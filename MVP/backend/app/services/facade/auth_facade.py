"""
Authentication facade — orchestrates auth flows for the API layer.

Delegates Firebase sync/login to ``firebase_sync_service`` and keeps
legacy helpers (logout, change-password) isolated from Firebase credential logic.
"""

import logging

from app.core.uuid_utils import as_uuid
from app.external_services.firebase_service import send_welcome_notification
from app.persistence.repositories.user_repo import UserRepository
from app.services.auth_service import change_password
from app.services.firebase_sync_service import login_exchange, register_sync

user_repo = UserRepository()
logger = logging.getLogger(__name__)

_LEGACY_DEPRECATED = {
    "error": "endpoint_deprecated",
    "message": (
        "Email/password auth uses Firebase Authentication. "
        "Use POST /api/v1/auth/firebase/register-sync and "
        "POST /api/v1/auth/firebase/login instead."
    ),
}


class AuthFacade:
    """Static entry points for auth routes — no business logic inline."""

    @staticmethod
    def register_firebase_sync(data: dict):
        """
        Sync LOVEN user after Firebase client signup.

        Returns 201 without LOVEN JWT per frozen auth contract.
        """
        return register_sync(data)

    @staticmethod
    def login_firebase(data: dict):
        """
        Exchange verified Firebase ID token for LOVEN JWT session.
        """
        return login_exchange(data)

    @staticmethod
    def register(data: dict):
        """Deprecated — legacy bcrypt register. Use :meth:`register_firebase_sync`."""
        return _LEGACY_DEPRECATED, 410

    @staticmethod
    def login(data: dict):
        """Deprecated — legacy bcrypt login. Use :meth:`login_firebase`."""
        return _LEGACY_DEPRECATED, 410

    @staticmethod
    def change_password(user_id: str, data: dict):
        return change_password(user_id, data)

    @staticmethod
    def logout(user_id):
        """
        Clear FCM token for the device on LOVEN logout.
        """
        try:
            uid = as_uuid(user_id)
        except (TypeError, ValueError):
            return {"error": "Invalid user identity"}, 401

        if not uid:
            return {"error": "Invalid user identity"}, 401

        try:
            updated = user_repo.update_fcm_token(uid, None)
            if not updated:
                return {"error": "User not found"}, 404

            return {
                "message": (
                    "Logged out successfully and notifications disabled "
                    "for this device."
                )
            }, 200
        except Exception:
            logger.exception("Error during logout")
            return {"error": "An internal error occurred during logout"}, 500

    def __init__(self, user_repo, jwt_service, firebase_auth_service):
        self.user_repo = user_repo
        self.jwt_service = jwt_service
        self.firebase_auth_service = firebase_auth_service

    def google_login(self, firebase_id_token: str):
        """Instance OAuth path — not wired for Milestone 1 Firebase email auth."""
        decoded = self.firebase_auth_service.verify_id_token(firebase_id_token)

        firebase_uid = decoded.get("uid")
        email = decoded.get("email")
        name = decoded.get("name")
        picture = decoded.get("picture")

        if not firebase_uid or not email:
            raise ValueError("Google account must provide email")

        user = self.user_repo.get_by_firebase_uid(firebase_uid)

        if not user:
            user = self.user_repo.get_by_email(email)

            if user:
                user = self.user_repo.link_firebase_uid(user, firebase_uid)
            else:
                user = self.user_repo.create_google_user(
                    email=email,
                    name=name,
                    firebase_uid=firebase_uid,
                    profile_picture=picture,
                )

        access_token = self.jwt_service.create_access_token(user)
        refresh_token = self.jwt_service.create_refresh_token(user)

        return {
            "user": user.to_dict(),
            "access_token": access_token,
            "refresh_token": refresh_token,
        }
