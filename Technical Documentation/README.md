<h1 align="center">Technical Documentation</h1>

## User Stories & Mockups – LOVEN MVP (For both User/ customer)

### 1. User Stories (MoSCoW Prioritization)

#### Must Have (Core MVP – absolutely required)
These are essential for the platform to function as a marketplace.

##### Authentication & Accounts

 - As a user, I want to create an account and log in, so that I can access the LOVEN platform securely.
 - As a user, I want to log out, so that I can protect my account.

##### Artwork Discovery & Purchase

 - As a user, I want to browse artworks, so that I can discover art available for purchase.
 - As a user, I want to view artwork details (title, description, price, images), so that I can decide whether to buy.
 - As a user, I want to add artworks to a cart, so that I can purchase multiple items easily.
 - As a user, I want to remove items from my cart, so that I can manage my selections.
 - As a user, I want to complete a purchase, so that I can buy artworks.

##### Orders

 - As a user, I want to view my orders, so that I can track my purchases.

##### Artist Core Features

 - As an artist, I want to create and manage my profile, so that I can showcase my artwork.
 - As an artist, I want to upload and manage artwork listings, so that I can sell my work.
 - As an artist, I want to view incoming orders, so that I can manage sales.
 - As an artist, I want to update shipment information (shipping company & tracking number), so that buyers can track deliveries.

#### Should Have (Important but not blocking)

These improve usability and trust but aren’t required for launch.

 - As a user, I want to search for artworks, so that I can quickly find specific items.
 - As a user, I want to filter artworks (price, category, artist), so that I can narrow down choices.
 - As a user, I want to save artworks to a wishlist, so that I can revisit them later.
 - As a user, I want to receive order status updates, so that I stay informed.
 - As an artist, I want to edit pricing and availability, so that I can manage my listings effectively.
 - As an artist, I want to see basic sales analytics, so that I can understand my performance.

#### Could Have (Nice-to-have enhancements)

These add polish and engagement but can wait.

 - As a user, I want to rate or review artworks, so that I can share feedback.
 - As a user, I want to follow artists, so that I can see their new work.
 - As a user, I want personalized recommendations, so that I can discover relevant art.
 - As an artist, I want to feature highlighted artworks, so that I can promote my best work.
   
#### Won’t Have (Out of scope for MVP)

Important to explicitly define to avoid scope creep.

 - Live chat between buyers and artists
 - Auction/bidding system
 - AR/VR artwork previews
 - Multi-language support
 - Advanced payment options (crypto, installment plans)

### 2.  Mockups (Main Screens Overview) (4 enitites)

#### 📱 Authentication Screens

##### Login Screen

 - Email & password input, Login button, Link to Sign Up

##### Sign Up Screen

 - Name, email, password inputs
Create account button

#### Tools for Mockups:
I used Figma to design the mobile UI mockups for LOVEN.
Screens include: Login, Home, Artwork Details, Cart, Orders, and Artist Dashboard.
Canva to design the Logo of the app

| Splash Screen | Login | Sign Up |
|:-------------:|:-----:|:-------:|
| <p align="center"><img src="https://github.com/user-attachments/assets/7dcc8f08-5940-4df5-8d03-40a3400d6a43" width="200"/></p> | <p align="center"><img src="https://github.com/user-attachments/assets/8ddde36e-df2b-42e8-99c9-27bae2faaaa0" width="200"/></p> | <p align="center"><img src="https://github.com/user-attachments/assets/461dbbc1-209d-4dd0-abca-c273c519bb20" width="200"/></p> |

## Design System Architecture
<p align="center">
  <strong>Figure 1: System Architecture Diagram</strong><br><br>
<img width="8191" height="2004" alt="FinalDSH" src="https://github.com/user-attachments/assets/f712bfed-e455-48c0-8b13-3c9a8378de65" />
This diagram illustrates the overall system architecture, showing the interaction between the mobile frontend, backend API, database, and external services such as payment processing, cloud storage, and push notifications.
</p>

## Front-End Components

This section outlines the main user interface of the LOVEN mobile application, including key screens and reusable components that define how users interact with the system.

### Main Screens

