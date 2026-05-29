"""
Authentication Facade:
acts as the Orchestrator. It delegates the core business logic to the auth_service,
and coordinates with external services (like Firebase/Notifications)
without cluttering the core service logic.
"""

from app.external_services.firebase_service import send_welcome_notification
from app.core.uuid_utils import as_uuid
from app.persistence.repositories.user_repo import UserRepository
from app.services.auth_service import login_user, register_user
import logging

user_repo = UserRepository()
logger = logging.getLogger(__name__)


class AuthFacade:

    @staticmethod
    def register(data: dict):
        """
        Manages the new user registration process.

        User and artist profile are created atomically in register_user.
        Welcome notification is sent only after a successful commit.
        """
        result, status_code = register_user(data)

        if status_code != 201:
            return result, status_code

        user_name = data.get("name", "Dear artist")
        fcm_token = data.get("fcm_token")

        if fcm_token:
            try:
                send_welcome_notification(fcm_token, user_name)
            except Exception as e:
                logger.warning(
                    "Failed to send welcome notification: %s", e
                )

        return result, status_code

    @staticmethod
    def login(data: dict):
        """
        Manages the login process.
        Args:
            data (dict): Login details including the FCM token.

        Returns:
            tuple: (response data, HTTP status code)
        """
        result, status_code = login_user(data)
        return result, status_code

    @staticmethod
    def logout(user_id):
        """
        Manages the logout process.
        Clears the FCM token to prevent push notifications to a logged-out device.
        Args:
            user_id: Normalized user UUID string from JWT (via auth_utils).

        Returns:
            tuple: (response data, HTTP status code)
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
                "message": "Logged out successfully and notifications disabled for this device."
            }, 200
        except Exception:
            logger.exception("Error during logout")
            return {"error": "An internal error occurred during logout"}, 500
