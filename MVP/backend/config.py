import os
from urllib.parse import quote_plus
from dotenv import load_dotenv
from datetime import timedelta
"""
This file connects the Flask app to the database.
"""

load_dotenv() # This line loads the .env file.


class Config:
    # security settings (important for JWT and sessions)
    # read it from .env, if not found, we use a fallback for development only.
    SECRET_KEY = os.getenv("SECRET_KEY", "dev-secret-key-change-me")
    JWT_SECRET_KEY = os.getenv("SECRET_KEY", "dev-secret-key-change-me")


    # connect the app to PostgreSQL
    DB_HOST = os.getenv("DB_HOST")
    DB_NAME = os.getenv("DB_NAME")
    DB_USER = os.getenv("DB_USER")
    DB_PASSWORD = os.getenv("DB_PASSWORD")
    DB_PORT = os.getenv("DB_PORT", "5432")

    # fail-fast
    if not all([DB_HOST, DB_NAME, DB_USER, DB_PASSWORD]):
        raise ValueError("CRITICAL ERROR: Database environment variables are missing in .env file!")

    # Encode the password to handle special characters (like '@') in the connection URI
    # This prevents SQLAlchemy from misinterpreting the URI structure
    safe_password = quote_plus(DB_PASSWORD)

    # the line here builds the database connection URL.
    SQLALCHEMY_DATABASE_URI = (
        f"postgresql://{DB_USER}:{safe_password}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    )
    
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # the 3 lines below tell Flask how to run the backend server

    # 1- read FLASK_DEBUG from .env and convert it into True or False
    DEBUG = os.getenv("FLASK_DEBUG", "False").lower() == "true"
    # 2- read the server host from .env, if the HOST missing use 0.0.0.0
    HOST = os.getenv("HOST", "0.0.0.0")
    # 3- read the port from .env then convert it to int
    PORT = int(os.getenv("PORT", "5000"))

    # ---- flask-jwt-extended settings ------
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(minutes=int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 30)))
    JWT_REFRESH_TOKEN_EXPIRES = timedelta(days=int(os.getenv("REFRESH_TOKEN_EXPIRE_DAYS", 7)))