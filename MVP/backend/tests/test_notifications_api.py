"""
API tests for notifications routes.

Mocks NotificationFacade — no live PostgreSQL required.
"""

import unittest
import uuid
from unittest.mock import patch

from flask_jwt_extended import create_access_token

from app import create_app
from app.services.facade.notification_facade import NotificationFacade


def _notification_payload(*, notification_id=None, user_id=None, is_read=False):
    notification_id = notification_id or uuid.uuid4()
    user_id = user_id or uuid.uuid4()
    return {
        "id": str(notification_id),
        "user_id": str(user_id),
        "type": "order_status",
        "title": "Order update from LOVEN 🎨",
        "body": "Your order was shipped.",
        "reference_id": str(uuid.uuid4()),
        "reference_type": "order",
        "is_read": is_read,
        "created_at": "2026-06-02T12:00:00",
        "updated_at": "2026-06-02T12:00:00",
    }


class NotificationsApiTestCase(unittest.TestCase):
    def setUp(self):
        self.app = create_app()
        self.client = self.app.test_client()
        self.user_id = str(uuid.uuid4())
        self.other_user_id = str(uuid.uuid4())
        self.notification_id = str(uuid.uuid4())

    def _auth_headers(self, user_id):
        with self.app.app_context():
            token = create_access_token(identity=user_id)
        return {"Authorization": f"Bearer {token}"}

    @patch.object(NotificationFacade, "unread_count")
    @patch.object(NotificationFacade, "list_for_user")
    def test_authenticated_user_can_list_own_notifications(
        self,
        mock_list_for_user,
        mock_unread_count,
    ):
        notification = _notification_payload(user_id=self.user_id)
        mock_list_for_user.return_value = (
            {
                "notifications": [notification],
                "count": 1,
                "limit": 20,
                "offset": 0,
            },
            200,
        )
        mock_unread_count.return_value = ({"unread_count": 1}, 200)

        response = self.client.get(
            "/api/v1/notifications/",
            headers=self._auth_headers(self.user_id),
        )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.json["notifications"]), 1)
        self.assertEqual(response.json["notifications"][0]["id"], notification["id"])
        self.assertEqual(response.json["unread_count"], 1)
        mock_list_for_user.assert_called_once_with(
            user_id=self.user_id,
            limit=20,
            offset=0,
            unread_only=False,
        )
        mock_unread_count.assert_called_once_with(self.user_id)

    def test_list_notifications_requires_authentication(self):
        response = self.client.get("/api/v1/notifications/")
        self.assertEqual(response.status_code, 401)
        self.assertEqual(response.json["error"], "Authorization token required")

    @patch.object(NotificationFacade, "mark_read")
    def test_user_can_mark_own_notification_as_read(self, mock_mark_read):
        notification = _notification_payload(
            notification_id=self.notification_id,
            user_id=self.user_id,
            is_read=True,
        )
        mock_mark_read.return_value = (
            {
                "message": "Notification marked as read",
                "notification": notification,
            },
            200,
        )

        response = self.client.patch(
            f"/api/v1/notifications/{self.notification_id}/read",
            headers=self._auth_headers(self.user_id),
        )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json["notification"]["is_read"], True)
        mock_mark_read.assert_called_once_with(
            user_id=self.user_id,
            notification_id=self.notification_id,
        )

    @patch.object(NotificationFacade, "mark_read")
    def test_user_cannot_mark_another_users_notification_as_read(
        self,
        mock_mark_read,
    ):
        mock_mark_read.return_value = (
            {"error": "Notification not found"},
            404,
        )

        response = self.client.patch(
            f"/api/v1/notifications/{self.notification_id}/read",
            headers=self._auth_headers(self.other_user_id),
        )

        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.json["error"], "Notification not found")
        mock_mark_read.assert_called_once_with(
            user_id=self.other_user_id,
            notification_id=self.notification_id,
        )

    @patch.object(NotificationFacade, "mark_all_read")
    def test_user_can_mark_all_notifications_as_read(self, mock_mark_all_read):
        mock_mark_all_read.return_value = (
            {
                "message": "All notifications marked as read",
                "updated_count": 3,
            },
            200,
        )

        response = self.client.patch(
            "/api/v1/notifications/read-all",
            headers=self._auth_headers(self.user_id),
        )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json["updated_count"], 3)
        mock_mark_all_read.assert_called_once_with(self.user_id)


if __name__ == "__main__":
    unittest.main()
