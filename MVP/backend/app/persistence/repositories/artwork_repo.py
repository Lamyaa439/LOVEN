"""
Artwork repository.

Handles database operations related to the Artwork model.
Inherits generic CRUD from SQLAlchemyRepository: add, get, get_all, update,
delete, soft_delete, get_by_attribute, get_all_by_attribute.

Note: the Artwork model has no UNIQUE constraints (unlike ArtistProfile),
so there is no need for "include-soft-deleted" variants here.
"""
from app.persistence.repository import SQLAlchemyRepository
from app.models.artwork import Artwork


class ArtworkRepository(SQLAlchemyRepository):
    def __init__(self):
        super().__init__(Artwork)

    # =====================================================================
    # Artist-facing reads ("my listings" dashboard)
    # Returns ALL statuses (available, sold_out, hidden) so artists can
    # manage every listing they own. Soft-deleted rows are still skipped.
    # =====================================================================

    def list_active_by_artist(self, artist_profile_id, limit=20, offset=0):
        """
        Paginated list of an artist's own artworks, newest first.
        Used by the artist's "manage my listings" view.
        """
        if not artist_profile_id:
            return []
        return (
            self.model.query
            .filter(self.model.artist_profile_id == artist_profile_id)
            .filter(self.model.deleted_at.is_(None))
            .order_by(self.model.created_at.desc()) # the newest first 
            .limit(limit)
            .offset(offset)
            .all()
        )

    def count_by_artist(self, artist_profile_id):
        """
        Count of non-deleted artworks owned by an artist.
        Useful for the artist profile page ("12 artworks listed").

        just return a number of artworks
        """
        if not artist_profile_id:
            return 0
        return (
            self.model.query
            .filter(self.model.artist_profile_id == artist_profile_id)
            .filter(self.model.deleted_at.is_(None))
            .count()
        )

    # =====================================================================
    # Public-facing reads (App browse & search)
    # Defaults to status="available" so sold-out / hidden listings don't
    # surface in the App by accident.
    # =====================================================================

    def list_public(self, limit=20, offset=0, status="available"):
        """
        Paginated App listing, newest first.

        Args:
            status: artwork status to include. Defaults to "available".
            Pass None to include every status.
        """
        query = (
            self.model.query
            .filter(self.model.deleted_at.is_(None))
        )
        if status is not None:
            query = query.filter(self.model.status == status)
        return (
            query
            .order_by(self.model.created_at.desc())
            .limit(limit)
            .offset(offset)
            .all()
        )

    def get_public(self, artwork_id, status="available"):
        """
        Fetch a single artwork for public marketplace detail views.

        Excludes soft-deleted rows. When status is set (default "available"),
        hidden and sold_out listings are not returned.
        """
        if not artwork_id:
            return None

        query = self.model.query.filter(
            self.model.id == artwork_id,
            self.model.deleted_at.is_(None),
        )
        if status is not None:
            query = query.filter(self.model.status == status)
        return query.first()

    def search_by_title(self, query_text, limit=20, offset=0, status="available"):
        """
        Case-insensitive partial match on title (PostgreSQL ILIKE).
        Defaults to available-only so search results match the marketplace.
        """
        if not query_text:
            return []
        
        # here we used '%' so if a user searches for "Flower," the % symbols 
        # allow the system to find "Red Flower," "Flower Bouquet," or "The Beautiful Flower."
        # Without them, the database would only return an exact match for the single word "Flower."
        pattern = f"%{query_text.strip()}%"

        # used 'ilike' operator to ignores the difference between uppercase and lowercase letters.
        query = (
            self.model.query
            .filter(self.model.deleted_at.is_(None))
            .filter(self.model.title.ilike(pattern))
        )
        if status is not None:
            query = query.filter(self.model.status == status)
        return (
            query
            .order_by(self.model.created_at.desc())
            .limit(limit)
            .offset(offset)
            .all()
        )

    # =====================================================================
    # Targeted updates (thin wrappers around the generic update)
    # =====================================================================

    def update_image(self, artwork_id, new_url):
        """
        Persists the Firebase Storage URL after a successful image upload.
        """
        return self.update(artwork_id, {"artwork_image_url": new_url})

    def update_status(self, artwork_id, new_status):
        """
        Transitions an artwork between available / sold_out / hidden.
        The Artwork model's @validates('status') enforces the whitelist,
        so invalid values raise ValueError up to the service layer.
        """
        return self.update(artwork_id, {"status": new_status})
    
    def count_active_artworks(self):
        return (
            self.model.query
            .filter(self.model.deleted_at.is_(None))
            .count()
        )
