import uuid
from sqlalchemy import text
from app.extensions import db

# =========================================================
# Repository: Order Repository
# Description:
# Handles all database operations related to:
# - orders
# - order_items
#
# Responsibilities:
# - Create customer orders
# - Create order items
# - Retrieve buyer orders
# - Retrieve incoming artist orders
# - Update shipment/order status
#
# Architecture Notes:
# - Uses SQLAlchemy session management
# - Uses raw SQL via sqlalchemy.text()
# - Keeps SQL isolated from service layer
# =========================================================


# =========================================================
# Create Order
# =========================================================
def create_order(
    buyer_id,
    subtotal,
    shipping_fee,
    total_amount,
    status="pending",
):
    """
    Create a new order.

    Args:
        buyer_id (UUID): Buyer user ID.
        subtotal (float): Order subtotal.
        shipping_fee (float): Shipping cost.
        total_amount (float): Final order total.
        status (str): Initial order status.

    Returns:
        Row: Newly created order row.
    """

    # Generate unique order ID
    order_id = str(uuid.uuid4())

    # Raw SQL insert query
    query = text("""
        INSERT INTO orders (
            id,
            buyer_id,
            subtotal,
            shipping_fee,
            total_amount,
            status
        )
        VALUES (
            :id,
            :buyer_id,
            :subtotal,
            :shipping_fee,
            :total_amount,
            :status
        )
        RETURNING
            id,
            buyer_id,
            subtotal,
            shipping_fee,
            total_amount,
            status,
            created_at
    """)

    # Execute query
    result = db.session.execute(query, {
        "id": order_id,
        "buyer_id": buyer_id,
        "subtotal": subtotal,
        "shipping_fee": shipping_fee,
        "total_amount": total_amount,
        "status": status,
    })

    # Commit transaction
    db.session.commit()

    # Return inserted row
    return result.fetchone()


# =========================================================
# Create Order Item
# =========================================================
def create_order_item(
    order_id,
    artwork_id,
    quantity,
    price_at_purchase,
):
    """
    Create a new order item.

    Args:
        order_id (UUID): Parent order ID.
        artwork_id (UUID): Purchased artwork ID.
        quantity (int): Quantity purchased.
        price_at_purchase (float): Locked purchase price.

    Returns:
        Row: Newly created order item row.
    """

    # Generate unique order item ID
    order_item_id = str(uuid.uuid4())

    # Raw SQL insert query
    query = text("""
        INSERT INTO order_items (
            id,
            order_id,
            artwork_id,
            quantity,
            price_at_purchase
        )
        VALUES (
            :id,
            :order_id,
            :artwork_id,
            :quantity,
            :price_at_purchase
        )
        RETURNING
            id,
            order_id,
            artwork_id,
            quantity,
            price_at_purchase
    """)

    # Execute query
    result = db.session.execute(query, {
        "id": order_item_id,
        "order_id": order_id,
        "artwork_id": artwork_id,
        "quantity": quantity,
        "price_at_purchase": price_at_purchase,
    })

    # Commit transaction
    db.session.commit()

    # Return inserted row
    return result.fetchone()


# =========================================================
# Retrieve Buyer Orders
# =========================================================
def get_orders_by_buyer(buyer_id):
    """
    Retrieve all orders placed by a buyer.

    Args:
        buyer_id (UUID): Buyer user ID.

    Returns:
        list: Buyer orders ordered by newest first.
    """

    query = text("""
        SELECT
            id,
            buyer_id,
            subtotal,
            shipping_fee,
            total_amount,
            status,
            created_at
        FROM orders
        WHERE buyer_id = :buyer_id
        ORDER BY created_at DESC
    """)

    result = db.session.execute(query, {
        "buyer_id": buyer_id,
    })

    return result.fetchall()


# =========================================================
# Retrieve Artist Incoming Orders
# =========================================================
def get_incoming_orders_by_artist(artist_profile_id):
    """
    Retrieve all incoming orders for an artist.

    Logic:
    - Join orders with order_items
    - Join order_items with artworks
    - Filter artworks owned by artist

    Args:
        artist_profile_id (UUID): Artist profile ID.

    Returns:
        list: Incoming artist orders.
    """

    query = text("""
        SELECT DISTINCT
            o.id,
            o.buyer_id,
            o.subtotal,
            o.shipping_fee,
            o.total_amount,
            o.status,
            o.created_at
        FROM orders o
        JOIN order_items oi
            ON o.id = oi.order_id
        JOIN artworks a
            ON oi.artwork_id = a.id
        WHERE a.artist_profile_id = :artist_profile_id
        ORDER BY o.created_at DESC
    """)

    result = db.session.execute(query, {
        "artist_profile_id": artist_profile_id,
    })

    return result.fetchall()


# =========================================================
# Update Order Status
# =========================================================
def update_order_status(
    order_id,
    status,
    shipping_company=None,
    tracking_number=None,
):
    """
    Update order shipment and status information.

    Args:
        order_id (UUID): Order ID.
        status (str): New order status.
        shipping_company (str): Shipping provider.
        tracking_number (str): Shipment tracking number.

    Returns:
        Row: Updated order row.
    """

    query = text("""
        UPDATE orders
        SET
            status = :status,
            shipping_company = :shipping_company,
            tracking_number = :tracking_number,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = :order_id
        RETURNING
            id,
            buyer_id,
            subtotal,
            shipping_fee,
            total_amount,
            status,
            shipping_company,
            tracking_number,
            created_at
    """)

    result = db.session.execute(query, {
        "order_id": order_id,
        "status": status,
        "shipping_company": shipping_company,
        "tracking_number": tracking_number,
    })

    db.session.commit()

    return result.fetchone()

# =========================================================
# Get buyer notification info
# =========================================================

def get_buyer_notification_info(buyer_id):
    """
    Retrieve the buyer name and Firebase token used for
    shipment notifications.

    The order service uses this after an order is marked
    as shipped so the notification goes to the real buyer
    instead of using a hardcoded placeholder token.
    """

    query = text("""
        SELECT
            name,
            fcm_token
        FROM users
        WHERE id = :buyer_id
          AND is_active = true
    """)

    result = db.session.execute(query, {
        "buyer_id": buyer_id,
    })

    return result.fetchone()