- **Login Screen**: Allows users to sign in using their credentials.
- **Sign Up Screen**: Enables users to create an account.
- **Home Screen**: Displays featured artworks and main navigation.
- **Explore Screen**: Allows users to browse and search for artworks.
- **Artwork Details Screen**: Shows detailed information about a selected artwork.
- **Artist Profile Screen**: Displays artist information and their artworks.
- **Favorites Screen**: Shows saved artworks.
- **Cart Screen**: Displays selected items and allows checkout.
- **Orders Screen**: Displays user orders and their status.
- **Upload Artwork Screen**: Allows artists to add new artworks.
- **Artist Dashboard Screen**: Allows artists to manage orders and update status.
- **Profile Screen**: Displays and updates user information.

---

### Reusable UI Components

- **Primary Button**: Used for main actions.
- **Input Field**: Used for user input in forms.
- **Artwork Card**: Displays a preview of an artwork.
- **Artist Card**: Displays basic artist information.
- **Search Bar**: Allows users to search content.
- **Category Filter**: Filters artworks by category.
- **Cart Item**: Represents an item in the cart.
- **Order Status Badge**: Displays order status.
- **Bottom Navigation Bar**: Provides navigation between main sections.

## Classes, and Database Design

### 1. Classes

<p align="center">
  <strong>Figure 2: Class Diagram</strong><br><br>
  <img width="600" alt="ClassesLovenProject" src="https://github.com/user-attachments/assets/a10b0bc9-83eb-4002-a742-e56347367026" />

  </p>
This diagram illustrates the main back-end classes of the system, including their attributes, methods, and relationships. It represents the business logic and interactions between system components.

### 2. Database Design

<p align="center">
  <strong>Figure 3: Entity Relationship Diagram (ERD)</strong><br><br>
  <img width="5880" alt="finalll" src="https://github.com/user-attachments/assets/63d27741-6b89-419f-b303-bc36bb9880a4" />

  </p>
This diagram represents the relational database design of the system. It shows tables, attributes, primary keys, unique keys, foreign keys, and relationships between entities.

## High-level sequence diagrams
This section presents high-level sequence diagrams that illustrate the interaction between system components during key use cases in the art marketplace system. The diagrams show communication between the client, frontend, backend API, database, and external services.

### 1.	Artist registration
* Goal: Create a new artist account while ensuring valid input and preventing duplicate registrations.
* Actors/Components:
    - **Artist (Client)**: Enters registration details and submits the form.
    - **App Frontend**: Collects user input and sends registration request to backend.
    - **Backend API**: Validates input, checks email uniqueness, hashes password, and creates user and artist profile.
    - **Database**: Stores user and artist profile records and checks for existing email.

<p align="center">
  <strong>Figure 4: Artist Registration Sequence Diagram</strong><br><br>
  <img src="https://github.com/user-attachments/assets/495fd6f0-9839-4cf0-bc0c-77eb99d0121f" width="600"/>
  </p>
The artist fills the registration form, and the frontend sends the request to the backend. The backend validates input data and checks whether the email already exists. If the email is already registered, an error is returned. Otherwise, the password is hashed, and both the user and artist profile records are created in the database. A success response is then returned to the frontend.

### 2.	Login
* Goal: Allow a user to log in securely using their email and password.
* Actors / Components:
    - **User (Client)**: Enters email and password to access the system.
    - **App Frontend**: Sends login request and displays response to the user.
    - **Backend API**: Validates credentials, verifies password, and generates access token.
    - **Database**: Retrieves user record based on email.

<p align="center">
  <strong>Figure 5: Login Sequence Diagram</strong><br><br>
  <img src="https://github.com/user-attachments/assets/edfa1020-30ca-48c1-83ba-4b0a7ab7c16c" width="600"/>
  </p>
The user enters their email and password in the frontend. The frontend sends a login request to the backend API. The backend retrieves the user record from the database using the email.
The backend then verifies the password. If the credentials are valid, the system generates and returns an access token. If the credentials are invalid, an error message is returned to the frontend.

