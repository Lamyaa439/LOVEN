from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity

from app.services.account_service import AccountService

account_bp = Blueprint("account", __name__)
account_service = AccountService()


@account_bp.route("/account/me", methods=["OPTIONS"])
def account_me_options():
    return "", 200


@account_bp.get("/account/me")
@jwt_required()
def get_current_account():
    user_id = get_jwt_identity()
    user = account_service.get_current_account(user_id)

    return jsonify(user), 200


@account_bp.patch("/account/me")
@jwt_required()
def update_current_account():
    user_id = get_jwt_identity()
    data = request.get_json() or {}

    user = account_service.update_current_account(
        user_id=user_id,
        name=data.get("name"),
        email=data.get("email"),
        profile_image_url=data.get("profile_image_url"),
    )

    return jsonify(user), 200