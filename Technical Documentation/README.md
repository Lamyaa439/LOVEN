# Technical Documentation

# Design System Architecture
<p align="center">
  <strong>Figure 1: System Architecture Diagram</strong><br><br>
<img width="6458" height="3563" alt="Payment Processing Flow in-2026-04-23-090142" src="https://github.com/user-attachments/assets/bfd0e88e-2b3c-4fa7-9853-5916f5b27e5e" />
This diagram illustrates the overall system architecture, showing the interaction between the mobile frontend, backend API, database, and external services such as payment processing, cloud storage, and push notifications.

# Classes, and Database Design

## 1. Classes

<p align="center">
  <strong>Figure 2: Class Diagram</strong><br><br>
  <img src="https://github.com/user-attachments/assets/08167734-75d6-4663-a80d-34cb2de49c17" width="600"/>
</p>
This diagram illustrates the main back-end classes of the system, including their attributes, methods, and relationships. It represents the business logic and interactions between system components.

## 2. Database Design

<p align="center">
  <strong>Figure 3: Entity Relationship Diagram (ERD)</strong><br><br>
  <img src="https://github.com/user-attachments/assets/3471af10-5c4e-4127-873a-fa658445ed26" width="600"/>
</p>
This diagram represents the relational database design of the system. It shows tables, attributes, primary keys, foreign keys, and relationships between entities.

# High-level sequence diagrams
This section presents high-level sequence diagrams that illustrate the interaction between system components during key use cases in the art marketplace system. The diagrams show communication between the client, frontend, backend API, database, and external services.

1.	Artist registration
* Goal: Create a new artist account while ensuring valid input and preventing duplicate registrations.
* Actors/Components:
    •	**Artist (Client)**: Enters registration details and submits the form.
    •	**App Frontend**: Collects user input and sends registration request to backend.
    •	**Backend API**: Validates input, checks email uniqueness, hashes password, and creates user and artist profile.
    •	**Database**: Stores user and artist profile records and checks for existing email.

<p align="center">
  <strong>Figure 4: Artist Registration Sequence Diagram</strong><br><br>
  <img src="https://github.com/user-attachments/assets/5bac8d39-c1fc-4250-9529-2b506989ef0f" width="600"/>
</p>

The artist fills the registration form, and the frontend sends the request to the backend. The backend validates input data and checks whether the email already exists. If the email is already registered, an error is returned. Otherwise, the password is hashed, and both the user and artist profile records are created in the database. A success response is then returned to the frontend.

2.	Login
* Goal: Allow a user to log in securely using their email and password.
* Actors / Components:
    •	**User (Client)**: Enters email and password to access the system.
    •	**App Frontend**: Sends login request and displays response to the user.
    •	**Backend API**: Validates credentials, verifies password, and generates access token.
    •	**Database**: Retrieves user record based on email.

<p align="center">
  <strong>Figure 5: Login Sequence Diagram</strong><br><br>
  <img src="https://github.com/user-attachments/assets/96f03add-3c99-45f7-842a-fca76e803cb8" width="600"/>
</p>

The user enters their email and password in the frontend. The frontend sends a login request to the backend API. The backend retrieves the user record from the database using the email.
The backend then verifies the password. If the credentials are valid, the system generates and returns an access token. If the credentials are invalid, an error message is returned to the frontend.

3.	Artist uploads a new artwork
* Goal: An artist uploads a new artwork by entering details and uploading an image.
* Actors / Components 
    •	**Artist (Client)**: Provides artwork details and uploads image.
    •	**App Frontend**: Sends artwork data and image to backend.
    •	**Backend API**: Verifies artist account, processes request and creates artwork records.
    •	**Database**: Stores artwork and artwork image records.
    •	**Image Storage**: Stores uploaded image and returns its URL.

<p align="center">
  <strong>Figure 6: Artist uploads a new artwork Sequence Diagram</strong><br><br>
  <img src="https://github.com/user-attachments/assets/49d99fd2-dbed-4dae-91b7-e90350352439" width="600"/>