### 3.	Artist uploads a new artwork
* Goal: An artist uploads a new artwork by entering details and uploading an image.
* Actors / Components 
    - **Artist (Client)**: Provides artwork details and uploads image.
    - **App Frontend**: Sends artwork data and image to backend.
    - **Backend API**: Verifies artist account, processes request and creates artwork records.
    - **Database**: Stores artwork and artwork image records.
    - **Image Storage**: Stores uploaded image and returns its URL.

<p align="center">
  <strong>Figure 6: Artist uploads a new artwork Sequence Diagram</strong><br><br>
  <img src="https://github.com/user-attachments/assets/16c577d6-69e8-4e99-865a-746d5901caa4" width="600"/>
  </p>
The artist submits artwork details and an image. The backend verifies the artist account, uploads the image to storage, and receives the image URL. Then, it creates the artwork and artwork image records in the database and returns a success response.

### 4.	Customer order
* Goal: A customer places an order by adding items to the cart and completing payment.
* Actors / Components 
    - **Customer (Client)**: Adds items to cart and initiates checkout.
    - **App Frontend**: Sends cart and order requests to backend and displays results.
    - **Backend API**: Handles business logic (availability check, total calculation, order creation).
    - **Database**: Stores cart, order, and order items; updates artwork stock.
    - **Payment Service**: Processes payment and returns success or failure.

<p align="center">
   <strong>Figure 7: Customer order sequence diagram</strong><br><br>
  <img src="https://github.com/user-attachments/assets/918d6c47-277b-44ab-bf26-0d9e5a6eb5cf" width="600"/>
  </p>
The customer adds items to the cart, and the backend checks artwork availability and updates the cart. During checkout, the backend calculates totals and sends a payment request. Once payment is successful, the system creates the order and order items, updates stock, clears the cart, and returns confirmation.

## LOVEN — API Documentation

### 1. External Services Integration (SDK & API)
The backend integrates with third-party services using a mix of REST APIs and Official Admin SDKs to ensure secure and efficient operations.

| Service | Integration Method | Input Format | Output Format | Description |
| :--- | :--- | :--- | :--- | :--- |
| **Moyasar** | REST API (Server-to-Server) | JSON (amount, order_id, source) | JSON (Payment Object) | Validates payment transactions and links them to the Order UUID. |
| **Firebase Storage** | Firebase Admin SDK | File Stream / Binary | string (Public URL) | Uploads artwork/profile images and retrieves persistent access URLs. |
| **Firebase Messaging**| Firebase Admin SDK | JSON (fcm_token, payload) | JSON (Message ID) | Dispatches real-time push notifications using the Server-side Admin SDK. |

---

### 2. Internal API Specification

#### General Configuration
- **Base URL:** `https://api.loven-app.com/v1`
- **Content-Type:** `application/json`
- **Authorization**: Bearer `<JWT_TOKEN>` (Required for all endpoints except `/auth/register`, `/auth/login`, and public GET catalog routes).
- **Identifiers:** All resource IDs are secure, non-sequential **UUIDs**.

#### Authentication & Identity Layer

| Method | Endpoint | Input Format | Output Format | Description |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/auth/register` | JSON (name, email, password) | JSON (User Object + Token) | Creates a new user account. |
| `POST` | `/auth/login` | JSON (email, password) | JSON (Token Object) | Authenticates user and returns JWT. |
|`POST`| `/auth/logout` | None |JSON (Success) | Invalidates the current JWT token and ends the session.|
| `PATCH` | `/users/me/fcm-token` | JSON (fcm_token) | JSON (Success Message) | Updates Firebase Cloud Messaging token. |
| `GET` | `/users/me` | None | JSON (User Object) | Retrieves current authenticated user profile. |
| `PATCH` | `/users/me` | JSON (name, email) | JSON (Updated User Object) | Updates the authenticated user's personal information. |
| `DELETE` | `/users/me` | None | JSON (Success Message) | Soft Delete |

---

#### Artist & Verification Layer

| Method | Endpoint | Input Format | Output Format | Description |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/artists` | JSON (display_name, bio) | JSON (Artist Object) | Initializes an artist profile. `Requires system_role = artist`. |
| `GET` | `/artists/{id}` | Path Param | JSON (Artist + Artworks) | Public view of an artist's profile. |
| `PATCH` | `/artists/me` | JSON (bio, city, policy) | JSON (Updated Artist Object) | Updates the artist's bio, city, or shipping policy. |
| `POST` | `/artists/me/verify`| JSON (doc_type, doc_no, inst) | JSON (Verification Object) | Submits institutional data for identity verification. |

