"""
Shared JWT identity helpers for API routes.
"""

from flask_jwt_extended import get_jwt, get_jwt_identity


def get_authenticated_user_id():
    """
    Extract the current user's ID from the JWT token.

    Supports both JWT identity formats used in the project:
    - sub as a direct UUID string
    - sub as a dictionary containing user_id
    """
    current_user_identity = get_jwt_identity()

    if isinstance(current_user_identity, dict):
        return current_user_identity.get("user_id")

    return current_user_identity


def get_authenticated_user_role():
    """Extract role from JWT claims."""
    claims = get_jwt()
    return claims.get("role") or claims.get("system_role")
