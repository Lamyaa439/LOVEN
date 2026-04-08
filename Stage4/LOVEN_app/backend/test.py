from pathlib import Path
from dotenv import load_dotenv
from pymongo import MongoClient
import os

load_dotenv(Path(__file__).resolve().parent / ".env")

uri = os.getenv("MONGO_URI")
client = MongoClient(uri, serverSelectionTimeoutMS=10000)

print(client.admin.command("ping"))