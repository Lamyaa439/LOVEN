"""
Scheduled notification jobs.

Job logic for delayed reminder notifications. Invoke from a CLI or external
cron runner — no scheduler is configured in this module.
"""

import logging
from datetime import datetime, timedelta, timezone

from sqlalchemy import func

from app.extensions import db
from app.models.cart import Cart
from app.models.cart_item import CartItem
from app.persistence.repositories.order_repo import order_repo
from app.persistence.repositories.user_repo import UserRepository
from app.services.notification_service import notification_service


logger = logging.getLogger(__name__)

REMINDER_WINDOW = timedelta(hours=24)

user_repo = UserRepository()


def _reminder_cutoff(now=None):
    """Return the UTC cutoff for 24h inactivity / awaiting-action checks."""
    current = now or datetime.now(timezone.utc)
    if current.tzinfo is None:
        current = current.replace(tzinfo=timezone.utc)
    return current - REMINDER_WINDOW


def _list_carts_needing_inactivity_reminder(cutoff_dt):
    """
    Return active carts whose most recent cart/item activity is on/before cutoff.

    Requires at least one active line item.
    """
    if not cutoff_dt:
        return []

    last_activity = func.greatest(
        Cart.updated_at,
        func.max(
            func.greatest(
                CartItem.updated_at,
                CartItem.created_at,
            )
        ),
    )

    return (
        db.session.query(Cart)
        .join(CartItem, CartItem.cart_id == Cart.id)
        .filter(Cart.deleted_at.is_(None))
        .filter(CartItem.deleted_at.is_(None))
        .group_by(Cart.id)
        .having(last_activity <= cutoff_dt)
        .all()
    )


def run_artist_order_reminders(now=None):
    """
    Notify artists about paid orders awaiting fulfillment for at least 24 hours.

    Uses NotificationService type ``artist_order_reminder`` (order reference).
    """
    cutoff_dt = _reminder_cutoff(now)
    orders = order_repo.list_orders_needing_artist_reminder(cutoff_dt)

    orders_processed = 0
    reminders_attempted = 0
    reminders_sent = 0

    for order in orders:
        orders_processed += 1
        artist_users = order_repo.get_artist_users_for_order(order.id)

        for artist_user in artist_users:
            reminders_attempted += 1
            try:
                notification = notification_service.notify_artist_order_reminder(
                    artist_user,
                    order,
                )
                if notification is not None:
                    reminders_sent += 1
            except Exception:
                logger.exception(
                    "Artist order reminder failed for order_id=%s user_id=%s",
                    order.id,
                    artist_user.id,
                )

    summary = {
        "orders_processed": orders_processed,
        "reminders_attempted": reminders_attempted,
        "reminders_sent": reminders_sent,
        "cutoff": cutoff_dt.isoformat(),
    }
    logger.info("Artist order reminder job finished: %s", summary)
    return summary


def run_cart_inactivity_reminders(now=None):
    """
    Notify users about carts with items inactive for at least 24 hours.

    Uses NotificationService type ``cart_inactivity`` (cart reference).
    """
    cutoff_dt = _reminder_cutoff(now)
    carts = _list_carts_needing_inactivity_reminder(cutoff_dt)

    carts_processed = 0
    reminders_attempted = 0
    reminders_sent = 0

    for cart in carts:
        carts_processed += 1
        user = user_repo.get_by_id(cart.user_id)
        if not user or not user.is_active:
            continue

        reminders_attempted += 1
        try:
            notification = notification_service.notify_cart_inactivity(user, cart)
            if notification is not None:
                reminders_sent += 1
        except Exception:
            logger.exception(
                "Cart inactivity reminder failed for cart_id=%s user_id=%s",
                cart.id,
                cart.user_id,
            )

    summary = {
        "carts_processed": carts_processed,
        "reminders_attempted": reminders_attempted,
        "reminders_sent": reminders_sent,
        "cutoff": cutoff_dt.isoformat(),
    }
    logger.info("Cart inactivity reminder job finished: %s", summary)
    return summary
