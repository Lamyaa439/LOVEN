from fastapi import FastAPI
from pymongo import MongoClient
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI()

client = MongoClient(os.getenv("MONGO_URI"))
db = client["myapp"]

@app.get("/")
def root():
    return {"message": "Backend + MongoDB working"}

@app.post("/users")
def create_user(user: dict):
    result = db.users.insert_one(user)
    return {"id": str(result.inserted_id)}

@app.get("/users")
def get_users():
    users = list(db.users.find())
    
    for user in users:
        user["_id"] = str(user["_id"])
    
    return users