</p>

The artist submits artwork details and an image. The backend verifies the artist account, uploads the image to storage, and receives the image URL. Then, it creates the artwork and artwork image records in the database and returns a success response.

4.	Customer order
* Goal: A customer places an order by adding items to the cart and completing payment.
* Actors / Components 
    •	**Customer (Client)**: Adds items to cart and initiates checkout.
    •	**App Frontend**: Sends cart and order requests to backend and displays results.
    •	**Backend API**: Handles business logic (availability check, total calculation, order creation).
    •	**Database**: Stores cart, order, and order items; updates artwork stock.
    •	**Payment Service**: Processes payment and returns success or failure.

<p align="center">
  <strong>Figure 7: Customer order sequence diagram</strong><br><br>
  <img src="https://github.com/user-attachments/assets/a84eca90-2c2e-4990-8bcd-2df1b4932518" width="600"/>
</p>

The customer adds items to the cart, and the backend checks artwork availability and updates the cart. During checkout, the backend calculates totals and sends a payment request. Once payment is successful, the system creates the order and order items, updates stock, clears the cart, and returns confirmation.

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

## Authentication & Identity Layer

| Method | Endpoint | Input Format | Output Format | Description |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/auth/register` | JSON (name, email, password) | User Object + Token | تسجيل مستخدم جديد (مشتري/فنان). |
| `POST` | `/auth/login` | JSON (email, password) | Auth Token | التحقق من الهوية واستلام توكن الدخول. |
| `PATCH` | `/users/me/fcm-token` | JSON (fcm_token) | Success Message | **مهم:** تحديث عنوان الجهاز لإرسال التنبيهات. |
| `GET` | `/users/me` | None (Auth Header) | User Object | جلب بيانات البروفايل للمستخدم الحالي. |
| `PUT` | `/users/me` | JSON (name, lang, city) | Updated User Object | تحديث البيانات الشخصية. |
| `DELETE` | `/users/me` | None (Auth Header) | Success Message | تنفيذ الحذف المنطقي (Soft Delete). |

---

## Artist & Verification Layer

| Method | Endpoint | Input Format | Output Format | Description |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/artists` | JSON (display_name, bio) | Artist Object | إنشاء بروفايل فنان لمستخدم مسجل. |
| `GET` | `/artists/{id}` | Path Param | Artist + Artworks | العرض العام لبروفايل الفنان وأعماله. |
| `PUT` | `/artists/me` | JSON (bio, city, policy) | Updated Artist | تحديث بيانات الفنان المهنية. |
| `POST` | `/artists/me/verify`| JSON (doc_type, doc_no, inst) | Verification Object | تقديم طلب التوثيق الرسمي للإدارة. |

---

## Artwork Marketplace (Catalog)

| Method | Endpoint | Input Format | Output Format | Description |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/artworks` | Query (`search, category, page`) | Paginated Array | تصفح المتجر مع دعم البحث والتقسيم (Pagination). |
| `GET` | `/artworks/{id}` | Path Param | Artwork Object | عرض تفاصيل العمل الفني والكمية المتوفرة. |
| `POST` | `/artworks` | JSON (title, price, stock, images)| Created Artwork | إضافة عمل فني جديد (خاص بالفنانين فقط). |
| `PUT` | `/artworks/{id}` | JSON (updatable fields) | Updated Artwork | تعديل بيانات العمل الفني. |
| `DELETE` | `/artworks/{id}` | Path Param | Success Message | أرشفة العمل الفني (Soft Delete). |

---

## Cart & Favorites (Interactions)

| Method | Endpoint | Input Format | Output Format | Description |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/cart` | None (Auth Header) | Cart Items + Total | جلب محتويات السلة الحالية. |
| `POST` | `/cart/items` | JSON (artwork_id, qty) | Updated Cart | إضافة أو تحديث كمية منتج في السلة. |
| `DELETE` | `/cart/items/{id}`| Path Param | Updated Cart | حذف منتج معين من السلة. |
| `GET` | `/favorites` | None (Auth Header) | Array (Artworks) | عرض قائمة المفضلات للمستخدم. |
| `POST` | `/favorites/toggle`| JSON (artwork_id) | `{ status: "added/removed" }`| **Toggle:** إضافة أو حذف من المفضلات بطلب واحد. |

