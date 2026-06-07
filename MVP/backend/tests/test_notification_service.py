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
            "app.services.notification_service.initialize_firebase",
            return_value=True,
        ), patch(
            "app.services.notification_service.messaging.send",
            side_effect=Exception("FCM unavailable"),
        ):
            result = self.service.create_in_app_notification(
                user_id=user.id,
                type="welcome",
                title="Welcome",
                body="Hello",
                push_user=user,
                push_data={"type": "welcome"},
            )

        self.repo.create_notification.assert_called_once()
        self.assertIs(result, saved)

    def test_send_push_best_effort_swallows_messaging_errors(self):
        with patch(
            "app.services.notification_service.initialize_firebase",
            return_value=True,
        ), patch(
            "app.services.notification_service.messaging.send",
            side_effect=Exception("send failed"),
        ):
            sent = self.service._send_push_best_effort(
                fcm_token="token",
                title="Title",
                body="Body",
                data={"type": "welcome"},
            )

        self.assertFalse(sent)

    def test_mark_read_is_not_owned_by_notification_service(self):
        """Read-state updates live in NotificationRepository / NotificationFacade."""
        self.assertFalse(hasattr(self.service, "mark_read"))
        self.assertFalse(hasattr(self.service, "mark_all_read"))


if __name__ == "__main__":
    unittest.main()
