from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required

from app.core.auth_utils import get_authenticated_user_id
from app.services.facade.admin_user_facade import AdminUserFacade


admin_users_bp = Blueprint("admin_users", __name__)


@admin_users_bp.get("/users")
@jwt_required()
def list_users():
    admin_user_id = get_authenticated_user_id()

    limit = request.args.get("limit", default=50, type=int)
    offset = request.args.get("offset", default=0, type=int)

    result, status_code = AdminUserFacade.list_users(
        admin_user_id=admin_user_id,
        limit=limit,
        offset=offset,
    )

    return jsonify(result), status_code


@admin_users_bp.patch("/users/<user_id>/status")
@jwt_required()
def update_user_active_status(user_id):
    admin_user_id = get_authenticated_user_id()
    data = request.get_json() or {}

    result, status_code = AdminUserFacade.update_user_active_status(
        admin_user_id=admin_user_id,
        target_user_id=user_id,
        is_active=data.get("is_active"),
    )

    return jsonify(result), status_code