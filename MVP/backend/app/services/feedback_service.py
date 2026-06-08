import logging

from app.persistence.repositories.feedback_repo import feedback_repo
from app.persistence.repositories.user_repo import UserRepository
from app.services.notification_service import notification_service


logger = logging.getLogger(__name__)
user_repo = UserRepository()

# =========================================================
# Feedback Service
# =========================================================
# The service layer is responsible for validating incoming
# feedback before any database interaction occurs.
#
# This keeps business rules separated from SQL operations.
# =========================================================


def submit_feedback(data):

    user_id = data.get("user_id")
    subject = data.get("subject")
    message = data.get("message")

    # Feedback must always belong to an authenticated user.
    # The user identity is injected from JWT authentication,
    # not trusted from frontend input.
    if not user_id:
        return {"error": "user_id is required"}, 400

    # The message is the core content of the feedback record.
    # Subject remains optional according to the schema.
    if not message:
        return {"error": "message is required"}, 400

    feedback = feedback_repo.create_feedback(
        user_id=user_id,
        subject=subject,
        message=message,
    )

    try:
        user = user_repo.get_by_id(user_id)
        if user:
            notification_service.notify_feedback_submitted(user, feedback)
    except Exception:
        logger.exception(
            "Feedback confirmation notification failed (non-fatal) "
            "for user_id=%s feedback_id=%s",
            user_id,
            feedback.id,
        )

    return {
        "message": "Feedback submitted successfully",
        "feedback": feedback.to_dict(),
    }, 201
