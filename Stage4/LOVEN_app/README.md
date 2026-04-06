## Project strcuture

```
LOVEN_app/
├── backend/                        # Python FastAPI Application
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py                 # App entry point & Router registration
│   │   ├── database.py             # MongoDB connection (Motor)
│   │   ├── config.py               # Settings & ENV variable loading
│   │   │
│   │   ├── models/                 # Pydantic Schemas (Data Validation)
│   │   │   ├── user.py             # Artist & Customer roles
│   │   │   ├── product.py          # Painting & Handmade art attributes
│   │   │   ├── gallery.py          # Art display collections
│   │   │   ├── review.py           # Ratings & bilingual comments
│   │   │   └── order.py            # Checkout & shipping status
│   │   │
│   │   ├── routes/                 # API Endpoints (Controllers)
│   │   │   ├── auth.py             # Login, Signup, JWT
│   │   │   ├── users.py            # Artist Verification & Profiles
│   │   │   ├── products.py         # Item listings (Paintings/Knitting)
│   │   │   ├── galleries.py        # Gallery display logic
│   │   │   ├── reviews.py          # Verified purchase review logic
│   │   │   └── orders.py           # Order tracking & management
│   │   │
│   │   └── utils/                  # Helper functions
│   │       ├── security.py         # Password hashing & JWT logic
│   │       ├── storage.py          # Image uploads (S3/Cloudinary)
│   │       └── helpers.py          # Bilingual formatting & error handlers
│   │
│   ├── tests/                      # Backend unit tests
│   ├── .env                        # Secret keys (API Keys, DB URLs)
│   ├── .gitignore                  # Ignore venv, __pycache__, .env
│   ├── requirements.txt            # Python dependencies
│   └── README.md                   # Backend setup instructions
│
├── frontend/flutter_app/           # Flutter Mobile Application
│   ├── lib/
│   │   ├── models/                 # Dart classes (matching Backend JSON)
│   │   ├── services/               # API calls (Dio or Http)
│   │   ├── providers/              # State Management (Riverpod/Provider)
│   │   ├── screens/                # UI (Gallery, Browsing, Profile)
│   │   │   ├── gallery_view.dart
│   │   │   ├── product_details.dart
│   │   │   └── artist_profile.dart
│   │   └── l10n/                   # intl_en.arb & intl_ar.arb (AR/EN)
│   ├── assets/                     # Icons, Fonts, Placeholders
│   ├── pubspec.yaml                # Flutter dependencies & Assets config
│   └── README.md                   # Frontend setup instructions
│
└── README.md                       # Main Project Overview & Local Setup
```
