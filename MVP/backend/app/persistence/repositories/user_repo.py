"""
User repository.

Handles database operations related to the User model.
"""
from app.persistence.repository import SQLAlchemyRepository
from app.models.user import User
from app.extensions import db


class UserRepository(SQLAlchemyRepository):
    def __init__(self):
        super().__init__(User)

    def get_user_by_email(self, email):
        """
        Fetch a user by their email address.
        """
        if not email:
            return None

        normalized_email = email.strip().lower()
        return self.model.query.filter_by(email=normalized_email).first()

    def update_fcm_token(self, user_id, new_token):
        """
        Updates the Firebase Cloud Messaging token for a specific user.
        """
        return self.update(user_id, {"fcm_token": new_token})

    def get_user_by_fcm_token(self, fcm_token):
        """
        Finds a user by their device token.
        """
        return self.get_by_attribute("fcm_token", fcm_token)

    def get_user_by_id(self, user_id):
        """
        Fetch a user by their unique ID.
        Useful for the Refresh Token logic.
        """
        return self.get(user_id)

    def get_by_id(self, user_id):
        return self.model.query.filter_by(id=user_id).first()

    def update_account(
        self,
        user_id,
        name=None,
        email=None,
        profile_image_url=None,
    ):
        user = self.get_by_id(user_id)

        if not user:
            return None

        if name is not None:
            user.name = name.strip()

        if email is not None:
            user.email = email.strip().lower()

        if profile_image_url is not None:
            user.profile_image_url = profile_image_url

        db.session.commit()

        return user