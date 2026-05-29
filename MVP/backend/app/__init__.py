from flask import Flask, jsonify
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from werkzeug.exceptions import HTTPException
import logging

from app.extensions import db
from config import Config

# import Blueprints
from app.api.v1.verification_requests import verification_requests_bp
from app.api.v1.auth import auth_bp
from app.api.v1.artists_profiles import artist_profiles_bp
from app.api.v1.carts import carts_bp
from app.api.v1.orders import order_bp
from app.api.v1.artworks import artwork_bp
from app.api.v1.feedback import feedback_bp
from app.api.v1.reports import report_bp
from app.api.v1.favorites import favorites_bp
from app.api.v1.payments import payments_bp
from flask_migrate import Migrate

# Global JWT instance
jwt = JWTManager()

logger = logging.getLogger(__name__)


def _configure_logging(app):
    """Configure application-wide logging when no handlers exist yet."""
    if logging.getLogger().handlers:
        return

    level = logging.DEBUG if app.debug else logging.INFO
    logging.basicConfig(
        level=level,
        format="%(asctime)s %(levelname)s [%(name)s] %(message)s",
    )


def _register_error_handlers(app):
    """Return JSON error responses for API clients."""

    @app.errorhandler(404)
    def not_found(error):
        return jsonify({"error": "Not found"}), 404

    @app.errorhandler(500)
    def internal_server_error(error):
        logger.exception("Internal server error")
        return jsonify({"error": "Internal server error"}), 500

    @app.errorhandler(Exception)
    def unhandled_exception(error):
        if isinstance(error, HTTPException):
            return jsonify(
                {"error": error.description or error.name}
            ), error.code

        logger.exception("Unhandled exception")
        return jsonify({"error": "Internal server error"}), 500


def create_app():
    app = Flask(__name__)
    # Load application configuration
    app.config.from_object(Config)

    _configure_logging(app)
    _register_error_handlers(app)

    CORS(
        app,
        resources={r"/api/*": {"origins": app.config["CORS_ORIGINS"]}},
        supports_credentials=True,
    )

    # Initialize database
    db.init_app(app)

    migrate = Migrate(app, db)
    # Initialize JWT manager
    jwt.init_app(app)

    # Create database tables from SQLAlchemy models
    with app.app_context():
        from app import models

    @app.route("/")
    def home():
        """
        Health check route.
        """
        return {"status": "success", "message": "LOVEN Backend API is running on AWS"}
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

    # Verification request routes
    app.register_blueprint(verification_requests_bp, url_prefix="/api/v1")
    
    # Feedback routes
    app.register_blueprint(feedback_bp, url_prefix="/api/v1/feedback")
    
    # Reports routes
    app.register_blueprint(report_bp, url_prefix="/api/v1/reports")

    # Favorites routes
    app.register_blueprint(favorites_bp, url_prefix="/api/v1/favorites")

    # Payment routes
    app.register_blueprint(payments_bp, url_prefix="/api/v1/payments")

    logger.debug("Registered routes: %s", app.url_map)

    return app
