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

```
LOVEN_app/
├── backend/                # Python FastAPI/Flask Application
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py         # Entry point (Initializes app & routes)
│   │   ├── database.py     # MongoDB connection logic (Motor/PyMongo)
│   │   ├── config.py       # Pydantic Settings (ENV variables, DB URLs)
│   │   │
│   │   ├── models/         # Pydantic Schemas (Data Validation)
│   │   │   ├── user.py     # Artist & Customer roles
│   │   │   ├── product.py  # Painting vs. Handmade details
│   │   │   ├── review.py   # Star ratings & bilingual comments
│   │   │   └── order.py    # Shipping & status updates
│   │   │
│   │   ├── routes/         # API Endpoints (Controllers)
│   │   │   ├── auth.py     # Register/Login
│   │   │   ├── users.py    # Profiles & Artist Verification
│   │   │   ├── products.py # Catalog browsing
│   │   │   ├── reviews.py  # Review submission logic
│   │   │   └── orders.py   # Checkout & Shipping updates
│   │   │
│   │   └── utils/          # Helper functions
│   │       ├── security.py # JWT hashing & password logic
│   │       ├── storage.py  # Logic to upload images to S3/Cloudinary
│   │       └── helpers.py  # Localization formatting
│   │
│   ├── tests/              # Backend unit tests
│   ├── .env                # Secret keys (Don't commit to Git!)
│   ├── .gitignore          # Ignores __pycache__, .env, venv/
│   ├── requirements.txt    # Python dependencies
│   └── README.md
│
├── frontend/flutter_app/   # Flutter Application
│   ├── lib/
│   │   ├── models/         # To match backend JSON structures
│   │   ├── providers/      # State management (Riverpod/Provider)
│   │   ├── services/       # API calling logic (using 'http' or 'dio')
│   │   ├── screens/        # UI (Browsing, Profile, Checkout)
│   │   └── l10n/           # AR/EN localization files (.arb)
│   ├── assets/             # Fonts, Icons, and local images
│   └── pubspec.yaml        # Flutter dependencies
│
└── README.md               # General project overview
```
