"""
Notification repository.

Handles ORM persistence for in-app Notification records.
"""

from sqlalchemy import update

from app.models.notification import Notification
from app.persistence.repository import SQLAlchemyRepository


class NotificationRepository(SQLAlchemyRepository):
    def __init__(self):
        super().__init__(Notification)

    def create_notification(
        self,
        user_id,
        type,
        title,
        body,
        reference_id=None,
        reference_type=None,
    ):
        """Create and persist a notification for a user."""
        notification = Notification(
            user_id=user_id,
            type=type,
            title=title,
            body=body,
            reference_id=reference_id,
            reference_type=reference_type,
        )
        return self.save(notification)

    def list_for_user(self, user_id, limit=20, offset=0, unread_only=False):
        """
        Return notifications for a user, newest first.

        Supports paginated in-app feeds and optional unread-only filtering.
        """
        query = self.model.query.filter(self.model.user_id == user_id)

        if unread_only:
            query = query.filter(self.model.is_read.is_(False))

        return (
            query
            .order_by(self.model.created_at.desc())
            .offset(offset)
            .limit(limit)
            .all()
        )

    def count_unread(self, user_id):
        """Return the number of unread notifications for a user."""
        return (
            self.model.query
            .filter(self.model.user_id == user_id)
            .filter(self.model.is_read.is_(False))
            .count()
        )

    def mark_read(self, notification_id, user_id):
        """
        Mark one notification as read for the owning user.

        Returns the updated notification, or None if not found or not owned
        by the given user.
        """
        notification = (
            self.model.query
            .filter(self.model.id == notification_id)
            .filter(self.model.user_id == user_id)
            .first()
        )
        if not notification:
            return None

        if not notification.is_read:
            notification.is_read = True
            return self.save(notification)

        return notification

    def mark_all_read(self, user_id):
        """Mark every unread notification as read for a user."""
        statement = (
            update(Notification)
            .where(Notification.user_id == user_id)
            .where(Notification.is_read.is_(False))
            .values(is_read=True)
        )
        result = self.execute_and_commit(statement)
        return result.rowcount


notification_repo = NotificationRepository()
