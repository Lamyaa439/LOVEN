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
```
LOVEN_app/
├── backend/                        # Python (FastAPI/Flask) Application
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py                 # Central Entry Point (Registers all Routers)
│   │   ├── database.py             # MongoDB connection logic (Motor/Async)
│   │   ├── config.py               # Environment & Global Settings (.env loader)
│   │   │
│   │   ├── models/                 # Pydantic Data Models (Validation)
│   │   │   ├── user.py             # Artist/Customer roles & Verification
│   │   │   ├── product.py          # Painting vs. Handmade (Knitting, etc.)
│   │   │   ├── gallery.py          # Collections/Display Groups
│   │   │   ├── order.py            # Payments, Shipping, & Custom Requests
│   │   │   ├── review.py           # Bilingual Star Ratings
│   │   │   ├── forum.py            # Suggestion Board posts & Upvotes
│   │   │   ├── report.py           # Flagging (Content/User safety)
│   │   │   └── contact.py          # Support Inquiries/Tickets
│   │   │
│   │   ├── routes/                 # API Endpoints (Controllers)
│   │   │   ├── auth.py             # JWT Registration & Login
│   │   │   ├── users.py            # Profiles & Artist Verification
│   │   │   ├── products.py         # Marketplace browsing/Search
│   │   │   ├── galleries.py        # Gallery/Collection management
│   │   │   ├── orders.py           # Checkout & Shipping updates
│   │   │   ├── reviews.py          # Review submission logic
│   │   │   ├── forum.py            # Public Suggestion logic
│   │   │   ├── reports.py          # Content Moderation endpoints
│   │   │   └── contact.py          # Contact Form submission
│   │   │
│   │   └── utils/                  # Shared Helper Functions
│   │       ├── security.py         # JWT & Password Hashing
│   │       ├── storage.py          # Image Upload logic (S3/Cloudinary)
│   │       ├── mailer.py           # Email alerts for Contact/Reports
│   │       └── helpers.py          # Bilingual text formatting logic
│   │
│   ├── tests/                      # Unit & Integration Tests
│   ├── .env                        # Private Keys (DB_URL, JWT_SECRET)
│   ├── .gitignore                  # Ignores venv/, __pycache__, .env
│   ├── requirements.txt            # Python Libraries
│   └── README.md                   # Backend Dev Setup Guide
│
├── frontend/flutter_app/           # Flutter Mobile Application
│   ├── lib/
│   │   ├── models/                 # Dart Classes (JSON Serialization)
│   │   ├── services/               # API Communication (Dio/Http)
│   │   ├── providers/              # State Management (Riverpod/Bloc/Provider)
│   │   ├── screens/                # UI Screens
│   │   │   ├── home_screen.dart
│   │   │   ├── gallery_view.dart
│   │   │   ├── product_details.dart
│   │   │   ├── forum_screen.dart   # Suggestions Board
│   │   │   ├── contact_screen.dart # Support Form
│   │   │   └── report_form.dart    # Safety/Reporting UI
│   │   └── l10n/                   # Translation files (intl_en.arb / intl_ar.arb)
│   ├── assets/                     # Images, Fonts, Local Icons
│   ├── pubspec.yaml                # Flutter Dependencies & Assets Config
│   └── README.md                   # Frontend Dev Setup Guide
│
└── README.md                       # Overall Project Documentation
```
