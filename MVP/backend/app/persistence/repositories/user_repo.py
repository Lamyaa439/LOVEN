"""
User repository — persistence for LOVEN business user records.

Firebase Auth owns credentials; this repository stores ``firebase_uid``,
verification timestamps, and role data used after token exchange.
"""

from datetime import datetime, timezone

from app.extensions import db
from app.models.user import User
from app.persistence.repository import SQLAlchemyRepository


class UserRepository(SQLAlchemyRepository):
    """Database access for :class:`~app.models.user.User`."""

    def __init__(self):
        super().__init__(User)

    def get_user_by_email(self, email):
        """Fetch a user by normalized email address."""
        if not email:
            return None

        normalized_email = email.strip().lower()
        return self.model.query.filter_by(email=normalized_email).first()

    def get_by_firebase_uid(self, firebase_uid: str):
        """Fetch a user by Firebase Auth ``uid``."""
        if not firebase_uid:
            return None

        return self.model.query.filter_by(firebase_uid=firebase_uid).first()

    def create_firebase_user(
        self,
        *,
        firebase_uid: str,
        email: str,
        name: str,
        system_role: str = "customer",
        fcm_token: str | None = None,
        email_verified_at: datetime | None = None,
    ) -> User:
        """
        Persist a new Firebase-linked user without a local password.

        Caller is responsible for transaction commit and artist profile creation.
        """
        user = User(
            name=name,
            email=email,
            password=None,
            firebase_uid=firebase_uid,
            auth_provider="firebase",
            system_role=system_role,
            fcm_token=fcm_token,
            email_verified_at=email_verified_at,
        )
        db.session.add(user)
        db.session.flush()
        return user

    def sync_email_verified_from_firebase(
        self,
        user: User,
        email_verified: bool,
        *,
        commit: bool = True,
    ) -> User:
        """Update ``email_verified_at`` when Firebase reports a verified email."""
        if email_verified and user.email_verified_at is None:
            user.email_verified_at = datetime.now(timezone.utc)

        if commit:
            db.session.commit()
        else:
            db.session.flush()

        return user

    def link_firebase_uid(
        self,
        user: User,
        firebase_uid: str,
        *,
        email_verified: bool = False,
        commit: bool = True,
    ) -> User:
        """
        Attach a Firebase ``uid`` to an existing LOVEN user (legacy email match).

        Raises:
            ValueError: When the uid is already linked to another account, or this
                user is linked to a different Firebase uid.
        """
        if not firebase_uid:
            raise ValueError("firebase_uid is required")

        if user.firebase_uid and user.firebase_uid != firebase_uid:
            raise ValueError("User is already linked to a different Firebase account")

        existing_uid_owner = self.get_by_firebase_uid(firebase_uid)
        if existing_uid_owner and existing_uid_owner.id != user.id:
            raise ValueError("Firebase account is already linked to another user")

        user.firebase_uid = firebase_uid
        if not user.auth_provider or user.auth_provider in {"local", "legacy"}:
            user.auth_provider = "firebase"

        if email_verified and user.email_verified_at is None:
            user.email_verified_at = datetime.now(timezone.utc)

        if commit:
            db.session.commit()
        else:
            db.session.flush()

        return user

    def update_fcm_token(self, user_id, new_token):
        """Update the Firebase Cloud Messaging device token."""
        return self.update(user_id, {"fcm_token": new_token})

    def get_user_by_fcm_token(self, fcm_token):
        """Find a user by FCM device token."""
        return self.get_by_attribute("fcm_token", fcm_token)

    def get_user_by_id(self, user_id):
        """Fetch a user by primary key UUID."""
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

    def get_by_email(self, email: str):
        return User.query.filter_by(email=email).first()

    def create_google_user(self, email, name, firebase_uid, profile_picture=None):
        """Create a Google-linked user (future OAuth path). Password lives in Firebase."""
        user = User(
            email=email,
            name=name or email.split("@")[0],
            firebase_uid=firebase_uid,
            auth_provider="google",
            profile_image_url=profile_picture,
            password=None,
            system_role="customer",
        )
        db.session.add(user)
        db.session.commit()
        return user
    
    def update_role(self, user_id, system_role):
        user = self.get_by_id(user_id)
        
        if not user:
            return None
        
        user.system_role = system_role
        db.session.commit()
        
        return user
