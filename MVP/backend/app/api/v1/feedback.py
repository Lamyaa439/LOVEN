from flask import Blueprint, request, jsonify
from flask_jwt_extended import (
    jwt_required,
    get_jwt_identity,
)

from app.services.facade.feedback_facade import (
    FeedbackFacade,
)


feedback_bp = Blueprint("feedback", __name__)


def get_authenticated_user_id():

    current_user_identity = get_jwt_identity()

    # The project currently supports multiple JWT identity
    # structures, so both formats are handled safely.
    if isinstance(current_user_identity, dict):
        return current_user_identity.get("user_id")

    return current_user_identity


@feedback_bp.post("/")
@jwt_required()
def create_feedback():

    data = request.get_json() or {}

    # The authenticated user is always taken from the JWT.
    # This prevents users from submitting feedback under
    # another account by modifying request payloads.
    data["user_id"] = get_authenticated_user_id()

    result, status_code = (
        FeedbackFacade.create_feedback(data)
    )

    return jsonify(result), status_code