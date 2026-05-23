"""
Artist profile facade.

Acts as the orchestrator for artist profile API flows. Delegates all business
logic to artists_profiles_service.

Image handling: the mobile app uploads profile photos directly to Firebase
Storage and sends the resulting URL as profile_image_url in the JSON body.
This layer does not accept multipart files or perform cloud storage operations.
"""

from app.services import artists_profiles_service as profile_service


class ArtistsProfileFacade:
    """
    Entry point for artist profile routes.

    Every method returns:
        tuple: (response dict, HTTP status code)
    """

    @staticmethod
    def create_for_registration(user_id, data: dict):
        """
        Auto-create a profile after signup (called from AuthFacade.register).

        Args:
            user_id: New user's UUID string from register_user.
            data: Original registration JSON (name, email, etc.).

        Returns:
            200/201 with profile on success; 4xx/5xx on failure.
        """
        return profile_service.bootstrap_artist_profile(user_id, data)

    @staticmethod
    def create(user_id, data: dict):
        """
        Create a new artist profile, or restore a previously soft-deleted one.

        Args:
            user_id: Authenticated user ID (from JWT).
            data: JSON body. Required for new profiles: display_name.
            Optional: city, bio, shipping_policy, profile_image_url.

        Returns:
            201 with profile on success; 400/403/404/500 on failure.
        """
        return profile_service.create_artist_profile(user_id, data)

    @staticmethod
    def get_my_profile(user_id):
        """
        Return the authenticated user's active artist profile.

        Args:
            user_id: Authenticated user ID (from JWT).

        Returns:
            200 on success with profile, or 404 if none exists.
        """
        return profile_service.get_my_profile(user_id)

    @staticmethod
    def get_by_id(profile_id):
        """
        Public lookup by artist profile UUID.

        Args:
            profile_id: Artist profile primary key.

        Returns:
            200 on success with profile, or 404 if not found (includes soft-deleted).
        """
        return profile_service.get_profile_by_id(profile_id)

    @staticmethod
    def get_by_display_name(display_name: str):
        """
        Public lookup by unique display name (handle).

        Args:
            display_name: Artist public handle (e.g. for share links).

        Returns:
            200 on success with profile; 400 if missing; 404 if not found.
        """
        return profile_service.get_profile_by_display_name(display_name)

    @staticmethod
    def list_profiles(limit=20, offset=0):
        """
        Paginated list of active artist profiles (newest first).

        Args:
            limit: Page size (1–100, enforced in service).
            offset: Rows to skip.

        Returns:
            200 on success with profiles array and pagination metadata.
        """
        return profile_service.list_artist_profiles(limit=limit, offset=offset)

    @staticmethod
    def update(user_id, data: dict):
        """
        Update the authenticated user's active artist profile.

        Args:
            user_id: Authenticated user ID (from JWT).
            data: JSON body with any of: display_name, city, bio,
            shipping_policy, profile_image_url.

        Returns:
            200 on success with updated profile; 400/404/500 on failure.
        """
        return profile_service.update_my_profile(user_id, data)

    @staticmethod
    def delete(user_id):
        """
        Soft-delete the authenticated user's artist profile.

        Args:
            user_id: Authenticated user ID (from JWT).

        Returns:
            200 on success; 404 if no active profile; 500 on failure.
        """
        return profile_service.soft_delete_my_profile(user_id)
