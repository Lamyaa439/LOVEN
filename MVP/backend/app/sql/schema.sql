-- ====================
-- LOVEN Schema
-- Database: PostgreSQL
-- ====================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

/* =======================================================================
TABLE: users
Description: The core authentication and account table for LOVEN APP
Relationships: Acts as the base for "artist_profiles" (1-1 relationship)
=========================================================================*/
CREATE TABLE IF NOT EXISTS "users" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "name" VARCHAR(255) NOT NULL,
    "email" VARCHAR(255) NOT NULL UNIQUE,
    "password" VARCHAR(255) NOT NULL, -- Stored as a bcrypt hash
    "system_role" VARCHAR(50) DEFAULT 'customer' CHECK (system_role IN ('admin', 'customer', 'artist')),
    "fcm_token" VARCHAR(255), -- Firebase Cloud Messaging token
    "is_active" BOOLEAN DEFAULT true,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP -- Soft Delete
);

/* =======================================================================
TABLE: artist_profiles
Description: Stores artist-specific profile information.
Relationships: One-to-one relationship with users. One artist profile can
own many artworks.
=========================================================================*/
CREATE TABLE IF NOT EXISTS "artist_profiles" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL UNIQUE,
    "display_name" VARCHAR(255) NOT NULL UNIQUE,
    "city" VARCHAR(100),
    "bio" TEXT,
    "profile_image_url" VARCHAR(255),
    "is_verified" BOOLEAN DEFAULT false,
    "shipping_policy" TEXT,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP -- Soft Delete
);

/* =======================================================================
TABLE: artworks
Description: Stores artwork listings created by artists.
Relationships: Each artwork belongs to one artist profile and can appear in
cart_items, order_items, favorites, and reports.
=========================================================================*/
CREATE TABLE IF NOT EXISTS "artworks" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "artist_profile_id" UUID NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "price" DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    "quantity_available" INTEGER DEFAULT 1 CHECK (quantity_available >= 0),
    "shipping_fee" DECIMAL(10,2) DEFAULT 0 CHECK (shipping_fee >= 0),
    "artwork_image_url" VARCHAR(255),
    "status" VARCHAR(50) DEFAULT 'available',
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP -- Soft Delete
);

/* =======================================================================
TABLE: carts
Description: Stores each user's shopping cart.
Relationships: One-to-one relationship with users. A cart can contain many
cart_items.
=========================================================================*/
CREATE TABLE IF NOT EXISTS "carts" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL UNIQUE,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP
);

/* =======================================================================
TABLE: cart_items
Description: Stores artworks added to a user's cart.
Relationships: Belongs to one cart and one artwork.
=========================================================================*/
CREATE TABLE IF NOT EXISTS "cart_items" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "cart_id" UUID NOT NULL,
    "artwork_id" UUID NOT NULL,
    "quantity" INTEGER DEFAULT 1 CHECK (quantity > 0),
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP
);

/* =======================================================================
TABLE: orders
Description: Stores customer orders.
Relationships: Each order belongs to one user and can have many order_items
and one payment.
=========================================================================*/
CREATE TABLE IF NOT EXISTS "orders" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "buyer_id" UUID NOT NULL,
    "subtotal" DECIMAL(10,2) CHECK (subtotal >= 0),
    "shipping_fee" DECIMAL(10,2) CHECK (shipping_fee >= 0),
    "total_amount" DECIMAL(10,2) CHECK (total_amount >= 0),
    "status" VARCHAR(50) DEFAULT 'pending',
    "shipping_company" VARCHAR(100),
    "tracking_number" VARCHAR(100),
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/* =======================================================================
TABLE: order_items
Description: Stores individual artworks inside an order.
Relationships: Belongs to one order and one artwork.
=========================================================================*/
CREATE TABLE IF NOT EXISTS "order_items" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "order_id" UUID NOT NULL,
    "artwork_id" UUID NOT NULL,
    "quantity" INTEGER NOT NULL CHECK (quantity > 0),
    "price_at_purchase" DECIMAL(10,2) NOT NULL CHECK (price_at_purchase >= 0),
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/* =======================================================================
TABLE: favorites
Description: Stores artworks favorited by users.
Relationships: Links users and artworks.
=========================================================================*/
CREATE TABLE IF NOT EXISTS "favorites" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "artwork_id" UUID NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE("user_id", "artwork_id") -- Prevents duplicate likes
);

