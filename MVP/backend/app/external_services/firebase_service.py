"""
Firebase Integration Service.
Handles Cloud Messaging (FCM) for notifications and Cloud Storage (FCS)
for media management.

Firebase is initialized lazily on first use so the API can start even when
credentials are missing (e.g. local dev without firebaseKey.json).
"""

import firebase_admin
from firebase_admin import credentials, messaging, storage
import logging
import os
from firebase_admin import auth

logger = logging.getLogger(__name__)


# Configuration: Use environment variables for security with local fallbacks
SERVICE_ACCOUNT_KEY = os.getenv("FIREBASE_CREDENTIALS_PATH", "/app/firebaseKey.json")
STORAGE_BUCKET_NAME = os.getenv("FIREBASE_STORAGE_BUCKET", "loven-88b0a.appspot.com")


def initialize_firebase() -> bool:
    """
    Initialize the Firebase Admin SDK singleton when credentials are available.

    Returns True when Firebase is ready, False when credentials are missing
    or initialization fails. Safe to call repeatedly.
    """
    if firebase_admin._apps:
        return True

    if not os.path.exists(SERVICE_ACCOUNT_KEY):
        logger.warning(
            "Firebase credentials not found at %s. "
            "FCM and Storage features are disabled.",
            SERVICE_ACCOUNT_KEY,
        )
        return False

    try:
        cred = credentials.Certificate(SERVICE_ACCOUNT_KEY)
        firebase_admin.initialize_app(
            cred,
            {"storageBucket": STORAGE_BUCKET_NAME},
        )
        logger.info("Firebase SDK initialized (FCM + Storage).")
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

def send_welcome_notification(fcm_token: str, user_name: str) -> bool:
    """
    Dispatches a personalized welcome push notification to new users.

    Args:
        fcm_token (str): The FCM device token provided by the frontend.
        user_name (str): The user's name for personalizing the message.

    Returns:
        bool: True if the notification was sent successfully, False otherwise.
    """
    if not fcm_token:
        logger.warning("No token provided. Skipping welcome notification.")
        return False

    if not _ensure_firebase():
        logger.warning("Firebase unavailable. Skipping welcome notification.")
        return False

    message = messaging.Message(
        notification=messaging.Notification(
            title="Welcome to LOVEN! 🎨 ",
            body=f"Hi {user_name}, we're happy you're here!!",
        ),
        data={
            "type": "welcome_alert",
            "action": "open_home_screen",
        },
        token=fcm_token,
    )

    try:
        message_id = messaging.send(message)
        logger.info("Welcome notification sent. ID: %s", message_id)
        return True
    except Exception as exc:
        logger.error("FCM welcome notification failed: %s", exc)
        return False


def send_order_status_notification(
    fcm_token: str,
    user_name: str,
    order_id: str,
    status: str,
) -> bool:
    """
    Sends an order status update push notification to the user.

    Args:
        fcm_token (str): The user's FCM device token.
        user_name (str): The user's name.
        order_id (str): The order ID.
        status (str): The updated order status.

    Returns:
        bool: True if sent successfully, False otherwise.
    """
    if not fcm_token:
        logger.warning("No token provided. Skipping order notification.")
        return False

    if not _ensure_firebase():
        logger.warning("Firebase unavailable. Skipping order notification.")
        return False

    message = messaging.Message(
        notification=messaging.Notification(
            title="Order Update from LOVEN 🎨",
            body=f"Hi {user_name}, your order #{order_id} is now {status}.",
        ),
        data={
            "type": "order_status_update",
            "action": "open_order_details",
            "order_id": str(order_id),
            "status": status,
        },
        token=fcm_token,
    )

    try:
        message_id = messaging.send(message)
        logger.info("Order notification sent. ID: %s", message_id)
        return True
    except Exception as exc:
        logger.error("FCM order notification failed: %s", exc)
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

def verify_firebase_token(id_token: str) -> dict:
    if not _ensure_firebase():
        raise ValueError("Firebase unavailable")

    try:
        decoded_token = auth.verify_id_token(id_token)
        return decoded_token
    except Exception:
        raise ValueError("Invalid Firebase token")