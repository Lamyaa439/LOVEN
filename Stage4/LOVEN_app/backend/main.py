from fastapi import FastAPI
from app.db.database import db

app = FastAPI()

@app.get("/")
def root():
    return {"message": "Backend connected"}

@app.get("/test-db")
def test_db():
    try:
        db.command("ping")
        return {"success": True, "message": "MongoDB connected"}
    except Exception as e:
        return {"success": False, "error": str(e)}

@app.get("/users")
def get_users():
    try:
        users = list(db.users.find())
        for user in users:
            user["_id"] = str(user["_id"])
        return {"success": True, "data": users}
    except Exception as e:
        return {"success": False, "error": str(e)}