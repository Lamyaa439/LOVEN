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