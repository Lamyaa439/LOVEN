"""
Unit tests for NotificationService.

Mocks persistence and FCM push — no live Firebase or PostgreSQL required.
"""

import unittest
import uuid
from datetime import datetime
from unittest.mock import MagicMock, patch

from app.services.notification_service import NotificationService


def _user(*, user_id=None, name="Test User", fcm_token="fcm-token"):
    user = MagicMock()
    user.id = user_id or uuid.uuid4()
    user.name = name
    user.fcm_token = fcm_token
    return user


def _order(*, order_id=None):
    order = MagicMock()
    order.id = order_id or uuid.uuid4()
    return order


def _notification(
    *,
    notification_id=None,
    user_id=None,
    notification_type="welcome",
    title="Title",
    body="Body",
    reference_id=None,
    reference_type=None,
    is_read=False,
):
    notification = MagicMock()
    notification.id = notification_id or uuid.uuid4()
    notification.user_id = user_id or uuid.uuid4()
    notification.type = notification_type
    notification.title = title
    notification.body = body
    notification.reference_id = reference_id
    notification.reference_type = reference_type
    notification.is_read = is_read
    notification.created_at = datetime(2026, 6, 2, 12, 0, 0)
    notification.updated_at = datetime(2026, 6, 2, 12, 0, 0)
    notification.to_dict.return_value = {
        "id": str(notification.id),
        "user_id": str(notification.user_id),
        "type": notification_type,
        "title": title,
        "body": body,
        "reference_id": str(reference_id) if reference_id else None,
        "reference_type": reference_type,
        "is_read": is_read,
        "created_at": notification.created_at.isoformat(),
        "updated_at": notification.updated_at.isoformat(),
    }
    return notification


