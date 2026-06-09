from flask import Blueprint, jsonify
from flask_jwt_extended import jwt_required

from app.core.auth_utils import get_authenticated_user_role
from app.services.facade.admin_dashboard_facade import AdminDashboardFacade


admin_dashboard_bp = Blueprint("admin_dashboard", __name__)


@admin_dashboard_bp.get("/dashboard/stats")
@jwt_required()
def get_dashboard_stats():
    role = get_authenticated_user_role()

    if role != "admin":
        return jsonify({"error": "Admin access required"}), 403

    result, status_code = AdminDashboardFacade.get_stats()

    return jsonify(result), status_code