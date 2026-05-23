"""
Verification request API routes.

Responsibilities:
- Artists can submit verification requests
- Admins can:
    - view all requests
    - view a specific request
    - approve/reject requests

Architecture:
    Route -> Facade -> Service -> Repository
"""

from flask import Blueprint, jsonify, request
from flask_jwt_extended import (
    jwt_required,
    get_jwt_identity,
)

from app.services.facade.verification_request_facade import (
    VerificationRequestFacade,
)

# =========================================================
# Blueprint Registration
# =========================================================

verification_requests_bp = Blueprint(
    "verification_requests",
    __name__,
)


# =========================================================
# Request Helpers
# =========================================================

def _json_body():
    """
    Safely parse JSON request body.

    Returns empty dict if request body is invalid/missing.
    """

    return request.get_json(silent=True) or {}


def get_authenticated_user_id():
    """
    Extract authenticated user ID from JWT payload.
    """

    current_user_identity = get_jwt_identity()

    if isinstance(current_user_identity, dict):
        return current_user_identity.get("user_id")

    return current_user_identity


def get_authenticated_user_role():
    """
    Extract authenticated user role from JWT payload.
    """

    current_user_identity = get_jwt_identity()

    if isinstance(current_user_identity, dict):
        return (
            current_user_identity.get("role")
            or current_user_identity.get("system_role")
        )

    return None


def require_admin():
    """
    Restrict route access to admin users only.
    """

    role = get_authenticated_user_role()

    if role != "admin":
        return jsonify(
            {"error": "Admin access required"}
        ), 403

    return None


# =========================================================
# Artist Routes
# =========================================================

@verification_requests_bp.post("/verification-requests")
@jwt_required()
def create_verification_request():
    """
    Create verification request for authenticated artist.
    """

    user_id = get_authenticated_user_id()

    data = _json_body()

    result, status_code = (
        VerificationRequestFacade.create_request(
            user_id=user_id,
            data=data,
        )
    )

    return jsonify(result), status_code


# =========================================================
# Admin Routes
# =========================================================

@verification_requests_bp.get("/verification-requests")
@jwt_required()
def get_all_verification_requests():
    """
    Return all verification requests.

    Admin only.
    """

    admin_error = require_admin()

    if admin_error:
        return admin_error

    result, status_code = (
        VerificationRequestFacade.get_all_requests()
    )

    return jsonify(result), status_code


@verification_requests_bp.get(
    "/verification-requests/<request_id>"
)
@jwt_required()
def get_verification_request(request_id):
    """
    Return single verification request by ID.

    Admin only.
    """

    admin_error = require_admin()

    if admin_error:
        return admin_error

    result, status_code = (
        VerificationRequestFacade.get_request_by_id(
            request_id,
        )
    )

    return jsonify(result), status_code


@verification_requests_bp.patch(
    "/verification-requests/<request_id>/status"
)
@jwt_required()
def update_verification_request_status(request_id):
    """
    Update verification request status.

    Allowed statuses:
    - pending
    - approved
    - rejected

    Admin only.
    """

    admin_error = require_admin()

    if admin_error:
        return admin_error

    data = _json_body()

    status = data.get("status")

    if not status:
        return jsonify(
            {"error": "status is required"}
        ), 400

    result, status_code = (
        VerificationRequestFacade.update_request_status(
            request_id,
            status,
        )
    )

    return jsonify(result), status_code