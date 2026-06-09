from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required
from app.core.auth_utils import get_authenticated_user_role
from app.core.auth_utils import get_authenticated_user_id

from app.services.facade.report_facade import (
    ReportFacade,
)


report_bp = Blueprint("reports", __name__)


@report_bp.post("/")
@jwt_required()
def create_report():

    data = request.get_json() or {}

    # Reporter identity is always derived from the active
    # authenticated session instead of client input.
    #
    # This prevents users from impersonating another account
    # while submitting moderation reports.
    data["reporter_id"] = (
        get_authenticated_user_id()
    )

    result, status_code = (
        ReportFacade.create_report(data)
    )

    return jsonify(result), status_code

@report_bp.get("/")
@jwt_required()
def get_reports():
    role = get_authenticated_user_role()

    if role != "admin":
        return jsonify({"error": "Admin access required"}), 403

    result, status_code = ReportFacade.get_all_reports()

    return jsonify(result), status_code

@report_bp.patch("/<report_id>/status")
@jwt_required()
def update_report_status(report_id):
    role = get_authenticated_user_role()

    if role != "admin":
        return jsonify({"error": "Admin access required"}), 403

    data = request.get_json() or {}
    status = data.get("status")

    result, status_code = ReportFacade.update_report_status(
        report_id,
        status,
    )

    return jsonify(result), status_code