/* =======================================================================
TABLE: reports
Description: Stores user reports against artworks.
Relationships: A report can belong to a user and an artwork.
=========================================================================*/
CREATE TABLE IF NOT EXISTS "reports" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "reporter_id" UUID NOT NULL,
    "target_artwork_id" UUID NOT NULL,
    "reason" VARCHAR(255) NOT NULL,
    "details" TEXT,
    "status" VARCHAR(50) DEFAULT 'open',
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/* =======================================================================
TABLE: feedback
Description: Stores feedback messages submitted by users.
Relationships: Feedback can optionally belong to one user.
=========================================================================*/
CREATE TABLE IF NOT EXISTS "feedback" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "subject" VARCHAR(255),
    "message" TEXT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/* =======================================================================
TABLE: verification_requests
Description: Stores artist verification requests.
Relationships: Each verification request belongs to one user.
=========================================================================*/
CREATE TABLE IF NOT EXISTS "verification_requests" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "artist_profile_id" UUID NOT NULL,
    "document_type" VARCHAR(50),
    "institution_name" VARCHAR(255),
    "document_number" VARCHAR(100),
    "status" VARCHAR(50) DEFAULT 'pending',
    "submitted_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/* =======================================================================
TABLE: payments
Description: Stores payment records for orders.
Relationships: Each payment belongs to one order.
=========================================================================*/
CREATE TABLE IF NOT EXISTS "payments" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "order_id" UUID NOT NULL UNIQUE,
    "moyasar_payment_id" VARCHAR(255) UNIQUE,
    "amount" DECIMAL(10,2) CHECK (amount >= 0),
    "status" VARCHAR(50) DEFAULT 'pending',
    "currency" VARCHAR(10) DEFAULT 'SAR',
    "paid_at" TIMESTAMP,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



/* ==============================================================================
   FOREIGN KEYS & CASCADING RULES (CRITICAL FOR FINANCIAL INTEGRITY)
============================================================================== */

-- Profile & Artwork linkages (Safe to Cascade if user is hard-deleted by Admin)
ALTER TABLE "artist_profiles" ADD FOREIGN KEY("user_id") REFERENCES "users"("id") ON DELETE CASCADE;
ALTER TABLE "artworks" ADD FOREIGN KEY("artist_profile_id") REFERENCES "artist_profiles"("id") ON DELETE CASCADE;

-- Cart is temporary, safe to Cascade
ALTER TABLE "carts" ADD FOREIGN KEY("user_id") REFERENCES "users"("id") ON DELETE CASCADE;
ALTER TABLE "cart_items" ADD FOREIGN KEY("cart_id") REFERENCES "carts"("id") ON DELETE CASCADE;
ALTER TABLE "cart_items" ADD FOREIGN KEY("artwork_id") REFERENCES "artworks"("id") ON DELETE CASCADE;

-- Favorites can be Cascaded
ALTER TABLE "favorites" ADD FOREIGN KEY("user_id") REFERENCES "users"("id") ON DELETE CASCADE;
ALTER TABLE "favorites" ADD FOREIGN KEY("artwork_id") REFERENCES "artworks"("id") ON DELETE CASCADE;

-- ==============================================================================
-- 🛑 FINANCIAL RECORDS (STRICT RESTRICTION - NEVER CASCADE)
-- ==============================================================================
ALTER TABLE "orders" ADD FOREIGN KEY("buyer_id") REFERENCES "users"("id") ON DELETE RESTRICT;
ALTER TABLE "order_items" ADD FOREIGN KEY("order_id") REFERENCES "orders"("id") ON DELETE RESTRICT;
ALTER TABLE "order_items" ADD FOREIGN KEY("artwork_id") REFERENCES "artworks"("id") ON DELETE RESTRICT; 
ALTER TABLE "payments" ADD FOREIGN KEY("order_id") REFERENCES "orders"("id") ON DELETE RESTRICT;

-- Support links
ALTER TABLE "verification_requests" ADD FOREIGN KEY("artist_profile_id") REFERENCES "artist_profiles"("id") ON DELETE CASCADE;
ALTER TABLE "feedback" ADD FOREIGN KEY("user_id") REFERENCES "users"("id") ON DELETE CASCADE;
ALTER TABLE "reports" ADD FOREIGN KEY("reporter_id") REFERENCES "users"("id") ON DELETE CASCADE;
ALTER TABLE "reports" ADD FOREIGN KEY("target_artwork_id") REFERENCES "artworks"("id") ON DELETE CASCADE;
