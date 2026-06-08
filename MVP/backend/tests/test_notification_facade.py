"""
Unit tests for NotificationFacade list pagination metadata.
"""

import unittest
import uuid
from datetime import datetime
from unittest.mock import MagicMock, patch

from app.services.facade.notification_facade import NotificationFacade


def _notification_row(*, user_id):
    notification = MagicMock()
    notification.to_dict.return_value = {
        "id": str(uuid.uuid4()),
        "user_id": str(user_id),
        "type": "welcome",
        "title": "Welcome",
        "body": "Hello",
        "reference_id": None,
        "reference_type": None,
        "is_read": False,
        "created_at": datetime(2026, 6, 2, 12, 0, 0).isoformat(),
        "updated_at": datetime(2026, 6, 2, 12, 0, 0).isoformat(),
    }
    return notification


class NotificationFacadeListTestCase(unittest.TestCase):
    @patch("app.services.facade.notification_facade.notification_repo")
    def test_list_for_user_returns_page_count_and_total_count(
        self,
        mock_repo,
    ):
        user_id = uuid.uuid4()
        page_rows = [_notification_row(user_id=user_id)]
        mock_repo.list_for_user.return_value = page_rows
        mock_repo.count_for_user.return_value = 12

        result, status_code = NotificationFacade.list_for_user(
            user_id=user_id,
            limit=1,
            offset=0,
            unread_only=False,
        )

        self.assertEqual(status_code, 200)
        self.assertEqual(result["count"], 1)
        self.assertEqual(result["total_count"], 12)
        self.assertEqual(result["limit"], 1)
        self.assertEqual(result["offset"], 0)
        mock_repo.count_for_user.assert_called_once_with(
            user_id=user_id,
            unread_only=False,
        )

    @patch("app.services.facade.notification_facade.notification_repo")
    def test_total_count_respects_unread_only_filter(self, mock_repo):
        user_id = uuid.uuid4()
        mock_repo.list_for_user.return_value = []
        mock_repo.count_for_user.return_value = 3

        result, status_code = NotificationFacade.list_for_user(
            user_id=user_id,
            limit=20,
            offset=0,
            unread_only=True,
        )

        self.assertEqual(status_code, 200)
        self.assertEqual(result["count"], 0)
        self.assertEqual(result["total_count"], 3)
        mock_repo.count_for_user.assert_called_once_with(
            user_id=user_id,
            unread_only=True,
        )


if __name__ == "__main__":
    unittest.main()
