"""
LOVEN user sync and JWT exchange after Firebase Authentication.

Firebase owns email/password credentials and verification. This module:
- Creates or updates the LOVEN ``User`` record on register-sync (**no JWT**).
- Issues LOVEN JWT only on login exchange when ``email_verified`` is true.
"""

from __future__ import annotations

import logging
from datetime import datetime, timezone

from sqlalchemy.exc import IntegrityError

from app.extensions import db
from app.persistence.repositories.artist_profile_repo import ArtistProfileRepository
from app.persistence.repositories.user_repo import UserRepository
from app.services.artists_profiles_service import prepare_registration_profile
from app.services.firebase_auth_service import FirebaseAuthError, firebase_auth_service
from app.services.notification_service import notification_service
from flask_jwt_extended import create_access_token, create_refresh_token

logger = logging.getLogger(__name__)

user_repo = UserRepository()
artist_profile_repo = ArtistProfileRepository()

ALLOWED_REGISTRATION_ROLES = frozenset({"customer", "artist"})


def _issue_loven_tokens(user) -> dict:
    """Build LOVEN access + refresh JWT pair for an authenticated user."""
    user_identity = str(user.id)
    access_token = create_access_token(
        identity=user_identity,
        additional_claims={"role": user.system_role},
    )
    refresh_token = create_refresh_token(identity=user_identity)
    return {
        "message": "Login successful",
        "access_token": access_token,
        "refresh_token": refresh_token,
    }


def register_sync(data: dict) -> tuple[dict, int]:
    """
    Create a LOVEN user from a verified Firebase ID token after client signup.

    Does **not** issue LOVEN JWT — verification is completed in Firebase first.
    """
    id_token = data.get("id_token")
    name = (data.get("name") or "").strip()
    role = (data.get("system_role") or "customer").lower()
    fcm_token = data.get("fcm_token")

    if not name:
        return {"error": "name is required"}, 400

    if role not in ALLOWED_REGISTRATION_ROLES:
        return {
            "error": (
                f"Invalid registration role. Allowed roles are: "
                f"{', '.join(sorted(ALLOWED_REGISTRATION_ROLES))}"
            )
        }, 400

    try:
        claims = firebase_auth_service.verify_id_token(id_token)
    except FirebaseAuthError as exc:
        return {"error": exc.message}, 401

    existing_uid_user = user_repo.get_by_firebase_uid(claims.firebase_uid)
    if existing_uid_user:
        return {"error": "User already exists"}, 409

    existing_email_user = user_repo.get_user_by_email(claims.email)
    if existing_email_user:
        if existing_email_user.firebase_uid:
            return {"error": "User already exists"}, 409

        try:
            user_repo.link_firebase_uid(
                existing_email_user,
                claims.firebase_uid,
                email_verified=claims.email_verified,
                commit=False,
            )
            if fcm_token:
                existing_email_user.fcm_token = fcm_token
            db.session.commit()
            return {
                "message": "Account linked. Please verify your email.",
                "email": claims.email,
                "verification_required": not claims.email_verified,
                "user_id": str(existing_email_user.id),
            }, 200
        except ValueError as exc:
            db.session.rollback()
            return {"error": str(exc)}, 409
        except IntegrityError:
            db.session.rollback()
            return {"error": "Registration failed due to a duplicate value"}, 409
        except Exception:
            logger.exception("Firebase register-sync legacy link failed")
            db.session.rollback()
            return {"error": "An internal error occurred during registration"}, 500

    email_verified_at = (
        datetime.now(timezone.utc) if claims.email_verified else None
    )

    try:
        new_user = user_repo.create_firebase_user(
            firebase_uid=claims.firebase_uid,
            email=claims.email,
            name=name,
            system_role=role,
            fcm_token=fcm_token,
            email_verified_at=email_verified_at,
        )

        if not artist_profile_repo.get_active_by_user_id(new_user.id):
            profile = prepare_registration_profile(
                new_user.id,
                {"name": name, "email": claims.email},
            )
            db.session.add(profile)

        db.session.commit()

        try:
            notification_service.notify_welcome(new_user)
        except Exception:
            logger.exception(
                "Welcome notification failed for user_id=%s (non-fatal)",
                new_user.id,
            )

        return {
            "message": "Account created. Please verify your email.",
            "email": claims.email,
            "verification_required": True,
            "user_id": str(new_user.id),
        }, 201

    except ValueError as exc:
        db.session.rollback()
        return {"error": str(exc)}, 400
    except IntegrityError:
        db.session.rollback()
        return {"error": "Registration failed due to a duplicate value"}, 409
    except Exception:
        logger.exception("Firebase register-sync failed")
        db.session.rollback()
        return {"error": "An internal error occurred during registration"}, 500


def login_exchange(data: dict) -> tuple[dict, int]:
    """
    Exchange a verified Firebase ID token for LOVEN JWT session credentials.

    Rejects unverified Firebase accounts with ``403 email_not_verified``.
    """
    id_token = data.get("id_token")
    fcm_token = data.get("fcm_token")

    try:
        claims = firebase_auth_service.verify_id_token(id_token)
    except FirebaseAuthError as exc:
        return {"error": exc.message}, 401

    if not claims.email_verified:
        return {
            "error": "email_not_verified",
            "message": "Please verify your email before signing in.",
        }, 403

    user = user_repo.get_by_firebase_uid(claims.firebase_uid)

    if not user:
        user = user_repo.get_user_by_email(claims.email)
        if user:
            try:
                user = user_repo.link_firebase_uid(
                    user,
                    claims.firebase_uid,
                    email_verified=claims.email_verified,
                    commit=False,
                )
            except ValueError as exc:
                db.session.rollback()
                return {"error": str(exc)}, 409
            except IntegrityError:
                db.session.rollback()
                return {"error": "Login failed due to a duplicate value"}, 409
        else:
            return {
                "error": "User not found",
                "message": "Complete registration sync before signing in.",
            }, 404

    if not user.is_active:
        return {"error": "Account is inactive"}, 403

    user_repo.sync_email_verified_from_firebase(
        user,
        claims.email_verified,
        commit=False,
    )

    if fcm_token:
        user.fcm_token = fcm_token

    try:
        db.session.commit()
    except IntegrityError:
        db.session.rollback()
        return {"error": "Login failed due to a duplicate value"}, 409

    return _issue_loven_tokens(user), 200
