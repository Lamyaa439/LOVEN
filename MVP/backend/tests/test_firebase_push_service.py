"""
Unit tests for canonical FCM transport in firebase_service.
"""

import unittest
from unittest.mock import patch

from app.external_services.firebase_service import send_push_notification


class FirebasePushServiceTestCase(unittest.TestCase):
    @patch("app.external_services.firebase_service.messaging.send")
    @patch("app.external_services.firebase_service._ensure_firebase", return_value=True)
    def test_send_push_notification_stringifies_data_payload(
        self,
        _mock_ensure,
        mock_send,
    ):
        mock_send.return_value = "projects/test/messages/abc"

        sent = send_push_notification(
            "device-token",
            title="Title",
            body="Body",
            data={
                "type": "order_status",
                "action": "open_order_details",
                "reference_id": "order-uuid",
                "reference_type": "order",
                "order_id": "order-uuid",
                "status": "shipped",
                "ignored": None,
            },
        )

        self.assertTrue(sent)
        message = mock_send.call_args.args[0]
        self.assertEqual(message.token, "device-token")
        self.assertEqual(message.notification.title, "Title")
        self.assertEqual(message.notification.body, "Body")
        self.assertEqual(message.data["type"], "order_status")
        self.assertEqual(message.data["order_id"], "order-uuid")
        self.assertNotIn("ignored", message.data)

    @patch("app.external_services.firebase_service._ensure_firebase", return_value=False)
    def test_send_push_notification_returns_false_when_firebase_unavailable(
        self,
        _mock_ensure,
    ):
        sent = send_push_notification(
            "device-token",
            title="Title",
            body="Body",
            data={"type": "welcome", "action": "open_home_screen"},
        )

        self.assertFalse(sent)

    @patch("app.external_services.firebase_service.messaging.send")
    @patch("app.external_services.firebase_service._ensure_firebase", return_value=True)
    def test_send_push_notification_swallows_send_errors(
        self,
        _mock_ensure,
        mock_send,
    ):
        mock_send.side_effect = Exception("FCM down")

        sent = send_push_notification(
            "device-token",
            title="Title",
            body="Body",
            data={"type": "welcome", "action": "open_home_screen"},
        )

        self.assertFalse(sent)


if __name__ == "__main__":
    unittest.main()
