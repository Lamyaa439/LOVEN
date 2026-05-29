"""
Favorite service layer.

Business logic for:
- favoriting artworks
- removing favorites
- checking favorite status
- listing a user's favorites

Returns:
    tuple: (response dict, HTTP status code)

Architecture:
    API Route -> Facade -> Service -> Repository -> Database
"""

from sqlalchemy.exc import IntegrityError

from app.core.uuid_utils import as_uuid

from app.models.favorites import Favorite

from app.persistence.repositories.artwork_repo import ArtworkRepository
from app.persistence.repositories.favorite_repo import FavoriteRepository


favorite_repo = FavoriteRepository()
artwork_repo = ArtworkRepository()


# =========================================================
# Private Helpers
# =========================================================

def _favorite_to_dict(favorite):
    """
    Serialize a Favorite model into JSON-safe dictionary.
    """

    if favorite is None:
        return None

    return {
        "id": str(favorite.id),
        "user_id": str(favorite.user_id),
        "artwork_id": str(favorite.artwork_id),
        "created_at": (
            favorite.created_at.isoformat()
            if favorite.created_at else None
        ),
    }


def _artwork_to_dict(artwork):
    """
    Serialize artwork for favorites list responses.
    """

    if artwork is None:
        return None

    return {
        "id": str(artwork.id),
        "artist_profile_id": str(artwork.artist_profile_id),
        "title": artwork.title,
        "description": artwork.description,
        "price": (
            str(artwork.price)
            if artwork.price is not None else None
        ),
        "quantity_available": artwork.quantity_available,
        "shipping_fee": (
            str(artwork.shipping_fee)
            if artwork.shipping_fee is not None else None
        ),
        "artwork_image_url": artwork.artwork_image_url,
        "status": artwork.status,
        "created_at": (
            artwork.created_at.isoformat()
            if artwork.created_at else None
        ),
        "updated_at": (
            artwork.updated_at.isoformat()
            if artwork.updated_at else None
        ),
    }


# =========================================================
# Public Service Functions
# =========================================================

def add_favorite(user_id, artwork_id):
    """
    Add artwork to user's favorites.

    Rules:
    - artwork must exist
    - artwork must not already be favorited
    """

    artwork = artwork_repo.get(as_uuid(artwork_id))

    if not artwork:
        return {"error": "Artwork not found"}, 404

    existing = favorite_repo.get_user_favorite(
        as_uuid(user_id),
        as_uuid(artwork_id),
    )

    if existing:
        return {"error": "Artwork already favorited"}, 400

    try:
        favorite = Favorite(
            user_id=as_uuid(user_id),
            artwork_id=as_uuid(artwork_id),
        )

        favorite_repo.add(favorite)

        return {
            "message": "Artwork added to favorites",
            "favorite": _favorite_to_dict(favorite),
        }, 201

    except IntegrityError:
        return {"error": "Could not favorite artwork"}, 400

    except Exception:
        return {"error": "Internal server error"}, 500


def remove_favorite(user_id, artwork_id):
    """
    Remove artwork from user's favorites.
    """

    favorite = favorite_repo.get_user_favorite(
        as_uuid(user_id),
        as_uuid(artwork_id),
    )

    if not favorite:
        return {"error": "Favorite not found"}, 404

    try:
        favorite_repo.delete(favorite.id)

        return {
            "message": "Artwork removed from favorites",
        }, 200

    except Exception:
        return {"error": "Internal server error"}, 500


def check_favorite(user_id, artwork_id):
    """
    Check whether artwork is favorited by user.
    """

    favorite = favorite_repo.get_user_favorite(
        as_uuid(user_id),
        as_uuid(artwork_id),
    )

    return {
        "is_favorited": favorite is not None,
    }, 200


def list_my_favorites(user_id):
    """
    List all favorited artworks for user.
    """

    artworks = favorite_repo.list_user_favorite_artworks(
        as_uuid(user_id),
    )

    favorite_artworks = [
        _artwork_to_dict(artwork) for artwork in artworks
    ]

    return {
        "favorites": favorite_artworks,
        "count": len(favorite_artworks),
    }, 200