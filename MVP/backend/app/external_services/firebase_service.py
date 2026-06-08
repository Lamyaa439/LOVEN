"""
Firebase Integration Service.
Handles Cloud Messaging (FCM) for notifications and Cloud Storage (FCS)
for media management.

Firebase is initialized lazily on first use so the API can start even when
credentials are missing (e.g. local dev without firebaseKey.json).
"""

import json
import logging
import os

import firebase_admin
from firebase_admin import auth, credentials, messaging, storage

logger = logging.getLogger(__name__)


# Configuration: Use environment variables for security with local fallbacks
SERVICE_ACCOUNT_KEY = os.getenv("FIREBASE_CREDENTIALS_PATH", "/app/firebaseKey.json")
STORAGE_BUCKET_NAME = os.getenv("FIREBASE_STORAGE_BUCKET", "loven-88b0a.firebasestorage.app")


def initialize_firebase() -> bool:
    """
    Initialize the Firebase Admin SDK singleton when credentials are available.

    Supports:
    1. FIREBASE_SERVICE_ACCOUNT_JSON environment variable for Render.
    2. FIREBASE_CREDENTIALS_PATH file path for local Docker development.
    """
    if firebase_admin._apps:
        return True

    firebase_json = os.getenv("FIREBASE_SERVICE_ACCOUNT_JSON")
    firebase_json = firebase_json.strip() if firebase_json else None

    try:
        if firebase_json:
            service_account_info = json.loads(firebase_json)
            
            cred = credentials.Certificate(service_account_info)
            
            firebase_admin.initialize_app(
                cred,
                {"storageBucket": STORAGE_BUCKET_NAME},
            )
            
            logger.info("Firebase SDK initialized from environment variable.")
            return True

        if not os.path.exists(SERVICE_ACCOUNT_KEY):
            logger.warning(
                "Firebase credentials not found at %s. "
                "FCM and Storage features are disabled.",
                SERVICE_ACCOUNT_KEY,
            )
            return False

        cred = credentials.Certificate(SERVICE_ACCOUNT_KEY)
        firebase_admin.initialize_app(
            cred,
            {"storageBucket": STORAGE_BUCKET_NAME},
        )
        logger.info("Firebase SDK initialized from credentials file.")
        return True

    except Exception as exc:
        logger.error("Firebase initialization failed: %s", exc)
        return False


def _ensure_firebase() -> bool:
    """Return True when Firebase is initialized and ready for use."""
    return initialize_firebase()


# ==========================================
# 1. Cloud Messaging (Notifications)
# ==========================================

def send_push_notification(
    fcm_token: str,
    *,
    title: str,
    body: str,
    data: dict | None = None,
) -> bool:
    """
    Canonical FCM transport for all app push notifications.

    Callers (typically NotificationService) own business copy and payload
    keys; this function only initializes Firebase, stringifies data values,
    and sends the message. Failures are logged and return False — never raised.
    """
    if not fcm_token:
        logger.debug("No FCM token; skipping push notification.")
        return False

    if not _ensure_firebase():
        logger.warning("Firebase unavailable; skipping push notification.")
        return False

    payload = {
        key: str(value)
        for key, value in (data or {}).items()
        if value is not None
    }

    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        data=payload,
        token=fcm_token,
    )

    try:
        message_id = messaging.send(message)
        logger.info("Push notification sent. ID: %s", message_id)
        return True
    except Exception as exc:
        logger.warning("Push notification failed (non-fatal): %s", exc)
        return False


# ==========================================
# 2. Cloud Storage (Media Management)
# ==========================================

def delete_cloud_file(file_path: str) -> bool:
    """
    Removes a physical file from the cloud bucket to prevent orphaned storage.

    Args:
        file_path: The specific path/name of the file in the bucket.
    """
    if not file_path:
        return False

    if not _ensure_firebase():
        logger.warning(
            "Firebase unavailable. Skipping cloud file deletion for %s.",
            file_path,
        )
        return False

    try:
        bucket = storage.bucket()
        blob = bucket.blob(file_path)

        if blob.exists():
            blob.delete()
            logger.info("Deleted cloud file: %s", file_path)
            return True
        return False
    except Exception as exc:
        logger.error("Cloud file deletion failed for %s: %s", file_path, exc)
        return False
    
# ==========================================
# 3. Firebase token verification
# ==========================================

def verify_firebase_id_token(id_token: str) -> dict:
    """
    Verify a Firebase Auth ID token via the Admin SDK.

    Returns the decoded token claims dict (uid, email, email_verified, …).
    Used by ``firebase_auth_service`` for LOVEN JWT exchange — not for FCM.
    """
    if not _ensure_firebase():
        raise ValueError("Firebase unavailable")

    try:
        return auth.verify_id_token(id_token)
    except Exception as exc:
        raise ValueError("Invalid Firebase token") from exc


def verify_firebase_token(id_token: str) -> dict:
    """Backward-compatible alias for :func:`verify_firebase_id_token`."""
    return verify_firebase_id_token(id_token)