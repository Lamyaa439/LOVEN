"""
Authentication service layer.

This module defines the business logic for user registration and login.
It connects the API layer with the persistence layer and security utilities.
"""

from sqlalchemy.exc import IntegrityError

from app.extensions import db
from app.models.user import User
from app.persistence.repositories.user_repo import UserRepository
from flask_jwt_extended import create_access_token, create_refresh_token

user_repo = UserRepository()


def register_user(data):
    """
    Register a new user.
    Args:
        data : Request data containing:
            - name (str)
            - email (str)
            - password (str)
    Returns:
        tuple: JSON response and HTTP status code.
    """
    # Extract user input from request body
    name = data.get("name")
    email = data.get("email")
    password = data.get("password")
    fcm_token = data.get("fcm_token")
    role = data.get("system_role","customer").lower()

    # Validate required fields
    if not name or not email or not password:
        return {"error": "Missing required fields"}, 400
    
    # Role Check
    allowed_roles = ["customer", "artist"]
    if role not in allowed_roles:
        return {"error": f"Invalid registration role. Allowed roles are: {', '.join(allowed_roles)}"}, 400

    # Check if a user with the same email already exists
    if user_repo.get_user_by_email(email):
        return {"error": "User already exists"}, 400
    
    try:
        new_user = User(
            name=name,
            email=email,
            password=password,
            fcm_token=fcm_token,
            system_role=role,
        )

        # User only — ArtistProfile is created by AuthFacade.register (orchestration).
        db.session.add(new_user)
        db.session.commit()

        # Generate JWT access token:
        # 1- Define user identity
        user_identity = str(new_user.id)
        
        # 2- Generate BOTH tokens using the flask_jwt_extended library
        access_token = create_access_token(
            identity=user_identity,
            additional_claims={"role": new_user.system_role}
            )
        refresh_token = create_refresh_token(identity=user_identity)

        return {
            "message": "User registered successfully",
            "user_id": user_identity,
            "access_token": access_token,
            "refresh_token": refresh_token,
        }, 201
    
    except ValueError as e:
        db.session.rollback()
        return {"error": str(e)}, 400
    except IntegrityError:
        db.session.rollback()
        return {"error": "Registration failed due to a duplicate value"}, 400
    except Exception:
        db.session.rollback()
        return {"error": "An internal error occurred during registration"}, 500


def login_user(data: dict):
    """
    Authenticate a user and return an access token.
    Args:
        data (dict): Request data containing:
            - email (str)
            - password (str)
    Returns:
        tuple: JSON response and HTTP status code.
    """
    # Extract login credentials
    email = data.get("email")
    password = data.get("password")
    fcm_token = data.get("fcm_token")

    # Validate required fields
    if not email or not password:
        return {"error": "Missing email or password"}, 400
    
    # Retrieve user from database
    user = user_repo.get_user_by_email(email)

    # Validate credentials
    if not user or not user.check_password(password):
        return {"error": "Invalid email or password"}, 401
    
    # UPDATE FCM TOKEN ON LOGIN
    if fcm_token:
        user_repo.update_fcm_token(user.id, fcm_token)

    # Generate JWT access token:
    # 1- Define user identity
    user_identity =str(user.id)

    # 2- Generate BOTH tokens
    access_token = create_access_token(
        identity=user_identity,
        additional_claims={"role": user.system_role}
        )
    refresh_token = create_refresh_token(identity=user_identity)

    return {
        "message": "Login successful",
        "access_token": access_token,
        "refresh_token": refresh_token
    }, 200