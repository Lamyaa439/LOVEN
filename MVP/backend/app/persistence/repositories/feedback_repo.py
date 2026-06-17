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
    
    def list_feedback(self):
        """Return all feedback records newest first."""
        return (
            self.model.query
            .order_by(self.model.created_at.desc())
            .all()
        )


feedback_repo = FeedbackRepository()
