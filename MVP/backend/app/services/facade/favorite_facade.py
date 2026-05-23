"""
Favorite facade.

Thin orchestration layer for favorite API flows.

Routes call this facade.
The facade delegates business logic to favorite_service.
"""

from app.services import favorite_service


class FavoriteFacade:
    """
    Entry point for favorites routes.

    Every method returns:
        tuple: (response dict, HTTP status code)
    """

    @staticmethod
    def add(user_id, artwork_id):
        return favorite_service.add_favorite(user_id, artwork_id)

    @staticmethod
    def remove(user_id, artwork_id):
        return favorite_service.remove_favorite(user_id, artwork_id)

    @staticmethod
    def check(user_id, artwork_id):
        return favorite_service.check_favorite(user_id, artwork_id)

    @staticmethod
    def list_mine(user_id):
        return favorite_service.list_my_favorites(user_id)