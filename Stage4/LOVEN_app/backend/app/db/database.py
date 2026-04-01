from pymongo import MongoClient
from dotenv import load_dotenv
from pathlib import Path
import os

BASE_DIR = Path(__file__).resolve().parents[2]
ENV_FILE = BASE_DIR / ".env"

load_dotenv(ENV_FILE)

MONGO_URI = os.getenv("MONGO_URI")

if not MONGO_URI:
    raise ValueError(f"MONGO_URI is not set. Expected .env at: {ENV_FILE}")

client = MongoClient(MONGO_URI, serverSelectionTimeoutMS=10000)
db = client["myapp"]