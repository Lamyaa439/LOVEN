## Project strcuture

## Project Overview


# Project structure layer

- The Presentation Layer (Flutter)
  * Facad: Handles the UI/UX, bilingual toggling (AR/EN), and local state
  * Key Logic:
     * Artist Side: Dashboard for uploading art, managing galleries, and entering
    tracking numbers for shipping.
     * User Side: Browsing the feed, adding to cart, booking workshops, and posting
        upvotes in the forum.
     * Pro-Gate: Showing "Upgrade" prompts when a Basic artist tries to create a workshop.
        
- The Logic Layer (Python / FastAPI)
  * Processes requests, authenticates users (JWT), and enforces business logic.
  * Key Logic:
     * Validation: Ensuring only buyers can leave reviews.
     * Permission: Checking if an artist is "Pro" before allowing a workshop post.
     * Communication: Triggering emails via mailer.py when an artist ships a package.
     * Localization: Serving the correct en or ar strings based on the app's request.

- The Data Layer (MongoDB & Cloud Storage)
  * Persistent storage for all structured and unstructured data.
  * Key Components:
     * MongoDB: Stores flexible "Documents" for products (painting vs. knitting), user profiles, forum posts, and orders.
     * Cloud Storage (S3/Cloudinary): Stores the actual high-resolution images for the galleries and workshops.
     * Indexing: Speeding up searches so users can find "Handmade Blue Scarves" instantly.


```
LOVEN_app/
├── backend/                        # Python (FastAPI) Logic
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py                 # Entry point: Mounts Auth, Store, Workshops, Reports
│   │   ├── database.py             # MongoDB Connection
│   │   ├── config.py               # Env Secrets & Subscription Tier Settings
│   │   │
│   │   ├── models/                 # Data Blueprints
│   │   │   ├── user.py             # Basic/Pro tiers, Artist Verification
│   │   │   ├── product.py          # Painting vs. Handmade details
│   │   │   ├── gallery.py          # Artist-curated collections
│   │   │   ├── workshop.py         # Pro-only: Dates, Capacity, & Links
│   │   │   ├── order.py            # Status & Shipping Tracking
│   │   │   ├── review.py           # Ratings (Verified Purchase Only)
│   │   │   ├── forum.py            # Suggestions & Upvotes
│   │   │   └── report.py           # Flagged Content (Target ID + Reason)
│   │   │
│   │   ├── routes/                 # API Endpoints
│   │   │   ├── auth.py             # Registration & JWT
│   │   │   ├── users.py            # Profiles
│   │   │   ├── products.py         # Marketplace
│   │   │   ├── galleries.py        # Gallery Display
│   │   │   ├── workshops.py        # Pro-Only Logic
│   │   │   ├── orders.py           # Artist-led Shipping
│   │   │   ├── payments.py         # Upgrades & Sales
│   │   │   ├── reviews.py          # Star Ratings
│   │   │   ├── forum.py            # Suggestions Board
│   │   │   └── reports.py          # Content Moderation (Triggers mailer.py)
│   │   │
│   │   └── utils/                  # Shared Internal Logic
│   │       ├── security.py         # Permission Decorators (is_pro, is_admin)
│   │       ├── storage.py          # Cloud Image Uploads
│   │       ├── mailer.py           # Dev Alerts for Reports & Notifications
│   │       └── helpers.py          # Bilingual Logic
│   │
│   ├── requirements.txt
│   └── .env
│
├── frontend/flutter_app/           # Flutter Mobile Application
│   ├── lib/
│   │   ├── models/                 # Dart Data Classes
│   │   ├── services/               # API Communication (Dio/Http)
│   │   ├── providers/              # State Management
│   │   ├── screens/                # UI Layer
│   │   │   ├── home_screen.dart
│   │   │   ├── gallery_view.dart
│   │   │   ├── workshop_hub.dart
│   │   │   ├── upgrade_pro.dart    # Marketing/Paywall for Pro Tier
│   │   │   ├── forum_board.dart    # Community upvoting
│   │   │   ├── contact_dev_info.dart # READY PAGE: Displays your contact info/links
│   │   │   ├── report_form.dart    # Submission UI for flagged content
│   │   │   ├── artist_dashboard.dart # Manage shipping & tracking
│   │   │   └── product_details.dart
│   │   └── l10n/                   # Translation Files (.arb)
│   ├── assets/                     # Fonts, Local Icons
│   └── pubspec.yaml                # Dependencies (url_launcher for contact links)
│
└── README.md                       # Root Overview
```
