"""
Firebase ID token verification for LOVEN auth exchange.

Thin domain layer over ``firebase_service`` that normalizes Admin SDK
decoded tokens into a stable contract consumed by ``firebase_sync_service``.
Password credentials live in Firebase Auth — this module never handles passwords.
"""

from __future__ import annotations

from dataclasses import dataclass

from app.external_services import firebase_service


@dataclass(frozen=True)
class FirebaseAuthClaims:
    """Normalized identity extracted from a verified Firebase ID token."""

    firebase_uid: str
    email: str
    email_verified: bool
    display_name: str | None = None


class FirebaseAuthError(Exception):
    """Raised when a Firebase ID token is missing, invalid, or incomplete."""

    def __init__(self, message: str = "Invalid Firebase token"):
        super().__init__(message)
        self.message = message


class FirebaseAuthService:
    """
    Verifies Firebase ID tokens and exposes LOVEN-relevant claims.

    Architectural role: isolate Firebase Admin SDK details from sync/login
    business logic so ``firebase_sync_service`` stays testable and focused.
    """

    def verify_id_token(self, id_token: str | None) -> FirebaseAuthClaims:
        """
        Verify ``id_token`` and return normalized claims.

        Raises:
            FirebaseAuthError: When the token is absent, invalid, or lacks uid/email.
        """
        if not id_token or not str(id_token).strip():
            raise FirebaseAuthError("id_token is required")

        try:
            decoded = firebase_service.verify_firebase_id_token(id_token.strip())
        except ValueError as exc:
            raise FirebaseAuthError(str(exc)) from exc

        firebase_uid = decoded.get("uid") or decoded.get("user_id")
        email = decoded.get("email")

        if not firebase_uid or not email:
            raise FirebaseAuthError(
                "Firebase token must include uid and email"
            )

        email_verified = bool(decoded.get("email_verified"))

        return FirebaseAuthClaims(
            firebase_uid=str(firebase_uid),
            email=str(email).strip().lower(),
            email_verified=email_verified,
            display_name=decoded.get("name"),
        )


firebase_auth_service = FirebaseAuthService()
