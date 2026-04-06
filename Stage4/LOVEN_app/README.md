## Project strcuture

```
backend/
  ├── app/
  │   ├── models/
  │   │   ├── user.py
  │   │   ├── product.py      # Individual artworks (Paintings/Handmade)
  │   │   ├── gallery.py      # NEW: Logic for grouping multiple artworks
  │   │   ├── review.py
  │   │   └── order.py
  │   │
  │   ├── routes/
  │   │   ├── auth.py
  │   │   ├── products.py     # CRUD for single items
  │   │   ├── galleries.py    # NEW: Endpoints for creating/viewing galleries
  │   │   ├── reviews.py
  │   │   └── orders.py
  │   │
  │   ├── utils/
  │   │   ├── storage.py      # Critical for Gallery (handling multiple uploads)
  │   │   └── helpers.py
  │   │
  │   ├── main.py             # Register the new gallery router here
  │   └── database.py
```
