"""
Order repository.

Handles ORM persistence for Order and OrderItem models.
"""

from decimal import Decimal, InvalidOperation

from app.extensions import db
from app.models.artwork import Artwork
from app.models.order import Order
from app.models.order_item import OrderItem
from app.models.user import User
from app.persistence.repository import SQLAlchemyRepository


def _quantize_money(value) -> Decimal:
    """Normalize monetary values to two decimal places."""
    return Decimal(str(value)).quantize(Decimal("0.01"))


def _optional_expected_money(value):
    """Parse optional client-supplied totals for validation."""
    if value is None:
        return None
    try:
        return _quantize_money(value)
    except (InvalidOperation, TypeError, ValueError):
        raise ValueError("Invalid monetary amount in order totals") from None


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
        return self.save(order_item)

    def create_order_with_items(
        self,
        buyer_id,
        items,
        status="pending",
        *,
        expected_subtotal=None,
        expected_shipping_fee=None,
        expected_total_amount=None,
    ):
        """
        Create an order, its line items, and inventory updates atomically.

        Prices and totals are computed from artwork rows in the database.
        Client-supplied totals are validated when provided and never trusted
        for persistence.

        Raises ValueError when an artwork is unavailable, stock is insufficient,
        or client totals do not match server-computed amounts.
        """
        if not items:
            raise ValueError("Order must contain at least one item")

        expected_subtotal = _optional_expected_money(expected_subtotal)
        expected_shipping_fee = _optional_expected_money(expected_shipping_fee)
        expected_total_amount = _optional_expected_money(expected_total_amount)

        subtotal = Decimal("0.00")
        shipping_fee = Decimal("0.00")
        created_items = []

        try:
            order = Order(
                buyer_id=buyer_id,
                status=status,
            )
            db.session.add(order)
            db.session.flush()

            for item in items:
                artwork_id = item["artwork_id"]
                quantity = int(item["quantity"])

                if quantity < 1:
                    raise ValueError(
                        "Each item quantity must be at least 1"
                    )

                artwork = db.session.get(Artwork, artwork_id)
                if not artwork or artwork.deleted_at is not None:
                    raise ValueError(
                        f"Artwork not found: {artwork_id}"
                    )

                if artwork.status != "available":
                    raise ValueError(
                        f"Artwork is not available for purchase: {artwork_id}"
                    )

                if artwork.quantity_available < quantity:
                    raise ValueError(
                        "Insufficient quantity for artwork "
                        f"{artwork_id}"
                    )

                unit_price = _quantize_money(artwork.price)
                line_shipping = _quantize_money(artwork.shipping_fee)

                subtotal += unit_price * quantity
                shipping_fee += line_shipping

                order_item = OrderItem(
                    order_id=order.id,
                    artwork_id=artwork_id,
                    quantity=quantity,
                    price_at_purchase=unit_price,
                )
                db.session.add(order_item)
                created_items.append(order_item)

                artwork.quantity_available -= quantity
                if artwork.quantity_available <= 0:
                    artwork.quantity_available = 0
                    artwork.status = "sold_out"

            subtotal = _quantize_money(subtotal)
            shipping_fee = _quantize_money(shipping_fee)
            total_amount = _quantize_money(subtotal + shipping_fee)

            if (
                expected_subtotal is not None
                and expected_subtotal != subtotal
            ):
                raise ValueError(
                    "Order subtotal does not match server pricing"
                )

            if (
                expected_shipping_fee is not None
                and expected_shipping_fee != shipping_fee
            ):
                raise ValueError(
                    "Order shipping fee does not match server pricing"
                )

            if (
                expected_total_amount is not None
                and expected_total_amount != total_amount
            ):
                raise ValueError(
                    "Order total does not match server pricing"
                )

            order.subtotal = subtotal
            order.shipping_fee = shipping_fee
            order.total_amount = total_amount

            db.session.commit()
            return order, created_items
        except Exception:
            db.session.rollback()
            raise

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