---

#### Artwork Marketplace (Catalog)

| Method | Endpoint | Input Format | Output Format | Description |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/artworks` | Query Params (`search, category, page`) | JSON(Paginated Array) | Browse artworks. Filters: `?search=sky&page=1&limit=20` |
| `GET` | `/artworks/{id}` | Path Param | JSON (Artwork Object) | Detailed view of a single artwork. |
| `POST` | `/artworks` | JSON (title, price, stock, images)| JSON ( Artwork Object) | Adds a new artwork. Requires `artist` role |
| `PUT` | `/artworks/{id}` | JSON (updatable fields) | JSON ( Artwork Object)| Modifies artwork details or pricing. |
| `DELETE` | `/artworks/{id}` | Path Param | JSON (Success Message) | Soft Delete|

---

#### Cart & Favorites (Interactions)

| Method | Endpoint | Input Format | Output Format | Description |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/cart` | None | JSON (Cart Object + Total) | Retrieves the active cart and calculates the total. |
| `POST` | `/cart/items` | JSON (artwork_id, qty) | JSON ( Cart Object) | Adds an artwork to the cart or updates its quantity. |
| `DELETE` | `/cart/items/{id}`| Path Param | JSON ( Cart Object) | Removes a specific item from the cart.|
| `GET` | `/favorites` | None | JSON (Array of Artworks) | Fetches artworks based on the `favorite_artworks_ids` array. |
| `POST` | `/favorites/toggle`| JSON (artwork_id) | JSON (Status Object) | Executes `toggle_favorite(id)` method in the User class. |

---

#### Orders & Financial Transactions

| Method | Endpoint | Input Format | Output Format | Description |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/orders` | JSON | JSON (Order Object) | Validates cart availability, creates order, and returns Payment ID. |
| `GET` | `/orders` | Query Params | JSON (Array of Orders) | Lists orders. Filter by role: `?role=buyer` or `?role=seller`. |
| `GET` | `/orders/{id}` | Path Param | JSON (Order Detailed Obj) | Full status, order items, and shipping info. |
| `PATCH` | `/orders/{id}/status` | JSON (status) | JSON ( Order Object)| Updates general order status (e.g., delivered, cancelled). |
| `PATCH` | `/orders/{id}/shipment`| JSON (company, tracking_no) | JSON ( Order Object) | Artist Only: Sets shipping company/tracking. Triggers FCM. |
| `POST` | `/payments/webhook` | JSON | JSON ( Success mes) | Moyasar gateway webhook to update payment status. |

---

#### System Governance (Support)

| Method | Endpoint | Input Format | Output Format | Description |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/reports` | JSON (artwork_id, reason, text) | JSON (Success Message) | Submits a report for a problematic artwork listing. |
| `POST` | `/feedback` | JSON (subject, message) | JSON (Success Message) | Submits general platform suggestions. |

---

## SCM and QA Plans

### 1. Source Code Management (SCM) Plan:
The LOVEN project uses **Git** and **GitHub** as the primary tools for source code management, following the **GitHub Flow** branching strategy to support organized and collaborative development.

The workflow includes:
* A main branch that contains the stable and production-ready version of the project.
* Creating separate feature branches for each task, feature, or documentation update (e.g., ```feature/login```, ```docs/project-charter```).
* Using **pull requests (PRs)** to propose changes and review them before merging into the main branch.
* Performing code reviews to ensure code quality, consistency, and correctness before approval.
* Writing clear and descriptive commit messages to track changes and maintain a readable project history.
* Following branch naming conventions to keep the repository organized.
* Resolving merge conflicts carefully before integrating changes.
This structured workflow ensures better collaboration among team members, reduces conflicts, and maintains a clean and traceable development process.

The team uses **Visual Studio Code (VS Code)** as the main development environment, which is integrated with **Git** and **GitHub** to manage version control, track changes, and support collaboration.

