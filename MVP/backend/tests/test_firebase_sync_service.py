"""
Unit tests for Firebase register-sync / login legacy-user handling.

Mocks persistence and Firebase verification — no live PostgreSQL required.
"""

import unittest
import uuid
from datetime import datetime, timezone
from unittest.mock import MagicMock, patch

from app.services.firebase_auth_service import FirebaseAuthClaims
from app.services.firebase_sync_service import login_exchange, register_sync


def _legacy_user(*, email="legacy@example.com", firebase_uid=None):
    user = MagicMock()
    user.id = uuid.uuid4()
    user.email = email
    user.firebase_uid = firebase_uid
    user.auth_provider = "local"
    user.email_verified_at = None
    user.is_active = True
    user.system_role = "customer"
    user.fcm_token = None
    return user


class FirebaseSyncLegacyUserTestCase(unittest.TestCase):
    """Legacy bcrypt rows without firebase_uid should link safely."""

    def setUp(self):
        self.claims = FirebaseAuthClaims(
            firebase_uid="firebase-uid-legacy",
            email="legacy@example.com",
            email_verified=True,
        )
        self.legacy = _legacy_user()

    @patch("app.services.firebase_sync_service.db")
    @patch("app.services.firebase_sync_service.user_repo")
    @patch(
        "app.services.firebase_sync_service.firebase_auth_service.verify_id_token",
        return_value=FirebaseAuthClaims(
            firebase_uid="firebase-uid-legacy",
            email="legacy@example.com",
            email_verified=False,
        ),
    )
    def test_register_sync_links_legacy_user_by_email(
        self,
        _verify,
        mock_user_repo,
        mock_db,
    ):
        mock_user_repo.get_by_firebase_uid.return_value = None
        mock_user_repo.get_user_by_email.return_value = self.legacy
        mock_user_repo.link_firebase_uid.return_value = self.legacy

        payload, status = register_sync(
            {
                "id_token": "token",
                "name": "Legacy User",
                "system_role": "customer",
            }
        )

        self.assertEqual(status, 200)
        self.assertEqual(payload["email"], "legacy@example.com")
        self.assertIn("linked", payload["message"].lower())
        mock_user_repo.link_firebase_uid.assert_called_once()
        mock_db.session.commit.assert_called_once()

    @patch("app.services.firebase_sync_service.db")
    @patch("app.services.firebase_sync_service.user_repo")
    @patch(
        "app.services.firebase_sync_service.firebase_auth_service.verify_id_token",
    )
    @patch("app.services.firebase_sync_service.create_access_token")
    @patch("app.services.firebase_sync_service.create_refresh_token")
    def test_login_links_legacy_user_by_email(
        self,
        mock_refresh,
        mock_access,
        mock_verify,
        mock_user_repo,
        mock_db,
    ):
        mock_verify.return_value = self.claims
        mock_user_repo.get_by_firebase_uid.return_value = None
        mock_user_repo.get_user_by_email.return_value = self.legacy
        mock_user_repo.link_firebase_uid.return_value = self.legacy
        mock_user_repo.sync_email_verified_from_firebase.return_value = self.legacy
        mock_access.return_value = "access"
        mock_refresh.return_value = "refresh"

        payload, status = login_exchange({"id_token": "token"})

        self.assertEqual(status, 200)
        self.assertIn("access_token", payload)
        mock_user_repo.link_firebase_uid.assert_called_once()
        mock_db.session.commit.assert_called_once()

    @patch("app.services.firebase_sync_service.db")
    @patch("app.services.firebase_sync_service.user_repo")
    @patch(
        "app.services.firebase_sync_service.firebase_auth_service.verify_id_token",
    )
    def test_login_returns_409_when_legacy_user_has_different_uid(
        self,
        mock_verify,
        mock_user_repo,
        mock_db,
    ):
        mock_verify.return_value = self.claims
        mock_user_repo.get_by_firebase_uid.return_value = None
        conflicting = _legacy_user(firebase_uid="other-firebase-uid")
        mock_user_repo.get_user_by_email.return_value = conflicting
        mock_user_repo.link_firebase_uid.side_effect = ValueError(
            "User is already linked to a different Firebase account"
        )

        payload, status = login_exchange({"id_token": "token"})

        self.assertEqual(status, 409)
        self.assertIn("error", payload)
        mock_db.session.rollback.assert_called_once()

    @patch("app.services.firebase_sync_service.user_repo")
    @patch(
        "app.services.firebase_sync_service.firebase_auth_service.verify_id_token",
    )
    def test_login_finds_user_by_firebase_uid(
        self,
        mock_verify,
        mock_user_repo,
    ):
        linked = _legacy_user(firebase_uid="firebase-uid-legacy")
        mock_verify.return_value = self.claims
        mock_user_repo.get_by_firebase_uid.return_value = linked

        with patch("app.services.firebase_sync_service.db") as mock_db, patch(
            "app.services.firebase_sync_service.create_access_token",
            return_value="access",
        ), patch(
            "app.services.firebase_sync_service.create_refresh_token",
            return_value="refresh",
        ):
            mock_user_repo.sync_email_verified_from_firebase.return_value = linked
            payload, status = login_exchange({"id_token": "token"})

        self.assertEqual(status, 200)
        mock_user_repo.get_user_by_email.assert_not_called()
        mock_user_repo.link_firebase_uid.assert_not_called()
        mock_db.session.commit.assert_called_once()


if __name__ == "__main__":
    unittest.main()
