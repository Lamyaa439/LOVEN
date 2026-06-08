"""
Notification service.

Central owner for in-app notification creation and optional FCM push
dispatch. Business flows should call this service rather than writing
notification rows or sending push messages directly.
"""

import logging

from app.external_services.firebase_service import send_push_notification
from app.persistence.repositories.notification_repo import notification_repo


logger = logging.getLogger(__name__)


class NotificationService:
    TYPE_WELCOME = "welcome"
    TYPE_ORDER_NEW_ARTIST = "order_new_artist"
    TYPE_ARTIST_ORDER_REMINDER = "artist_order_reminder"
    TYPE_ORDER_STATUS = "order_status"
    TYPE_PAYMENT_SUCCESS = "payment_success"
    TYPE_FEEDBACK_SUBMITTED = "feedback_submitted"
    TYPE_CART_INACTIVITY = "cart_inactivity"

    REFERENCE_ORDER = "order"
    REFERENCE_FEEDBACK = "feedback"
    REFERENCE_CART = "cart"

    def __init__(self, repo=None):
        self.notification_repo = repo or notification_repo

    def create_in_app_notification(
        self,
        user_id,
        type,
        title,
        body,
        reference_id=None,
        reference_type=None,
        *,
        push_user=None,
        push_data=None,
    ):
        """
        Persist an in-app notification, then attempt optional push delivery.

        Push delivery is best-effort and never raises to callers.
        """
        notification = self.notification_repo.create_notification(
            user_id=user_id,
            type=type,
            title=title,
            body=body,
            reference_id=reference_id,
            reference_type=reference_type,
        )

        if push_user is not None:
            self._send_push_best_effort(
                fcm_token=getattr(push_user, "fcm_token", None),
                title=title,
                body=body,
                data=push_data,
            )

        return notification

    def notify_welcome(self, user):
        """
        Welcome notification for a newly registered user.

        Deduplicated: at most one welcome notification per user.
        """
        if not user or not user.id:
            return None

        if self._notification_exists(user.id, self.TYPE_WELCOME):
            logger.debug(
                "Skipping duplicate welcome notification for user_id=%s",
                user.id,
            )
            return self._find_existing(user.id, self.TYPE_WELCOME)

        display_name = user.name or "there"
        title = "Welcome to LOVEN! 🎨"
        body = f"Hi {display_name}, we're happy you're here!!"

        return self.create_in_app_notification(
            user_id=user.id,
            type=self.TYPE_WELCOME,
            title=title,
            body=body,
            push_user=user,
            push_data=self._build_push_data(
                notification_type=self.TYPE_WELCOME,
                action="open_home_screen",
            ),
        )

    def notify_artist_new_order(self, artist_user, order):
        """
        Notify an artist that they received a new order.

        Deduplicated: at most one new-order notification per artist per order.
        """
        if not artist_user or not artist_user.id:
            return None
        if not order or not order.id:
            return None

        if self._notification_exists(
            artist_user.id,
            self.TYPE_ORDER_NEW_ARTIST,
            reference_id=order.id,
            reference_type=self.REFERENCE_ORDER,
        ):
            logger.debug(
                "Skipping duplicate artist new-order notification "
                "for user_id=%s order_id=%s",
                artist_user.id,
                order.id,
            )
            return self._find_existing(
                artist_user.id,
                self.TYPE_ORDER_NEW_ARTIST,
                reference_id=order.id,
                reference_type=self.REFERENCE_ORDER,
            )

        order_id = str(order.id)
        title = "New order on LOVEN 🎨"
        body = f"You received a new order #{order_id}."

        return self.create_in_app_notification(
            user_id=artist_user.id,
            type=self.TYPE_ORDER_NEW_ARTIST,
            title=title,
            body=body,
            reference_id=order.id,
            reference_type=self.REFERENCE_ORDER,
            push_user=artist_user,
            push_data=self._build_push_data(
                notification_type=self.TYPE_ORDER_NEW_ARTIST,
                action="open_order_details",
                reference_id=order.id,
                reference_type=self.REFERENCE_ORDER,
            ),
        )

    def notify_artist_order_reminder(self, artist_user, order):
        """
        Remind an artist to fulfill a paid order.

        Callable by future scheduled jobs. Deduplicated per artist per order
        so repeated cron runs do not create duplicate reminders.
        """
        if not artist_user or not artist_user.id:
            return None
        if not order or not order.id:
            return None

        if self._notification_exists(
            artist_user.id,
            self.TYPE_ARTIST_ORDER_REMINDER,
            reference_id=order.id,
            reference_type=self.REFERENCE_ORDER,
        ):
            logger.debug(
                "Skipping duplicate artist order reminder "
                "for user_id=%s order_id=%s",
                artist_user.id,
                order.id,
            )
            return self._find_existing(
                artist_user.id,
                self.TYPE_ARTIST_ORDER_REMINDER,
                reference_id=order.id,
                reference_type=self.REFERENCE_ORDER,
            )

        order_id = str(order.id)
        title = "Order Preparation reminder"
        body = (
            f"Order #{order_id} is paid and waiting for Preparation. "
            "Please send it out when you're ready."
        )

        return self.create_in_app_notification(
            user_id=artist_user.id,
            type=self.TYPE_ARTIST_ORDER_REMINDER,
            title=title,
            body=body,
            reference_id=order.id,
            reference_type=self.REFERENCE_ORDER,
            push_user=artist_user,
            push_data=self._build_push_data(
                notification_type=self.TYPE_ARTIST_ORDER_REMINDER,
                action="open_order_details",
                reference_id=order.id,
                reference_type=self.REFERENCE_ORDER,
            ),
        )

    def notify_customer_order_status(self, buyer_user, order, new_status):
        """
        Notify a customer that their order status changed.

        Deduplicated: at most one order-status notification per buyer per order
        per status value (e.g. shipped and delivered may both exist; repeated
        shipped does not create another row).
        """
        if not buyer_user or not buyer_user.id:
            return None
        if not order or not order.id:
            return None
        if not new_status:
            return None

        body_suffix = self._order_status_body_suffix(new_status)
        existing = self.notification_repo.find_order_status_notification(
            user_id=buyer_user.id,
            order_id=order.id,
            body_suffix=body_suffix,
        )
        if existing:
            logger.debug(
                "Skipping duplicate order-status notification "
                "for user_id=%s order_id=%s status=%s",
                buyer_user.id,
                order.id,
                new_status,
            )
            return existing

        order_id = str(order.id)
        display_name = buyer_user.name or "Customer"
        display_status = self._order_status_display(new_status)
        title = "Order update from LOVEN 🎨"
        body = (
            f"Hi {display_name}, your order #{order_id} "
            f"is now {display_status}."
        )

        return self.create_in_app_notification(
            user_id=buyer_user.id,
            type=self.TYPE_ORDER_STATUS,
            title=title,
            body=body,
            reference_id=order.id,
            reference_type=self.REFERENCE_ORDER,
            push_user=buyer_user,
            push_data=self._build_push_data(
                notification_type=self.TYPE_ORDER_STATUS,
                action="open_order_details",
                reference_id=order.id,
                reference_type=self.REFERENCE_ORDER,
                status=str(new_status),
            ),
        )

    def notify_payment_success(self, buyer_user, order, payment=None):
        """
        Notify a customer that payment for an order succeeded.

        Deduplicated: at most one payment-success notification per buyer
        per order.
        """
        if not buyer_user or not buyer_user.id:
            return None
        if not order or not order.id:
            return None

        if self._notification_exists(
            buyer_user.id,
            self.TYPE_PAYMENT_SUCCESS,
            reference_id=order.id,
            reference_type=self.REFERENCE_ORDER,
        ):
            logger.debug(
                "Skipping duplicate payment-success notification "
                "for user_id=%s order_id=%s",
                buyer_user.id,
                order.id,
            )
            return self._find_existing(
                buyer_user.id,
                self.TYPE_PAYMENT_SUCCESS,
                reference_id=order.id,
                reference_type=self.REFERENCE_ORDER,
            )

        order_id = str(order.id)
        display_name = buyer_user.name or "Customer"
        title = "Payment confirmed 🎨"
        body = (
            f"Hi {display_name}, your payment for order #{order_id} "
            "was successful."
        )

        payment_id = (
            str(payment.id)
            if payment is not None and getattr(payment, "id", None)
            else None
        )

        return self.create_in_app_notification(
            user_id=buyer_user.id,
            type=self.TYPE_PAYMENT_SUCCESS,
            title=title,
            body=body,
            reference_id=order.id,
            reference_type=self.REFERENCE_ORDER,
            push_user=buyer_user,
            push_data=self._build_push_data(
                notification_type=self.TYPE_PAYMENT_SUCCESS,
                action="open_order_details",
                reference_id=order.id,
                reference_type=self.REFERENCE_ORDER,
                payment_id=payment_id,
            ),
        )

    def notify_feedback_submitted(self, user, feedback):
        """Confirm to a user that their feedback was received."""
        if not user or not user.id:
            return None
        if not feedback or not feedback.id:
            return None

        display_name = user.name or "there"
        title = "Thanks for your feedback"
        body = (
            f"Hi {display_name}, we received your feedback and appreciate "
            "you helping us improve LOVEN."
        )

        return self.create_in_app_notification(
            user_id=user.id,
            type=self.TYPE_FEEDBACK_SUBMITTED,
            title=title,
            body=body,
            reference_id=feedback.id,
            reference_type=self.REFERENCE_FEEDBACK,
            push_user=user,
            push_data=self._build_push_data(
                notification_type=self.TYPE_FEEDBACK_SUBMITTED,
                action="open_notifications",
                reference_id=feedback.id,
                reference_type=self.REFERENCE_FEEDBACK,
            ),
        )

    def notify_cart_inactivity(self, user, cart):
        """
        Remind a user about items left in their cart.

        Callable by future scheduled jobs. Deduplicated per user per cart
        so repeated cron runs do not create duplicate reminders.
        """
        if not user or not user.id:
            return None
        if not cart or not cart.id:
            return None

        if self._notification_exists(
            user.id,
            self.TYPE_CART_INACTIVITY,
            reference_id=cart.id,
            reference_type=self.REFERENCE_CART,
        ):
            logger.debug(
                "Skipping duplicate cart inactivity notification "
                "for user_id=%s cart_id=%s",
                user.id,
                cart.id,
            )
            return self._find_existing(
                user.id,
                self.TYPE_CART_INACTIVITY,
                reference_id=cart.id,
                reference_type=self.REFERENCE_CART,
            )

        display_name = user.name or "there"
        title = "Items waiting in your cart"
        body = (
            f"Hi {display_name}, you still have items in your cart. "
            "Complete your purchase before they're gone."
        )

        return self.create_in_app_notification(
            user_id=user.id,
            type=self.TYPE_CART_INACTIVITY,
            title=title,
            body=body,
            reference_id=cart.id,
            reference_type=self.REFERENCE_CART,
            push_user=user,
            push_data=self._build_push_data(
                notification_type=self.TYPE_CART_INACTIVITY,
                action="open_cart",
                reference_id=cart.id,
                reference_type=self.REFERENCE_CART,
            ),
        )

    def _notification_exists(
        self,
        user_id,
        notification_type,
        reference_id=None,
        reference_type=None,
    ):
        """Return True when a matching notification row already exists."""
        return (
            self._find_existing(
                user_id,
                notification_type,
                reference_id=reference_id,
                reference_type=reference_type,
            )
            is not None
        )

    def _find_existing(
        self,
        user_id,
        notification_type,
        reference_id=None,
        reference_type=None,
    ):
        """Return the first matching notification row, if any."""
        query = (
            self.notification_repo.model.query
            .filter(self.notification_repo.model.user_id == user_id)
            .filter(self.notification_repo.model.type == notification_type)
        )

        if reference_id is not None:
            query = query.filter(
                self.notification_repo.model.reference_id == reference_id
            )

        if reference_type is not None:
            query = query.filter(
                self.notification_repo.model.reference_type == reference_type
            )

        return query.first()

    @staticmethod
    def _normalize_order_status(status):
        """Normalize raw status values for stable display and dedupe matching."""
        return str(status).strip().lower()

    @classmethod
    def _order_status_display(cls, status):
        """Human-readable status label used in notification copy."""
        return cls._normalize_order_status(status).replace("_", " ")

    @classmethod
    def _order_status_body_suffix(cls, status):
        """
        Stable trailing body fragment identifying a specific order status.

        Used by order_status dedupe to distinguish shipped vs delivered while
        collapsing repeated emissions of the same status.
        """
        return f"is now {cls._order_status_display(status)}."

    @staticmethod
    def _build_push_data(
        *,
        notification_type,
        action,
        reference_id=None,
        reference_type=None,
        order_id=None,
        cart_id=None,
        feedback_id=None,
        payment_id=None,
        status=None,
    ):
        """
        Build the canonical FCM data payload for a notification type.

        Always includes ``type`` and ``action``. Entity reference keys
        (``reference_id``, ``reference_type``, and typed IDs) are added
        when provided so Flutter can route from one consistent contract.
        """
        data = {
            "type": notification_type,
            "action": action,
        }

        if reference_id is not None:
            data["reference_id"] = str(reference_id)

        if reference_type is not None:
            data["reference_type"] = reference_type

        if reference_type == NotificationService.REFERENCE_ORDER:
            resolved_order_id = order_id if order_id is not None else reference_id
            if resolved_order_id is not None:
                data["order_id"] = str(resolved_order_id)

        if reference_type == NotificationService.REFERENCE_CART:
            resolved_cart_id = cart_id if cart_id is not None else reference_id
            if resolved_cart_id is not None:
                data["cart_id"] = str(resolved_cart_id)

        if reference_type == NotificationService.REFERENCE_FEEDBACK:
            resolved_feedback_id = (
                feedback_id if feedback_id is not None else reference_id
            )
            if resolved_feedback_id is not None:
                data["feedback_id"] = str(resolved_feedback_id)

        if payment_id is not None:
            data["payment_id"] = str(payment_id)

        if status is not None:
            data["status"] = str(status)

        return data

    def _send_push_best_effort(self, fcm_token, title, body, data=None):
        """
        Attempt FCM delivery without affecting the caller's control flow.

        Delegates transport to firebase_service.send_push_notification.
        Returns True when a message was sent, False otherwise.
        """
        return send_push_notification(
            fcm_token,
            title=title,
            body=body,
            data=data,
        )


notification_service = NotificationService()
