"""
Order repository.

Handles ORM persistence for Order and OrderItem models.
"""

from app.extensions import db
from app.models.artwork import Artwork
from app.models.order import Order
from app.models.order_item import OrderItem
from app.models.user import User
from app.persistence.repository import SQLAlchemyRepository


class OrderRepository(SQLAlchemyRepository):
    def __init__(self):
        super().__init__(Order)

    def create_order(
        self,
        buyer_id,
        subtotal,
        shipping_fee,
        total_amount,
        status="pending",
    ):
        """Create and persist a new order."""
        order = Order(
            buyer_id=buyer_id,
            subtotal=subtotal,
            shipping_fee=shipping_fee,
            total_amount=total_amount,
            status=status,
        )
        return self.save(order)

    def create_order_item(
        self,
        order_id,
        artwork_id,
        quantity,
        price_at_purchase,
    ):
        """Create and persist a line item on an existing order."""
        order_item = OrderItem(
            order_id=order_id,
            artwork_id=artwork_id,
            quantity=quantity,
            price_at_purchase=price_at_purchase,
        )
        try:
            db.session.add(order_item)
            db.session.commit()
            return order_item
        except Exception as exc:
            db.session.rollback()
            raise exc

    def get_orders_by_buyer(self, buyer_id):
        """Return all orders for a buyer, newest first."""
        if not buyer_id:
            return []

        return (
            Order.query.filter_by(buyer_id=buyer_id)
            .order_by(Order.created_at.desc())
            .all()
        )

    def get_incoming_orders_by_artist(self, artist_profile_id):
        """
        Return distinct orders containing artworks owned by the artist.
        """
        if not artist_profile_id:
            return []

        return (
            db.session.query(Order)
            .join(OrderItem, OrderItem.order_id == Order.id)
            .join(Artwork, OrderItem.artwork_id == Artwork.id)
            .filter(Artwork.artist_profile_id == artist_profile_id)
            .distinct()
            .order_by(Order.created_at.desc())
            .all()
        )

    def update_order_status(
        self,
        order_id,
        status,
        shipping_company=None,
        tracking_number=None,
    ):
        """Update shipment fields on an order and return the model."""
        order = db.session.get(Order, order_id)
        if not order:
            return None

        order.status = status
        if shipping_company is not None:
            order.shipping_company = shipping_company
        if tracking_number is not None:
            order.tracking_number = tracking_number

        return self.save(order)

    def get_buyer_notification_info(self, buyer_id):
        """
        Return the active buyer User for shipment notifications.

        Returns None when the buyer does not exist or is inactive.
        """
        if not buyer_id:
            return None

        user = db.session.get(User, buyer_id)
        if not user or not user.is_active:
            return None

        return user


order_repo = OrderRepository()
