"""
Feedback repository.

Handles ORM persistence for Feedback records.
"""

from app.models.feedback import Feedback
from app.persistence.repository import SQLAlchemyRepository


class FeedbackRepository(SQLAlchemyRepository):
    def __init__(self):
        super().__init__(Feedback)

    def create_feedback(self, user_id, subject, message):
        """Create and persist a feedback record."""
        feedback = Feedback(
            user_id=user_id,
            subject=subject,
            message=message,
        )
        return self.save(feedback)


feedback_repo = FeedbackRepository()
