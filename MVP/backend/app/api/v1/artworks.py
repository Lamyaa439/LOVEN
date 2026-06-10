from flask import Blueprint, request, jsonify

# JWT authentication utilities
from flask_jwt_extended import (
    jwt_required,
)

from app.core.auth_utils import get_authenticated_user_id

# Facade layer responsible for orchestration
from app.services.facade.artwork_facade import ArtworkFacade


# =========================================================
# Blueprint: Artworks API
# =========================================================
# Description:
# Handles all HTTP endpoints related to:
# - public artwork discovery
# - artwork search
# - artist artwork management
# - artwork updates
# - soft deletion
#
# Architecture:
# Routes/API Layer
#       ↓
# Facade Layer
#       ↓
# Service Layer
#       ↓
# Repository Layer
#       ↓
# PostgreSQL Database
#
# Responsibilities:
# - Receive HTTP requests
# - Extract params/body/query params
# - Validate authentication
# - Delegate orchestration to ArtworkFacade
# - Return JSON responses
#
# IMPORTANT:
# Routes should remain THIN.
#
# Do NOT place:
# - SQLAlchemy queries
# - business logic
# - ownership validation
# - database logic
# inside routes.
#
# NOTES:
# Artwork images are uploaded directly from Flutter
# to Firebase Storage.
#
# The backend only stores:
# - artwork_image_url
# inside PostgreSQL.
# =========================================================

artwork_bp = Blueprint("artworks", __name__)

# =========================================================
# Route: Admin Update Artwork Status
# Method: PATCH
# Endpoint: /api/v1/artworks/admin/<artwork_id>/status
#
# Description:
# Allows admins to moderate artwork status.
#
# Expected JSON:
# {
#     "status": "hidden"
# }
#
# Allowed statuses:
# - available
# - sold_out
# - hidden
#
# Authentication:
# Protected route, admin only
# =========================================================
@artwork_bp.patch("/admin/<artwork_id>/status")
@jwt_required()
def admin_update_artwork_status(artwork_id):

    user_id = get_authenticated_user_id()
    data = request.get_json() or {}

    status = data.get("status")

    result, status_code = ArtworkFacade.admin_update_status(
        user_id=user_id,
        artwork_id=artwork_id,
        status=status,
    )

    return jsonify(result), status_code

# =========================================================
# Route: List Public Artworks
# Method: GET
# Endpoint: /api/v1/artworks
#
# Description:
# Public marketplace endpoint used to retrieve
# paginated public artwork listings.
#
# Query Params:
# - limit
# - offset
# - status
#
# Example:
# /api/v1/artworks?limit=20&offset=0
#
# Authentication:
# Public route (No JWT required)
# =========================================================
@artwork_bp.get("/")
def list_public_artworks():

    # Extract pagination params
    limit = request.args.get(
        "limit",
        default=20,
        type=int
    )

    offset = request.args.get(
        "offset",
        default=0,
        type=int
    )

    # Extract artwork status filter
    status = request.args.get(
        "status",
        default="available"
    )

    # Delegate orchestration to facade layer
    result, status_code = ArtworkFacade.list_public(
        limit=limit,
        offset=offset,
        status=status,
    )

    return jsonify(result), status_code


# =========================================================
# Route: Search Artworks
# Method: GET
# Endpoint: /api/v1/artworks/search
#
# Description:
# Performs case-insensitive artwork search.
#
# Query Params:
# - q
# - limit
# - offset
# - status
#
# Example:
# /api/v1/artworks/search?q=painting
#
# IMPORTANT:
# This route MUST appear before:
# /<artwork_id>
#
# Otherwise Flask may incorrectly treat
# "search" as artwork_id.
#
# Authentication:
# Public route
# =========================================================
@artwork_bp.get("/search")
def search_artworks():

    # Extract search text
    query_text = request.args.get(
        "q",
        default="",
        type=str
    )

    # Extract pagination params
    limit = request.args.get(
        "limit",
        default=20,
        type=int
    )

    offset = request.args.get(
        "offset",
        default=0,
        type=int
    )

    # Extract status filter
    status = request.args.get(
        "status",
        default="available"
    )

    # Delegate search orchestration to facade
    result, status_code = ArtworkFacade.search(
        query_text=query_text,
        limit=limit,
        offset=offset,
        status=status,
    )

    return jsonify(result), status_code


