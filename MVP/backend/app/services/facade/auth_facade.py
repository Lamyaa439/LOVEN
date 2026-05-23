"""
Authentication Facade:
acts as the Orchestrator. It delegates the core business logic to the auth_service,
and coordinates with external services (like Firebase/Notifications)
without cluttering the core service logic.
"""

from app.external_services.firebase_service import send_welcome_notification
from app.persistence.repositories.user_repo import UserRepository
from app.services.auth_service import login_user, register_user
from app.services.facade.artists_profile_facade import ArtistsProfileFacade

user_repo = UserRepository()


class AuthFacade:

    @staticmethod
    def register(data: dict):
        """
        Manages the new user registration process.

        Orchestration:
        1. Create User (auth_service.register_user)
        2. Create linked ArtistProfile (ArtistsProfileFacade.create_for_registration)
        3. If step 2 fails, remove the user so the DB stays consistent
        4. Optional Firebase welcome notification
        """
        result, status_code = register_user(data)

        if status_code != 201:
            return result, status_code

        user_id = result.get("user_id")
        if not user_id:
            return {"error": "Registration succeeded but user_id is missing"}, 500

        # Step 2: empty artist profile so GET /artist-profiles/me does not 404.
        profile_result, profile_status = ArtistsProfileFacade.create_for_registration(
            user_id,
            data,
        )

        if profile_status not in (200, 201):
            # Step 3: profile failed — roll back the user row.
            try:
                user_repo.delete(user_id)
            except Exception as cleanup_error:
                print(f"Failed to roll back user after profile error: {cleanup_error}")

            return {
                "error": profile_result.get(
                    "error",
                    "User was created but artist profile setup failed",
                ),
            }, profile_status if profile_status >= 400 else 500

        # Step 4: welcome push (non-blocking).
        user_name = data.get("name", "Dear artist")
        fcm_token = data.get("fcm_token")

        if fcm_token:
            try:
                send_welcome_notification(fcm_token, user_name)
            except Exception as e:
                print(f"Failed to send welcome notification: {e}")

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
    def logout(user_id: str):
        """
        Manages the logout process.
        Clears the FCM token to prevent push notifications to a logged-out device.
        Args:
            user_id (str): The ID of the user logging out.

        Returns:
            tuple: (response data, HTTP status code)
        """
        try:
            user_repo.update_fcm_token(user_id, None)

            return {
                "message": "Logged out successfully and notifications disabled for this device."
            }, 200
        except Exception as e:
            print(f"Error during logout: {e}")
            return {"error": "An internal error occurred during logout"}, 500
