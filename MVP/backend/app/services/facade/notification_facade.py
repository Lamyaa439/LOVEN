"""
Notification facade.

Thin orchestration layer for notifications API flows.

Routes call this facade. Inbox operations delegate to
NotificationRepository; event-driven creation remains in
NotificationService.
"""

from app.core.uuid_utils import as_uuid
from app.persistence.repositories.notification_repo import notification_repo


class NotificationFacade:
    """
    Entry point for notifications routes.

    Every method returns:
        tuple: (response dict, HTTP status code)
    """

    @staticmethod
    def list_for_user(user_id, limit=20, offset=0, unread_only=False):
        user_uuid = as_uuid(user_id)
        notifications = notification_repo.list_for_user(
            user_id=user_uuid,
            limit=limit,
            offset=offset,
            unread_only=unread_only,
        )
        total_count = notification_repo.count_for_user(
            user_id=user_uuid,
            unread_only=unread_only,
        )

        return {
            "notifications": [
                notification.to_dict()
                for notification in notifications
            ],
            "count": len(notifications),
            "total_count": total_count,
            "limit": limit,
            "offset": offset,
        }, 200

    @staticmethod
    def unread_count(user_id):
        unread_count = notification_repo.count_unread(as_uuid(user_id))

        return {
            "unread_count": unread_count,
        }, 200

    @staticmethod
    def mark_read(user_id, notification_id):
        notification = notification_repo.mark_read(
            notification_id=as_uuid(notification_id),
            user_id=as_uuid(user_id),
        )

        if not notification:
            return {"error": "Notification not found"}, 404

        return {
            "message": "Notification marked as read",
            "notification": notification.to_dict(),
        }, 200

    @staticmethod
    def mark_all_read(user_id):
        updated_count = notification_repo.mark_all_read(as_uuid(user_id))

        return {
            "message": "All notifications marked as read",
            "updated_count": updated_count,
        }, 200