### 2. Quality Assurance (QA) Plan
To ensure the **LOVEN** application is reliable, secure, and production-ready, a comprehensive **end-to-end (E2E)** testing strategy is implemented alongside **unit** and **integration** testing.

#### 1. End-to-End (E2E) Testing

E2E testing validates complete user journeys across the entire system, from frontend to backend and external services. Key scenarios include:

- ```User registration``` → ```login``` → ```profile access```
- ```Browsing artworks``` → ```adding to cart``` → ```checkout``` → ```payment``` → ```order confirmation```
- ```Artist uploading artwork``` → ```listing``` → ```customer purchase``` → ```shipment update```

These tests ensure that all system components (frontend, backend API, database, and third-party services) work together correctly.

#### 2. API Testing

APIs are tested using Postman and command-line tools (e.g., curl) to verify:

- Request/response correctness
- Authentication handling
- Error responses and edge cases

#### 3. Integration Testing

Integration tests verify communication between:

- Frontend and backend
- Backend and database
- Backend and external services (payments, storage, notifications)

#### 4. Functional & User Flow Testing

Manual testing is conducted on critical user flows to validate usability and correctness:

- Authentication (register/login/logout)
- Artwork browsing and filtering
- Cart and checkout process

#### 5. Security Testing

- Authentication and authorization validation
- Token handling and protected routes
- Input validation and error handling

#### 6. Regression Testing

Performed after each major update to ensure new changes do not break existing functionality.

#### 7. Database Testing

Ensures:

- Data consistency and integrity
- Correct CRUD operations
- Proper handling of relationships (users, artworks, orders)

## Technical Justification

### 1. Flutter for Cross-Platform Development
Flutter was chosen because it allows the development of both Android and iOS applications using a single codebase. This significantly reduces development time and effort compared to building separate native applications. This choice aligns with the scope of the project as an MVP, where time and resources are limited, enabling faster delivery without compromising quality.

### 2. Mobile App over Web Application
A mobile application was selected instead of a web application to provide better accessibility and user engagement. Mobile apps allow users to easily browse artworks, make purchases, and receive real-time updates. This decision fits the scope of the system, as the platform focuses on frequent user interaction and benefits from mobile-specific features such as push notifications.

### 3. High Performance UI with Flutter
Flutter provides high performance because it compiles directly to native code, resulting in smooth animations and fast rendering. This is especially important for the LOVEN platform, where users interact with image-heavy content such as artwork listings. Ensuring a responsive UI within the scope of the MVP enhances user experience without requiring complex frontend optimization.

### 4. UI/UX Design Tools – Figma & Canva
Figma was used to design the mobile UI mockups for the LOVEN application, including screens such as Login, Home, Artwork Details, Cart, Orders, and the Artist Dashboard. It supports rapid prototyping and easy iteration, which is essential within the scope of an MVP, where quick design validation is needed.

Canva was used to design the application logo due to its simplicity and efficiency in creating visual assets. It allows the team to produce professional-quality branding without requiring advanced design skills, making it suitable for the project’s limited scope and resources.

### 5. Python for Rapid Development
Python was selected as the backend programming language due to its simplicity and readability, which enables rapid development and easier collaboration. This makes it highly suitable for the limited scope and timeframe of an MVP, allowing the team to efficiently implement core features.

### 6. Flask as a Lightweight Backend Framework
Flask was chosen because it is a lightweight and flexible web framework that provides only the essential tools needed to build RESTful APIs. It avoids unnecessary complexity, making it ideal for the project scope, where a simple and maintainable backend is sufficient.

### 7. RESTful API Design
The backend follows a RESTful API design to ensure clear and standardized communication between the frontend and backend. This approach simplifies integration with the Flutter application and supports future scalability. It aligns with the scope of the system by providing a structured yet flexible architecture.

### 8. PostgreSQL for Relational Data Management
PostgreSQL was selected as the database because it provides strong support for relational data and ensures data integrity. The LOVEN system relies on structured relationships between entities such as users, artworks, and orders. This choice fits the scope of the application, where reliable data management is essential.

### 9. Containerization using Docker
Docker was used to containerize the application, ensuring a consistent development and execution environment across different machines. This eliminates issues related to dependency conflicts and environment configuration differences between team members. It also simplifies setup and deployment processes. This choice aligns with the scope of the project, as it improves development efficiency and collaboration without introducing unnecessary complexity.

