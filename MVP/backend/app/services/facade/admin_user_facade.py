from app.services import admin_user_service


class AdminUserFacade:

    @staticmethod
    def list_users(admin_user_id, limit=50, offset=0):
        return admin_user_service.list_users(
            admin_user_id=admin_user_id,
            limit=limit,
            offset=offset,
        )

    @staticmethod
    def update_user_active_status(
        admin_user_id,
        target_user_id,
        is_active,
    ):
        return admin_user_service.update_user_active_status(
            admin_user_id=admin_user_id,
            target_user_id=target_user_id,
            is_active=is_active,
        )