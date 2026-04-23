# Technical Documentation
# LOVEN — API Documentation



## 1. External APIs

The LOVEN backend integrates with the following third-party services to offload specialized tasks and maintain architectural efficiency.

| Service | Purpose | Reason for Selection |
| :--- | :--- | :--- |
| **Moyasar API** | Payment Processing | Securely handles Mada, Visa, and Apple Pay. Ensures PCI compliance without storing sensitive card data on our servers. |
| **Firebase Storage** | Media Hosting | Offloads binary image data (artworks/profiles). Improves database performance by storing only lightweight URLs in PostgreSQL. |
| **Firebase Cloud Messaging (FCM)** | Push Notifications | Essential for real-time order updates. Provides a reliable delivery system for the `fcm_token` stored in the User model. |

---

## 2. Internal API Specification

### General Configuration
- **Base URL:** 
- **Content-Type:** `application/json`
- **Authentication:** All protected endpoints require a `Bearer <token>` in the HTTP `Authorization` header.
- **Identifiers:** All resource IDs are secure, non-sequential **UUIDs**.

### Authentication & Account Management
| Method | Endpoint | Input Format | Output Format | Description |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/auth/register` | JSON (name, email, password, role) | User Object + Token | Registers a new buyer or artist. |
| `POST` | `/auth/login` | JSON (email, password) | Auth Token | Authenticates user and returns JWT. |
| `GET` | `/users/me` | None (Auth Header) | User Object | Retrieves the current user's profile. |
| `PUT` | `/users/me` | JSON (name, email, etc.) | Updated User Object | Modifies user account data. |
| `DELETE` | `/users/me` | None (Auth Header) | Success Message | Performs a soft delete on the account. |

### Artist Profile Management
| Method | Endpoint | Input Format | Output Format | Description |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/artists` | JSON (display_name, bio) | Artist Object | Initializes an artist profile for a User. |
| `GET` | `/artists/{id}` | Path Param | Artist + Artworks | Public view of an artist's portfolio. |
| `PUT` | `/artists/me` | JSON (bio, city, policy) | Updated Artist | Updates own artist profile details. |
| `POST` | `/artists/me/verify`| JSON (doc_type, doc_no, inst) | Verification Object | Submits institutional data for verification. |

### Artwork Marketplace
| Method | Endpoint | Input Format | Output Format | Description |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/artworks` | Query Params (`?search=`, `?cat=`) | Array (Artworks) | Browses marketplace with filters. |
| `GET` | `/artworks/{id}` | Path Param | Artwork Object | Detailed view of a single piece. |
| `POST` | `/artworks` | JSON (title, price, qty, etc.)| Created Artwork | Artist adds a new listing. |
| `PUT` | `/artworks/{id}` | JSON (fields to change) | Updated Artwork | Modifies an existing listing. |
| `DELETE` | `/artworks/{id}` | Path Param | Success Message | Soft deletes a listing from the shop. |

### Cart & Favorites
| Method | Endpoint | Input Format | Output Format | Description |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/cart` | None (Auth Header) | Cart Items + Total | Retrieves current active cart items. |
| `POST` | `/cart/items` | JSON (artwork_id, qty) | Updated Cart | Adds or updates item quantity in cart. |
| `DELETE` | `/cart/items/{id}`| Path Param | Updated Cart | Removes an item from the cart. |
| `GET` | `/favorites` | None (Auth Header) | Array (Artworks) | Lists user's saved artworks. |
| `POST` | `/favorites` | JSON (artwork_id) | Success Message | Adds an artwork to favorites. |

### Orders & Fulfillment
| Method | Endpoint | Input Format | Output Format | Description |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/orders` | JSON (payment_id) | Order Object | Processes cart into a confirmed order. |
| `GET` | `/orders` | Query (`?role=buyer/seller`) | Array (Orders) | Lists order history by role. |
| `GET` | `/orders/{id}` | Path Param | Order Details | Full status and shipping info. |
| `PATCH` | `/orders/{id}/shipment`| JSON (company, tracking_no) | Updated Order | Artist updates shipping; triggers FCM. |

### Support & Feedback
| Method | Endpoint | Input Format | Output Format | Description |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/reports` | JSON (artwork_id, reason) | Success Message | Reports problematic artwork. |
| `POST` | `/feedback` | JSON (subject, message) | Success Message | Submits general platform feedback. |
