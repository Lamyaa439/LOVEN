from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required

from app.core.auth_utils import get_authenticated_user_id
from app.services.facade.notification_facade import NotificationFacade


notifications_bp = Blueprint("notifications", __name__)


def _unread_only_from_query():
    raw = request.args.get("unread_only", "false")
    return str(raw).strip().lower() in ("true", "1", "yes")


@notifications_bp.get("/")
@jwt_required()
def list_notifications():
    """
    Return the authenticated user's notifications and unread count.

    Query params:
        limit: max rows to return (default 20)
        offset: pagination offset (default 0)
        unread_only: true or false (default false)

    Response metadata:
        count: number of notifications in the current page
        total_count: total rows matching the current filters
        unread_count: global unread count for the user (not page-scoped)
    """
    user_id = get_authenticated_user_id()

    result, status_code = NotificationFacade.list_for_user(
        user_id=user_id,
        limit=request.args.get("limit", default=20, type=int),
        offset=request.args.get("offset", default=0, type=int),
        unread_only=_unread_only_from_query(),
    )

    unread_result, _ = NotificationFacade.unread_count(user_id)
    result["unread_count"] = unread_result["unread_count"]

    return jsonify(result), status_code


@notifications_bp.patch("/read-all")
@jwt_required()
def mark_all_notifications_read():
    user_id = get_authenticated_user_id()

    result, status_code = NotificationFacade.mark_all_read(user_id)

    return jsonify(result), status_code


@notifications_bp.patch("/<notification_id>/read")
@jwt_required()
def mark_notification_read(notification_id):
    user_id = get_authenticated_user_id()

    result, status_code = NotificationFacade.mark_read(
        user_id=user_id,
        notification_id=notification_id,
    )

    return jsonify(result), status_code