### 10. ACID Compliance for Transactions
**PostgreSQL** was configured to ensure **ACID (Atomicity, Consistency, Isolation, Durability)** compliance for all database transactions. In a marketplace like **LOVEN**, where a single purchase involves multiple steps—such as deducting stock, creating an order record, and confirming payment—ACID properties guarantee that either all steps succeed or none do. This prevents data corruption and ensures that the system remains in a consistent state, which is critical for maintaining user trust and financial accuracy.

### 11. Use of External Payment Gateway (Moyasar)
**Moyasar** was integrated as the primary payment gateway to handle financial transactions securely. By offloading payment processing to a specialized provider, the system ensures compliance with **PCI DSS** standards without the need to store sensitive credit card information on the local server. Moyasar was specifically chosen for its robust support of local payment methods in Saudi Arabia, such as **Mada and Apple Pay**, which enhances the user experience and facilitates seamless transactions within the target market.

### 12. Firebase Cloud Storage (FCS) for Media Handling
**Firebase Cloud Storage (FCS)** Firebase Storage was integrated as the dedicated media handling solution for the LOVEN MVP to efficiently manage high-resolution artwork and user profile images. In a visually-driven art marketplace, storing heavy binary files directly within a relational database like PostgreSQL is an architectural anti-pattern that drastically degrades query performance and inflates storage requirements. By offloading media to Firebase, the system maintains a strict separation of concerns: the database remains lightweight and lightning-fast by storing only the persistent access URLs, while Firebase handles the heavy lifting of binary data storage. Furthermore, Firebase automatically serves these assets through a robust **Global CDN** (Content Delivery Network), significantly reducing latency and ensuring that image-heavy screens load instantly within the Flutter application. Coupled with the seamless backend integration provided by the **Firebase Admin SDK**, this approach delivers a scalable, high-performance media architecture without the overhead of configuring and maintaining a custom file server.

### 13. Firebase Cloud Messaging (FCM) for Notifications
**Firebase Cloud Messaging (FCM)** was selected as the optimal push notification infrastructure for the LOVEN MVP due to its strategic alignment with our tech stack and operational efficiency. Since the frontend is built with **Flutter**, FCM provides a seamless "One Codebase" advantage, acting as a universal translator that reliably delivers notifications to both iOS and Android devices without the need to maintain separate logic for APNs and Android services. On the backend, the official **Python Admin SDK** allows for painless integration with Flask, enabling instant notification dispatch using the user's stored `fcm_token` without building complex HTTP requests. Crucially, unlike custom WebSocket solutions that drop when an app is closed, FCM connects directly at the OS level, guaranteeing delivery even when the app is in the background or fully terminated. Furthermore, it delivers this enterprise-grade, highly scalable notification system at **zero cost** for standard messages, making it the perfect resource-efficient choice for validating the MVP.

### 14. JWT for Secure Authentication
**JSON Web Tokens (JWT)** were adopted for secure, stateless authentication between the Flutter frontend and the Flask backend. JWT allows the server to verify user identity without the need to maintain session data in memory, which enhances system scalability. Each request is authenticated via a signed token, ensuring that sensitive actions—such as managing an artist profile or completing a purchase—are protected against unauthorized access.

### 15. UUIDs for Resource Identification
The system utilizes **UUIDs (Universally Unique Identifiers)** instead of sequential integers for identifying all primary resources (Users, Artworks, Orders). This approach enhances security by preventing **ID enumeration attacks**, where malicious actors could guess resource URLs by incrementing IDs. Additionally, UUIDs provide a future-proof foundation for database sharding or merging, ensuring that identifiers remain unique across different distributed systems.

### 16. Modular System Architecture (Facade & Repositories)
A **Modular Architecture**—incorporating the **Facade and Repository patterns**—was implemented to ensure a strict **Separation of Concerns**. The Repository layer abstracts database interactions, while the Facade layer orchestrates complex business logic. This modularity makes the codebase significantly easier to test, maintain, and scale. It also allows the team to modify specific components, such as changing a third-party service or updating database logic, with minimal impact on the rest of the system.
