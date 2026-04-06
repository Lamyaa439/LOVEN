## Project strcuture

```
app/
   ├── database.py         # MongoDB connection & client setup
   ├── main.py             # FastAPI/Flask initialization & router imports
   ├── models/             # Pydantic schemas (Data validation)
   │   ├── user.py
   │   ├── product.py      # Includes handmade vs painting fields
   │   ├── review.py       # Our new review logic
   │   └── order.py
   ├── routes/             # API Endpoints
   │   ├── auth.py
   │   ├── products.py
   │   ├── reviews.py      # Handle GET/POST for reviews
   │   └── orders.py
   ├── utils/              # Helper functions (Auth, Image uploads, Translation)
   └── config.py           # Environment variable loading
```
