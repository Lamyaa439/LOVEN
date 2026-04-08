from fastapi import FastAPI, Depends
from sqlalchemy import Column, Integer, String, Numeric, ForeignKey, Text, Boolean, Enum, text
from sqlalchemy.orm import relationship, Session
import enum

from app.db.database import engine, Base, get_db

app = FastAPI()

class UserRole(str, enum.Enum):
    buyer = "buyer"
    artist = "artist"
    admin = "admin"

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, nullable=False)
    password_hash = Column(String, nullable=False)
    preferred_language = Column(String, nullable=True)
    is_active = Column(Boolean, default=True)
    role = Column(Enum(UserRole, name="user_role"), nullable=False, default=UserRole.buyer)

    products = relationship("Product", back_populates="seller")


class Product(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(Text)
    price = Column(Numeric(10, 2), nullable=False)
    seller_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    seller = relationship("User", back_populates="products")

Base.metadata.create_all(bind=engine)

@app.get("/")
def read_root():
    return {"message": "LOVEN API is running"}

@app.get("/users")
def get_users(db: Session = Depends(get_db)):
    result = db.execute(text("SELECT * FROM users"))
    return [dict(row._mapping) for row in result]