# =========================================================
# Route: List My Artworks
# Method: GET
# Endpoint: /api/v1/artworks/mine
#
# Description:
# Retrieves artworks belonging to the authenticated artist.
#
# Authentication:
# Protected route
#
# IMPORTANT:
# This route MUST appear before:
# /<artwork_id>
# =========================================================
@artwork_bp.get("/mine")
@jwt_required()
def list_my_artworks():

    # Extract authenticated user ID from JWT
    user_id = get_authenticated_user_id()

    # Extract pagination params
    limit = request.args.get(
        "limit",
        default=20,
        type=int
    )

    offset = request.args.get(
        "offset",
        default=0,
        type=int
    )

    # Delegate orchestration to facade
    result, status_code = ArtworkFacade.list_mine(
        user_id=user_id,
        limit=limit,
        offset=offset,
    )

    return jsonify(result), status_code


# =========================================================
# Route: Get Artwork By ID
# Method: GET
# Endpoint: /api/v1/artworks/<artwork_id>
#
# Description:
# Retrieves one artwork by UUID.
#
# Authentication:
# Public route
# =========================================================
@artwork_bp.get("/<artwork_id>")
def get_artwork(artwork_id):

    # Delegate retrieval to facade
    result, status_code = ArtworkFacade.get_by_id(
        artwork_id
    )

    return jsonify(result), status_code


# =========================================================
# Route: Create Artwork
# Method: POST
# Endpoint: /api/v1/artworks
#
# Description:
# Allows authenticated artists to create
# new artwork listings.
#
# Expected JSON:
# {
#     "title": "Artwork",
#     "description": "Description",
#     "price": 150.00,
#     "quantity_available": 1,
#     "shipping_fee": 20.00,
#     "artwork_image_url": "https://firebase-url",
#     "status": "available"
# }
#
# IMPORTANT:
# Images are uploaded from Flutter directly
# to Firebase Storage.
#
# The backend only stores:
# - artwork_image_url
#
# Authentication:
# Protected route
# =========================================================
@artwork_bp.post("/")
@jwt_required()
def create_artwork():

    # Extract authenticated artist ID
    user_id = get_authenticated_user_id()

    # Safely extract JSON payload
    data = request.get_json() or {}

    # Delegate orchestration to facade
    result, status_code = ArtworkFacade.create(
        user_id,
        data
    )

    return jsonify(result), status_code


# =========================================================
# Route: Update Artwork
# Method: PATCH
# Endpoint: /api/v1/artworks/<artwork_id>
#
# Description:
# Allows artists to update their own artwork.
#
# IMPORTANT:
# Ownership validation should happen
# inside service layer.
#
# Authentication:
# Protected route
# =========================================================
@artwork_bp.patch("/<artwork_id>")
@jwt_required()
def update_artwork(artwork_id):

    # Extract authenticated user ID
    user_id = get_authenticated_user_id()

    # Extract update payload
    data = request.get_json() or {}

    # Delegate orchestration to facade
    result, status_code = ArtworkFacade.update(
        user_id=user_id,
        artwork_id=artwork_id,
        data=data,
    )

    return jsonify(result), status_code


# =========================================================
# Route: Delete Artwork
# Method: DELETE
# Endpoint: /api/v1/artworks/<artwork_id>
#
# Description:
# Soft-deletes an artwork owned by the artist.
#
# IMPORTANT:
# This should NOT hard-delete the row.
#
# The service layer should:
# - set deleted_at timestamp
# - hide artwork from public queries
#
# Authentication:
# Protected route
# =========================================================
@artwork_bp.delete("/<artwork_id>")
@jwt_required()
def delete_artwork(artwork_id):

    # Extract authenticated user ID
    user_id = get_authenticated_user_id()

    # Delegate delete orchestration to facade
    result, status_code = ArtworkFacade.delete(
        user_id=user_id,
        artwork_id=artwork_id,
    )

    return jsonify(result), status_code
