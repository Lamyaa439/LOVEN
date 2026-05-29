"""
Favorite repository.

Handles database operations related to user favorites.

Responsibilities:
- Create favorite records
- Remove favorites
- Check whether an artwork is favorited
- Fetch all favorites for a user

Inherits generic CRUD functionality from SQLAlchemyRepository.
"""

from app.extensions import db
from app.models.artwork import Artwork
from app.persistence.repository import SQLAlchemyRepository
from app.models.favorites import Favorite


class FavoriteRepository(SQLAlchemyRepository):
    def __init__(self):
        super().__init__(Favorite)

    # =========================================================
    # Favorite Lookup Helpers
    # =========================================================

    def get_user_favorite(self, user_id, artwork_id):
        """
        Returns the favorite row if the user already favorited
        the artwork.

        Used for:
        - preventing duplicate favorites
        - checking favorite status
        - unfavorite operations
        """

        return (
            self.model.query
            .filter(self.model.user_id == user_id)
            .filter(self.model.artwork_id == artwork_id)
            .first()
        )

    def list_user_favorites(self, user_id):
        """
        Returns all artworks favorited by the user,
        newest favorites first.
        """

        return (
            self.model.query
            .filter(self.model.user_id == user_id)
            .order_by(self.model.created_at.desc())
            .all()
        )

    def list_user_favorite_artworks(self, user_id):
        """
        Return active artworks favorited by the user in a single query.

        Joins favorites to artworks and excludes soft-deleted rows from both
        tables. Results are ordered by favorite creation time (newest first).
        """
        if not user_id:
            return []

        return (
            db.session.query(Artwork)
            .join(Favorite, Favorite.artwork_id == Artwork.id)
            .filter(Favorite.user_id == user_id)
            .filter(Favorite.deleted_at.is_(None))
            .filter(Artwork.deleted_at.is_(None))
            .order_by(Favorite.created_at.desc())
            .all()
        )