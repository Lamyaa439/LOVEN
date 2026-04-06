## Project strcuture

```
LOVEN_app/
├── backend/                        # Python (FastAPI/Flask) Core
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py                 # Entry point: Mounts all routers (Auth, Store, Workshops)
│   │   ├── database.py             # MongoDB Connection (Motor/Async)
│   │   ├── config.py               # Settings, Secrets (.env), & Subscription Tiers
│   │   │
│   │   ├── models/                 # Pydantic Schemas (The "Blueprints")
│   │   │   ├── user.py             # Tier logic (Basic/Pro), Verification status
│   │   │   ├── product.py          # Painting vs. Handmade (Knitting, etc.)
│   │   │   ├── gallery.py          # Artist-curated collections
│   │   │   ├── workshop.py         # Pro-only: Dates, Capacity, & Meeting Links
│   │   │   ├── order.py            # Status: Pending/Shipped (Artist-led tracking)
│   │   │   ├── review.py           # Bilingual Star Ratings (Verified Purchase Only)
│   │   │   ├── forum.py            # Community Suggestions & Upvotes
│   │   │   ├── report.py           # Flagged Content/Safety Tickets
│   │   │   └── contact.py          # Support Inquiries
│   │   │
│   │   ├── routes/                 # API Endpoints (The "Gatekeepers")
│   │   │   ├── auth.py             # Registration & JWT Login
│   │   │   ├── users.py            # Profiles & Account Tier Management
│   │   │   ├── products.py         # Marketplace Discovery
│   │   │   ├── galleries.py        # Gallery Display Logic
│   │   │   ├── workshops.py        # CRUD (Locked behind Pro-Tier Middleware)
│   │   │   ├── orders.py           # Shipping updates (Artist-side) & History (User-side)
│   │   │   ├── payments.py         # Stripe/Tap for Pro Upgrades & Booking
│   │   │   ├── reviews.py          # Review submission (Checks Order History)
│   │   │   ├── forum.py            # Suggestion Board API
│   │   │   ├── reports.py          # Content Moderation endpoints
│   │   │   └── contact.py          # Public Contact Form
│   │   │
│   │   └── utils/                  # Shared Internal Logic
│   │       ├── security.py         # JWT, Hashing, & Permission Decorators
│   │       ├── storage.py          # Image Uploads (S3/Cloudinary)
│   │       ├── mailer.py           # Email alerts (Tracking info, Support)
│   │       └── helpers.py          # Bilingual Logic (EN/AR String Handlers)
│   │
│   ├── tests/                      # Automated Testing (Pytest)
│   ├── .env                        # Private Keys (DB_URL, JWT_SECRET)
│   ├── .gitignore                  # Ignores venv/, __pycache__, .env
│   ├── requirements.txt            # Python Dependencies
│   └── README.md                   # Backend Dev Setup Guide
│
├── frontend/flutter_app/           # Flutter Mobile Application
│   ├── lib/
│   │   ├── models/                 # Dart Data Classes
│   │   ├── services/               # API Communication (Dio/Http)
│   │   ├── providers/              # State Management (Riverpod/Provider)
│   │   ├── screens/                # UI Layer
│   │   │   ├── home_screen.dart
│   │   │   ├── gallery_view.dart
│   │   │   ├── workshop_hub.dart   # Browsing & Booking Classes
│   │   │   ├── upgrade_pro.dart    # The "Paywall" for Artists to host workshops
│   │   │   ├── forum_board.dart    # Suggestions UI
│   │   │   ├── artist_dashboard.dart # Shipping management for Artists
│   │   │   ├── order_tracking.dart # Tracking info view for Users
│   │   │   └── product_details.dart
│   │   └── l10n/                   # Translation Files (.arb)
│   ├── assets/                     # Images, Fonts, Local Icons
│   ├── pubspec.yaml                # App Dependencies & Assets Config
│   └── README.md                   # Frontend Build Guide
│
└── README.md                       # Root Project Overview
```
