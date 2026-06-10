"""
Artwork facade.

Acts as the orchestrator for artwork listing API flows. Delegates all business
logic to artwork_service.

Image handling: the mobile app uploads artwork images directly to Firebase
Storage and sends the resulting URL as artwork_image_url in the JSON body.
This layer does not accept multipart files or perform cloud storage operations.
"""

from app.services import artwork_service


class ArtworkFacade:
    """
    Entry point for artwork routes.

    Every method returns:
        tuple: (response dict, HTTP status code)
    """

    @staticmethod
    def create(user_id, data: dict):
        """
        Create a new artwork listing for the authenticated artist.

        Args:
            user_id: Authenticated user ID (from JWT).
            data: JSON body. Required: title, price.
                  Optional: description, quantity_available, shipping_fee,
                  artwork_image_url, status.

        Returns:
            201 with artwork on success; 400/404/500 on failure.
        """
        return artwork_service.create_artwork(user_id, data)

    @staticmethod
    def get_by_id(artwork_id):
        """
        Public lookup by artwork UUID.

        Args:
            artwork_id: Artwork primary key.

        Returns:
            200 with artwork, or 404 if not found.
        """
        return artwork_service.get_artwork(artwork_id)

    @staticmethod
    def list_public(limit=20, offset=0, status="available"):
        """
        Provides the primary discovery feed for the marketplace, allowing users 
        to browse available artworks from all artists with pagination support.

        Args:
            limit: Page size (1–100).
            offset: Rows to skip.
            status: Filter by status; default "available". Pass None for all.

        Returns:
            200 with artworks array and pagination metadata.
        """
        return artwork_service.list_public_artworks(
            limit=limit, offset=offset, status=status
        )

    @staticmethod
    def search(query_text, limit=20, offset=0, status="available"):
        """
        Case-insensitive title search for the marketplace.

        Args:
            query_text: Search string (partial match).
            limit: Page size (1–100).
            offset: Rows to skip.
            status: Filter by status; default "available".

        Returns:
            200 with matching artworks and pagination metadata.
        """
        return artwork_service.search_artworks(
            query_text, limit=limit, offset=offset, status=status
        )

    @staticmethod
    def list_mine(user_id, limit=20, offset=0):
        """
        Paginated list of the authenticated artist's own listings (all statuses).

        Args:
            user_id: Authenticated user ID (from JWT).
            limit: Page size (1–100).
            offset: Rows to skip.

        Returns:
            200 with artworks; 404 if artist profile not found.
        """
        return artwork_service.list_my_artworks(user_id, limit=limit, offset=offset)

    @staticmethod
    def list_for_profile(artist_profile_id, limit=20, offset=0, status="available"):
        """
        Public artworks for a specific artist profile page.

        Args:
            artist_profile_id: Artist profile UUID.
            limit: Page size (1–100).
            offset: Rows to skip.
            status: Filter by status; default "available". Pass None for all.

        Returns:
            200 with artworks; 404 if profile not found.
        """
        return artwork_service.list_artworks_for_profile(
            artist_profile_id, limit=limit, offset=offset, status=status
        )

    @staticmethod
    def count_for_profile(artist_profile_id):
        """
        Count of non-deleted artworks for an artist profile.

        Args:
            artist_profile_id: Artist profile UUID.

        Returns:
            200 with count; 404 if profile not found.
        """
        return artwork_service.count_artworks_for_profile(artist_profile_id)

    @staticmethod
    def update(user_id, artwork_id, data: dict):
        """
        Update an artwork listing owned by the authenticated artist.

        Args:
            user_id: Authenticated user ID (from JWT).
            artwork_id: Artwork primary key.
            data: JSON body with any writable listing fields, including
                  artwork_image_url.

        Returns:
            200 with updated artwork; 400/403/404/500 on failure.
        """
        return artwork_service.update_artwork(user_id, artwork_id, data)
    
    @staticmethod
    def admin_update_status(user_id, artwork_id, status):
        """
        Admin-only artwork moderation status update.
        """
        return artwork_service.admin_update_artwork_status(
            user_id=user_id,
            artwork_id=artwork_id,
            status=status,
        )

    @staticmethod
    def delete(user_id, artwork_id):
        """
        Soft-delete an artwork listing owned by the authenticated artist.

        Args:
            user_id: Authenticated user ID (from JWT).
            artwork_id: Artwork primary key.

        Returns:
            200 on success; 403 if not owner; 404 if not found; 500 on failure.
        """
        return artwork_service.soft_delete_artwork(user_id, artwork_id)
