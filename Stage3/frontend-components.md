# Front-End Components

This section outlines the main user interface components of the LOVEN mobile application, including the primary screens and reusable UI elements, along with their roles and interactions within the system.

---

## 1. Main Screens

### 1.1 Login Screen
**Purpose:**  
Allows existing users to sign in using their email and password.

**Interaction:**  
Validates user input and communicates with the authentication system. Upon successful login, the user is redirected to the Home Screen.

---

### 1.2 Sign Up Screen
**Purpose:**  
Allows new users to create an account and select their role within the platform.

**Interaction:**  
Collects user data and sends it to the backend for account creation. Redirects users to the Home Screen after successful registration.

---

### 1.3 Home Screen
**Purpose:**  
Displays featured artworks, highlighted artists, and main navigation options.

**Interaction:**  
Fetches artwork and artist data and allows navigation to Artwork Details and Artist Profile screens.

---

### 1.4 Explore Screen
**Purpose:**  
Allows users to browse and search for artworks.

**Interaction:**  
Provides filtering and search functionality. Navigates to Artwork Details when an artwork is selected.

---

### 1.5 Artwork Details Screen
**Purpose:**  
Displays detailed information about a selected artwork.

**Interaction:**  
Retrieves artwork and artist data. Allows users to add items to favorites or cart and navigate to the Artist Profile.

---

### 1.6 Artist Profile Screen
**Purpose:**  
Displays detailed information about an artist and their artworks.

**Interaction:**  
Fetches artist profile data and associated artworks. Allows navigation to individual artwork details.

---

### 1.7 Favorites Screen
**Purpose:**  
Displays artworks saved by the user.

**Interaction:**  
Retrieves favorite items and allows navigation to Artwork Details or removal from favorites.

---

### 1.8 Cart Screen
**Purpose:**  
Displays items added to the shopping cart.

**Interaction:**  
Allows users to update quantities, remove items, and proceed to checkout.

---

### 1.9 Orders Screen
**Purpose:**  
Displays user orders and their status.

**Interaction:**  
Retrieves order and shipping data and allows users to track their purchases.

---

### 1.10 Upload Artwork Screen
**Purpose:**  
Allows artists to create and publish new artwork listings.

**Interaction:**  
Collects artwork details and submits them to the backend system.

---

### 1.11 Artist Dashboard Screen
**Purpose:**  
Provides artists with an overview of their orders.

**Interaction:**  
Allows artists to update order status and shipment information.

---

### 1.12 Profile Screen
**Purpose:**  
Displays and manages user account information.

**Interaction:**  
Retrieves and updates user profile data.

---

## 2. Reusable UI Components

### 2.1 Primary Button
**Purpose:**  
A reusable button for main actions such as login, submission, and navigation.

**Interaction:**  
Triggers actions like API calls or screen navigation.

---

### 2.2 Input Field
**Purpose:**  
Captures user input in forms.

**Interaction:**  
Validates and updates form state dynamically.

---

### 2.3 Artwork Card
**Purpose:**  
Displays a summary of an artwork.

**Interaction:**  
Used across multiple screens and navigates to Artwork Details when selected.

---

### 2.4 Artist Card
**Purpose:**  
Displays basic artist information.

**Interaction:**  
Navigates to the Artist Profile screen.

---

### 2.5 Search Bar
**Purpose:**  
Allows users to search for artworks.

**Interaction:**  
Filters displayed results based on input.

---

### 2.6 Category Filter
**Purpose:**  
Allows users to filter artworks by category.

**Interaction:**  
Updates displayed content based on selected filters.

---

### 2.7 Cart Item Component
**Purpose:**  
Represents a single item in the cart.

**Interaction:**  
Allows quantity updates and item removal.

---

### 2.8 Order Status Badge
**Purpose:**  
Displays the current order status.

**Interaction:**  
Reflects backend updates.

---

### 2.9 Bottom Navigation Bar
**Purpose:**  
Provides navigation between main application sections.

**Interaction:**  
Switches between screens such as Home, Explore, Cart, and Profile.