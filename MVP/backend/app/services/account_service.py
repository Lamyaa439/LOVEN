from app.persistence.repositories.user_repo import UserRepository


class AccountService:
    def __init__(self):
        self.user_repo = UserRepository()

    def get_current_account(self, user_id):
        user = self.user_repo.get_by_id(user_id)

        if not user:
            raise ValueError("User not found")

        return self._serialize_user(user)

    def update_current_account(
        self,
        user_id,
        name=None,
        email=None,
        profile_image_url=None,
    ):
        user = self.user_repo.update_account(
            user_id=user_id,
            name=name,
            email=email,
            profile_image_url=profile_image_url,
        )

        if not user:
            raise ValueError("User not found")

        return self._serialize_user(user)
    
    def delete_current_account(self, user_id):

        user = self.user_repo.get_by_id(user_id)
        if not user:
            raise ValueError("User not found")

        self.user_repo.delete(user_id)

    def _serialize_user(self, user):
        return {
            "id": str(user.id),
            "name": user.name,
            "email": user.email,
            "system_role": user.system_role,
            "profile_image_url": user.profile_image_url,
        }