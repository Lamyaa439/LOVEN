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

    def _user_notifications_query(self, user_id, unread_only=False):
        """Base query for a user's notification feed."""
        query = self.model.query.filter(self.model.user_id == user_id)

        if unread_only:
            query = query.filter(self.model.is_read.is_(False))

        return query

    def count_for_user(self, user_id, unread_only=False):
        """
        Return total notifications matching the user's feed filters.

        When ``unread_only`` is true, counts only unread rows.
        """
        if not user_id:
            return 0

        return self._user_notifications_query(
            user_id,
            unread_only=unread_only,
        ).count()

    def list_for_user(self, user_id, limit=20, offset=0, unread_only=False):
        """
        Return notifications for a user, newest first.

        Supports paginated in-app feeds and optional unread-only filtering.
        """
        return (
            self._user_notifications_query(user_id, unread_only=unread_only)
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

    def find_order_status_notification(self, user_id, order_id, body_suffix):
        """
        Return an existing order_status row for the same user, order, and status.

        ``body_suffix`` is the stable trailing fragment of the notification body
        (e.g. ``"is now shipped."``) so different statuses remain distinct while
        repeated emissions of the same status dedupe without a schema change.
        """
        if not user_id or not order_id or not body_suffix:
            return None

        return (
            self.model.query
            .filter(self.model.user_id == user_id)
            .filter(self.model.type == "order_status")
            .filter(self.model.reference_id == order_id)
            .filter(self.model.reference_type == "order")
            .filter(self.model.body.endswith(body_suffix))
            .first()
        )


notification_repo = NotificationRepository()
