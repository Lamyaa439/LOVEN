from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required

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