---

## Orders & Financial Transactions

| Method | Endpoint | Input Format | Output Format | Description |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/orders` | JSON (payment_method) | Order Object | تحويل السلة إلى طلب والبدء في عملية الدفع. |
| `GET` | `/orders` | Query (`?role=buyer/seller`) | Array (Orders) | عرض سجل الطلبات حسب دور المستخدم. |
| `GET` | `/orders/{id}` | Path Param | Order Detailed Obj | تفاصيل الطلب، الفاتورة، وبيانات الشحن. |
| `PATCH` | `/orders/{id}/status` | JSON (status) | Updated Order | تحديث حالة الطلب (Cancelled, Delivered). |
| `PATCH` | `/orders/{id}/shipment`| JSON (company, tracking_no) | Updated Order | **للفنانين:** إضافة بيانات الشحن وإطلاق تنبيه FCM. |

---

## System Governance (Support)

| Method | Endpoint | Input Format | Output Format | Description |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/reports` | JSON (artwork_id, reason, text) | Success Message | الإبلاغ عن محتوى مخالف. |
| `POST` | `/feedback` | JSON (subject, message) | Success Message | إرسال مقترح أو ملاحظة للإدارة. |

---

# SCM and QA Plans

1. Source Code Management (SCM) Plan:
The LOVEN project uses **Git** and **GitHub** as the primary tools for source code management, following the **GitHub Flow** branching strategy to support organized and collaborative development.

The workflow includes:
	A main branch that contains the stable and production-ready version of the project.
	Creating separate feature branches for each task, feature, or documentation update (e.g., ```feature/login```, ```docs/project-charter```).
	Using **pull requests (PRs)** to propose changes and review them before merging into the main branch.
	Performing code reviews to ensure code quality, consistency, and correctness before approval.
	Writing clear and descriptive commit messages to track changes and maintain a readable project history.
	Following branch naming conventions to keep the repository organized.
	Resolving merge conflicts carefully before integrating changes.
This structured workflow ensures better collaboration among team members, reduces conflicts, and maintains a clean and traceable development process.

The team uses **Visual Studio Code (VS Code)** as the main development environment, which is integrated with **Git** and **GitHub** to manage version control, track changes, and support collaboration.

2. Quality Assurance (QA) Plan
To ensure the reliability and functionality of the LOVEN application, the team applies continuous testing throughout the development process.

The QA strategy includes:
	API testing using **Postman** and **command-line tools (e.g., curl)** to verify endpoint functionality, request handling, and responses.
	Manual testing of key user flows such as registration, login, browsing artworks, adding items to cart, and completing purchases.
	Integration testing to ensure proper communication between the mobile application, backend services, and database.
	Validation and error handling testing to ensure the system correctly handles invalid inputs and unexpected scenarios.
	Authentication and authorization testing to verify secure access control and protected routes.
	Regression testing to ensure that new changes do not negatively affect existing features.
	Database testing to confirm correct storage, retrieval, and updating of data.
Testing focuses on core MVP functionalities to ensure system stability, usability, and correctness before final delivery.

3. Technical Justification
The use of **GitHub Flow** provides a simple and effective branching strategy that supports parallel development and safe integration of changes. Additionally, using **Postman** and **command-line tools** enables efficient and reliable API testing, allowing the team to validate backend functionality before integrating it with the mobile application. Continuous testing throughout development helps identify issues early, improves system reliability, and increases the likelihood of delivering a functional and stable MVP.
