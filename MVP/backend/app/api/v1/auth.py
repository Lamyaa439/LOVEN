"""
Authentication HTTP routes.

Firebase Auth owns email/password credentials. LOVEN JWT is issued only via
``/auth/firebase/login`` after Firebase reports ``emailVerified == true``.

Legacy ``/register`` and ``/login`` (bcrypt + immediate JWT) return 410 Gone.
"""

from flask import Blueprint, jsonify, request
from flask_jwt_extended import create_access_token, get_jwt_identity, jwt_required

from app.core.auth_utils import get_authenticated_user_id
from app.services.facade.auth_facade import AuthFacade

auth_bp = Blueprint("auth", __name__)


@auth_bp.post("/auth/firebase/register-sync")
def firebase_register_sync():
    """
    Create/sync LOVEN user after Firebase client signup.

    Expects JSON: id_token, name, system_role (optional), fcm_token (optional).
    Does **not** return LOVEN JWT.
    """
    data = request.get_json(silent=True) or {}

    if not data.get("id_token"):
        return jsonify({"error": "id_token is required"}), 400
    if not data.get("name"):
        return jsonify({"error": "name is required"}), 400

    result, status_code = AuthFacade.register_firebase_sync(data)
    return jsonify(result), status_code


@auth_bp.post("/auth/firebase/login")
def firebase_login():
    """
    Exchange verified Firebase ID token for LOVEN JWT.

    Expects JSON: id_token, fcm_token (optional).
    Returns 403 when Firebase email is not verified.
    """
    data = request.get_json(silent=True) or {}

    if not data.get("id_token"):
        return jsonify({"error": "id_token is required"}), 400

    result, status_code = AuthFacade.login_firebase(data)
    return jsonify(result), status_code


@auth_bp.post("/register")
def register():
    """
    Deprecated — use ``POST /api/v1/auth/firebase/register-sync``.
    """
    data = request.get_json(silent=True) or {}
    result, status_code = AuthFacade.register(data)
    return jsonify(result), status_code


@auth_bp.post("/login")
def login():
    """
    Deprecated — use ``POST /api/v1/auth/firebase/login``.
    """
    data = request.get_json(silent=True) or {}
    result, status_code = AuthFacade.login(data)
    return jsonify(result), status_code


@auth_bp.post("/refresh")
@jwt_required(refresh=True)
def refresh():
    """Issue a new access token from a valid refresh token."""
    current_user_identity = get_jwt_identity()
    new_access_token = create_access_token(identity=current_user_identity)

    return jsonify({"access_token": new_access_token}), 200


@auth_bp.post("/logout")
@jwt_required()
def logout():
    """Clear FCM token for the authenticated device."""
    user_id = get_authenticated_user_id()
    if not user_id:
        return jsonify({"error": "Invalid user identity"}), 401

    result, status_code = AuthFacade.logout(user_id)
    return jsonify(result), status_code


@auth_bp.patch("/change-password")
@jwt_required()
def change_password_route():
    """Authenticated password change (legacy local password — migrate to Firebase)."""
    current_user_id = get_jwt_identity()
    data = request.get_json(silent=True) or {}

    result, status_code = AuthFacade.change_password(current_user_id, data)
    return jsonify(result), status_code


@auth_bp.post("/google")
def google_login():
    """Google OAuth — out of scope for email/password Firebase auth."""
    data = request.get_json(silent=True) or {}
    id_token = data.get("id_token")

    if not id_token:
        return jsonify({"error": "id_token is required"}), 400

    return jsonify({"error": "Google login is not available yet"}), 501
