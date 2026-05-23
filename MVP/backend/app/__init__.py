from flask import Flask
from flask_cors import CORS
from flask_jwt_extended import JWTManager

from app.api.v1.auth import auth_bp
from app.api.v1.artists_profiles import artist_profiles_bp
from app.api.v1.carts import carts_bp
from app.api.v1.orders import order_bp
from app.api.v1.artworks import artwork_bp
from app.api.v1.feedback import feedback_bp
from app.api.v1.reports import report_bp
from app.api.v1.favorites import favorites_bp
from app.extensions import db
from config import Config

# Global JWT instance
jwt = JWTManager()

def create_app():
    app = Flask(__name__)

    # Enable CORS for API routes
    CORS(
        app,
        resources={r"/api/*": {"origins": "http://localhost:57876"}},
        supports_credentials=True,
        allow_headers=["Content-Type", "Authorization"],
        methods=["GET", "POST", "PATCH", "DELETE", "OPTIONS"],
    )
    # Load application configuration
    app.config.from_object(Config)

    # Initialize database
    db.init_app(app)

    # Initialize JWT manager
    jwt.init_app(app)

    # Create database tables from SQLAlchemy models
    with app.app_context():
        from app.models.user import User
        from app.models.artist_profile import ArtistProfile
        from app.models.artwork import Artwork
        from app.models.cart import Cart
        from app.models.cart_item import CartItem
        from app.models.order import Order
        from app.models.order_item import OrderItem
        from app.models.feedback import Feedback
        from app.models.report import Report
        from app.models.favorites import Favorite

        db.create_all()

    @app.route("/")
    def home():
        """
        Health check route.
        """
        return {"message": "LOVEN on Air!"}

    # =========================================================
    # Register API Blueprints
    # =========================================================

    # Authentication routes
    app.register_blueprint(auth_bp, url_prefix="/api/v1")

    # Artist profile routes
    app.register_blueprint(artist_profiles_bp, url_prefix="/api/v1")
    
    # Shopping cart routes
    app.register_blueprint(carts_bp, url_prefix="/api/v1/carts")

    # Order management routes
    app.register_blueprint(order_bp, url_prefix="/api/v1/orders")

    # Artwork discovery routes
    app.register_blueprint(artwork_bp, url_prefix="/api/v1/artworks")
    
    # Feedback routes
    app.register_blueprint(feedback_bp, url_prefix="/api/v1/feedback")
    
    # Reports routes
    app.register_blueprint(report_bp, url_prefix="/api/v1/reports")

    # Favorites routes
    app.register_blueprint(favorites_bp, url_prefix="/api/v1/favorites")

    # Print all registered routes
    print(app.url_map)

    return app
