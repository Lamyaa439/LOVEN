"""
Contract tests for Firebase auth routes.

Uses mocks for Firebase Admin verification — no live Firebase or PostgreSQL required
for the unverified-login and deprecated-endpoint cases.
"""

import unittest
from unittest.mock import patch

from app import create_app
from app.services.firebase_auth_service import FirebaseAuthClaims


class FirebaseAuthApiTestCase(unittest.TestCase):
    """HTTP contract for register-sync, login exchange, and deprecated routes."""

    def setUp(self):
        self.app = create_app()
        self.client = self.app.test_client()
        self.claims_unverified = FirebaseAuthClaims(
            firebase_uid="firebase-uid-1",
            email="user@example.com",
            email_verified=False,
        )
        self.claims_verified = FirebaseAuthClaims(
            firebase_uid="firebase-uid-1",
            email="user@example.com",
            email_verified=True,
        )

    def test_legacy_register_returns_410(self):
        response = self.client.post(
            "/api/v1/register",
            json={"email": "a@b.com", "password": "x"},
        )
        self.assertEqual(response.status_code, 410)
        self.assertEqual(response.json["error"], "endpoint_deprecated")

    def test_legacy_login_returns_410(self):
        response = self.client.post(
            "/api/v1/login",
            json={"email": "a@b.com", "password": "x"},
        )
        self.assertEqual(response.status_code, 410)

    def test_firebase_login_unverified_returns_403(self):
        with patch(
            "app.services.firebase_sync_service.firebase_auth_service.verify_id_token",
            return_value=self.claims_unverified,
        ):
            response = self.client.post(
                "/api/v1/auth/firebase/login",
                json={"id_token": "fake-token"},
            )

        self.assertEqual(response.status_code, 403)
        self.assertEqual(response.json["error"], "email_not_verified")

    def test_firebase_register_sync_requires_id_token(self):
        response = self.client.post(
            "/api/v1/auth/firebase/register-sync",
            json={"name": "Test User"},
        )
        self.assertEqual(response.status_code, 400)
        self.assertIn("id_token", response.json["error"])

    def test_firebase_login_requires_id_token(self):
        response = self.client.post("/api/v1/auth/firebase/login", json={})
        self.assertEqual(response.status_code, 400)


if __name__ == "__main__":
    unittest.main()
