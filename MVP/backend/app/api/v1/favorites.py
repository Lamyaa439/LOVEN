from flask import Blueprint, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity

from app.services.facade.favorite_facade import FavoriteFacade


favorites_bp = Blueprint("favorites", __name__)


def get_authenticated_user_id():
    current_user_identity = get_jwt_identity()

    if isinstance(current_user_identity, dict):
        return current_user_identity.get("user_id")

    return current_user_identity


@favorites_bp.get("/")
@jwt_required()
def list_my_favorites():
    user_id = get_authenticated_user_id()

    result, status_code = FavoriteFacade.list_mine(user_id)

    return jsonify(result), status_code


@favorites_bp.post("/<artwork_id>")
@jwt_required()
def add_favorite(artwork_id):
    user_id = get_authenticated_user_id()

    result, status_code = FavoriteFacade.add(
        user_id=user_id,
        artwork_id=artwork_id,
    )

    return jsonify(result), status_code


@favorites_bp.delete("/<artwork_id>")
@jwt_required()
def remove_favorite(artwork_id):
    user_id = get_authenticated_user_id()

    result, status_code = FavoriteFacade.remove(
        user_id=user_id,
        artwork_id=artwork_id,
    )

    return jsonify(result), status_code


@favorites_bp.get("/check/<artwork_id>")
@jwt_required()
def check_favorite(artwork_id):
    user_id = get_authenticated_user_id()

    result, status_code = FavoriteFacade.check(
        user_id=user_id,
        artwork_id=artwork_id,
    )

    return jsonify(result), status_code