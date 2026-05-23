from flask import Blueprint, request, jsonify
from app.services.facade.auth_facade import AuthFacade
from flask_jwt_extended import jwt_required, get_jwt_identity, create_access_token


# Blueprint for authentication-related routes (register, login, logout)
# No url_prefix here — routes are /api/v1/register, /api/v1/login (matches Flutter ApiConstants).
auth_bp = Blueprint("auth", __name__)

@auth_bp.post("/register")
def register():
    """
    Handle user registration.

    Expects JSON body with:
        - name
        - email
        - password
        - fcm_token (Optional: Used for Firebase welcome notifications)

    Returns:
        JSON response with result and HTTP status code.
    """
    data = request.get_json(silent=True) or {}
    # Validate required fields BEFORE passing to service layer
    if not data.get("email") or not data.get("password"):
        return jsonify({"error": "email and password are required"}), 400

    # Delegate the payload to the Facade to handle multiple operations seamlessly:
    # 1. Persist the new user in the database via auth_service.
    # 2. Dispatch the welcome push notification via notification_service.
    result, status_code = AuthFacade.register(data)

    return jsonify(result), status_code


@auth_bp.post("/login")
def login():
    """
    Handle user login.

    Expects JSON body with:
        - email
        - password
        - fcm_token (Optional: To update the device token on login)

    Returns:
        JSON response with JWT token if successful.
    """
    # this to safely get JSON body and default to empty dict if missing or invalid
    data = request.get_json(silent=True) or {}

    # Validate required fields BEFORE authentication logic
    if not data.get("email") or not data.get("password"):
        return jsonify({"error": "email and password are required"}), 400

    # Delegate the payload to the Facade to verify credentials
    # and update the user's FCM token in the database.
    result, status_code = AuthFacade.login(data)
    return jsonify(result), status_code

@auth_bp.post("/refresh")
@jwt_required(refresh=True)
def refresh():
    """
    Handle token refresh.
    Generates a new short-lived access token using a valid refresh token.
    """

    # Extract the identity dictionary (contains 'user_id' and 'role') from the refresh token.
    current_user_identity = get_jwt_identity()

    # Issue a fresh Access Token (valid for 30 mins) without requiring the user to login again.
    new_access_token = create_access_token(identity=current_user_identity)

    # Return the new token to the client (Flutter app) to continue their session.
    return jsonify({
        "access_token": new_access_token
    }), 200


@auth_bp.post("/logout")
@jwt_required()
def logout():
    """
    Handle user logout.
    Clears the FCM token from the database to prevent cross-account notifications.
    """
    # Extract the identity dictionary from the token.
    current_user_identity = get_jwt_identity()

    # Delegate business logic to Facade
    result, status_code = AuthFacade.logout(current_user_identity)

    return jsonify(result), status_code