class NotificationServiceTestCase(unittest.TestCase):
    def setUp(self):
        self.repo = MagicMock()
        self.repo.find_order_status_notification.return_value = None
        self.service = NotificationService(repo=self.repo)

    def test_create_in_app_notification_persists_notification(self):
        user_id = uuid.uuid4()
        saved = _notification(user_id=user_id, notification_type="welcome")
        self.repo.create_notification.return_value = saved

        result = self.service.create_in_app_notification(
            user_id=user_id,
            type="welcome",
            title="Welcome to LOVEN! 🎨",
            body="Hi there, we're happy you're here!!",
        )

        self.repo.create_notification.assert_called_once_with(
            user_id=user_id,
            type="welcome",
            title="Welcome to LOVEN! 🎨",
            body="Hi there, we're happy you're here!!",
            reference_id=None,
            reference_type=None,
        )
        self.assertIs(result, saved)

    def test_notify_welcome_creates_welcome_notification(self):
        user = _user(name="Aisha")
        saved = _notification(
            user_id=user.id,
            notification_type=NotificationService.TYPE_WELCOME,
            title="Welcome to LOVEN! 🎨",
            body="Hi Aisha, we're happy you're here!!",
        )
        self.repo.model.query.filter.return_value.filter.return_value.first.return_value = None
        self.repo.create_notification.return_value = saved

        with patch.object(
            self.service,
            "_notification_exists",
            return_value=False,
        ), patch.object(
            self.service,
            "_send_push_best_effort",
            return_value=True,
        ) as mock_push:
            result = self.service.notify_welcome(user)

        self.repo.create_notification.assert_called_once()
        create_kwargs = self.repo.create_notification.call_args.kwargs
        self.assertEqual(create_kwargs["type"], NotificationService.TYPE_WELCOME)
        self.assertEqual(create_kwargs["user_id"], user.id)
        self.assertIn("Aisha", create_kwargs["body"])
        mock_push.assert_called_once()
        self.assertIs(result, saved)

    def test_notify_welcome_is_deduplicated_per_user(self):
        user = _user()
        existing = _notification(
            user_id=user.id,
            notification_type=NotificationService.TYPE_WELCOME,
        )

        with patch.object(
            self.service,
            "_notification_exists",
            return_value=True,
        ), patch.object(
            self.service,
            "_find_existing",
            return_value=existing,
        ):
            result = self.service.notify_welcome(user)

        self.repo.create_notification.assert_not_called()
        self.assertIs(result, existing)

    def test_notify_customer_order_status_creates_order_status_notification(self):
        buyer = _user(name="Customer")
        order = _order()
        saved = _notification(
            user_id=buyer.id,
            notification_type=NotificationService.TYPE_ORDER_STATUS,
            reference_id=order.id,
            reference_type=NotificationService.REFERENCE_ORDER,
        )
        self.repo.create_notification.return_value = saved

        with patch.object(
            self.service,
            "_send_push_best_effort",
            return_value=True,
        ) as mock_push:
            result = self.service.notify_customer_order_status(
                buyer,
                order,
                "shipped",
            )

        self.repo.find_order_status_notification.assert_called_once()
        self.repo.create_notification.assert_called_once()
        create_kwargs = self.repo.create_notification.call_args.kwargs
        self.assertEqual(create_kwargs["type"], NotificationService.TYPE_ORDER_STATUS)
        self.assertEqual(create_kwargs["reference_id"], order.id)
        self.assertEqual(create_kwargs["reference_type"], NotificationService.REFERENCE_ORDER)
        self.assertIn("shipped", create_kwargs["body"])
        mock_push.assert_called_once()
        self.assertIs(result, saved)

    def test_push_failure_does_not_break_persistence(self):
        user = _user()
        saved = _notification(user_id=user.id)
        self.repo.create_notification.return_value = saved

        with patch(
            "app.services.notification_service.send_push_notification",
            return_value=False,
        ):
            result = self.service.create_in_app_notification(
                user_id=user.id,
                type="welcome",
                title="Welcome",
                body="Hello",
                push_user=user,
                push_data={"type": "welcome", "action": "open_home_screen"},
            )

        self.repo.create_notification.assert_called_once()
        self.assertIs(result, saved)

    def test_send_push_best_effort_swallows_messaging_errors(self):
        with patch(
            "app.services.notification_service.send_push_notification",
            return_value=False,
        ):
            sent = self.service._send_push_best_effort(
                fcm_token="token",
                title="Title",
                body="Body",
                data={"type": "welcome", "action": "open_home_screen"},
            )

        self.assertFalse(sent)

    def test_build_push_data_includes_order_reference_keys(self):
        order_id = uuid.uuid4()

        payload = NotificationService._build_push_data(
            notification_type=NotificationService.TYPE_ORDER_STATUS,
            action="open_order_details",
            reference_id=order_id,
            reference_type=NotificationService.REFERENCE_ORDER,
            status="shipped",
        )

        self.assertEqual(payload["type"], NotificationService.TYPE_ORDER_STATUS)
        self.assertEqual(payload["action"], "open_order_details")
        self.assertEqual(payload["reference_id"], str(order_id))
        self.assertEqual(payload["reference_type"], NotificationService.REFERENCE_ORDER)
        self.assertEqual(payload["order_id"], str(order_id))
        self.assertEqual(payload["status"], "shipped")

    def test_build_push_data_includes_cart_and_feedback_keys(self):
        cart_id = uuid.uuid4()
        feedback_id = uuid.uuid4()

        cart_payload = NotificationService._build_push_data(
            notification_type=NotificationService.TYPE_CART_INACTIVITY,
            action="open_cart",
            reference_id=cart_id,
            reference_type=NotificationService.REFERENCE_CART,
        )
        feedback_payload = NotificationService._build_push_data(
            notification_type=NotificationService.TYPE_FEEDBACK_SUBMITTED,
            action="open_notifications",
            reference_id=feedback_id,
            reference_type=NotificationService.REFERENCE_FEEDBACK,
        )

        self.assertEqual(cart_payload["cart_id"], str(cart_id))
        self.assertEqual(feedback_payload["feedback_id"], str(feedback_id))

    def test_notify_customer_order_status_passes_standardized_push_payload(self):
        buyer = _user(name="Customer")
        order = _order()
        saved = _notification(
            user_id=buyer.id,
            notification_type=NotificationService.TYPE_ORDER_STATUS,
            reference_id=order.id,
            reference_type=NotificationService.REFERENCE_ORDER,
        )
        self.repo.create_notification.return_value = saved

        with patch.object(
            self.service,
            "_send_push_best_effort",
            return_value=True,
        ) as mock_push:
            self.service.notify_customer_order_status(
                buyer,
                order,
                "shipped",
            )

        self.repo.find_order_status_notification.assert_called_once()
        push_data = mock_push.call_args.kwargs["data"]
        self.assertEqual(push_data["reference_id"], str(order.id))
        self.assertEqual(push_data["reference_type"], NotificationService.REFERENCE_ORDER)
        self.assertEqual(push_data["order_id"], str(order.id))
        self.assertEqual(push_data["status"], "shipped")

    def test_notify_order_status_same_status_is_deduplicated(self):
        buyer = _user(name="Customer")
        order = _order()
        existing = _notification(
            user_id=buyer.id,
            notification_type=NotificationService.TYPE_ORDER_STATUS,
            reference_id=order.id,
            reference_type=NotificationService.REFERENCE_ORDER,
            body=f"Hi Customer, your order #{order.id} is now shipped.",
        )
        self.repo.find_order_status_notification.return_value = existing

        with patch.object(
            self.service,
            "_send_push_best_effort",
            return_value=True,
        ) as mock_push:
            result = self.service.notify_customer_order_status(
                buyer,
                order,
                "shipped",
            )

        self.repo.create_notification.assert_not_called()
        mock_push.assert_not_called()
        self.assertIs(result, existing)

    def test_notify_order_status_different_status_creates_separate_notifications(
        self,
    ):
        buyer = _user(name="Customer")
        order = _order()
        shipped = _notification(
            user_id=buyer.id,
            notification_type=NotificationService.TYPE_ORDER_STATUS,
            reference_id=order.id,
            reference_type=NotificationService.REFERENCE_ORDER,
            body=f"Hi Customer, your order #{order.id} is now shipped.",
        )
        delivered = _notification(
            user_id=buyer.id,
            notification_type=NotificationService.TYPE_ORDER_STATUS,
            reference_id=order.id,
            reference_type=NotificationService.REFERENCE_ORDER,
            body=f"Hi Customer, your order #{order.id} is now delivered.",
        )
        self.repo.find_order_status_notification.side_effect = [None, None]
        self.repo.create_notification.side_effect = [shipped, delivered]

        with patch.object(
            self.service,
            "_send_push_best_effort",
            return_value=True,
        ):
            first = self.service.notify_customer_order_status(
                buyer,
                order,
                "shipped",
            )
            second = self.service.notify_customer_order_status(
                buyer,
                order,
                "delivered",
            )

        self.assertEqual(self.repo.create_notification.call_count, 2)
        self.assertIs(first, shipped)
        self.assertIs(second, delivered)

    def test_order_status_body_suffix_normalizes_case_and_underscores(self):
        self.assertEqual(
            NotificationService._order_status_body_suffix("In_Transit"),
            "is now in transit.",
        )
        self.assertEqual(
            NotificationService._order_status_body_suffix("SHIPPED"),
            "is now shipped.",
        )

    def test_mark_read_is_not_owned_by_notification_service(self):
        """Read-state updates live in NotificationRepository / NotificationFacade."""
        self.assertFalse(hasattr(self.service, "mark_read"))
        self.assertFalse(hasattr(self.service, "mark_all_read"))


if __name__ == "__main__":
    unittest.main()
