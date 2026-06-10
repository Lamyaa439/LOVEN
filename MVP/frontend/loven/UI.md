# UI/UX Architecture Guide — LOVEN Flutter App

> **Document location:** `MVP/frontend/loven/UI.md`  
> **Last aligned to codebase:** June 2026 (based on current `lib/` structure and routes)  
> **Important:** This document describes the **UI layer only**. It does not change any code.

---

## 1. Executive Introduction

### What LOVEN is trying to feel like

LOVEN is an **art-first marketplace** — not a generic e-commerce app. The UI is designed to feel:

- **Calm** — soft backgrounds, generous spacing, no visual shouting  
- **Editorial** — like browsing a gallery or art magazine, especially on Home  
- **Premium but honest** — polished surfaces without pretending features exist when the backend does not support them yet  
- **Trustworthy** — consistent buttons, cards, loading states, and clear copy  

The app should feel like a place to **discover original art from local creators**, not like a discount shopping mall.

### What changed during the redesign phases

Over several phases, the team moved the app from **scattered, screen-by-screen styling** toward a **shared design system**:

| Phase theme | What improved |
|-------------|---------------|
| Design tokens | Colors, spacing, typography centralized in `core/res/` |
| Shared widgets | Buttons, cards, loading/empty states reused everywhere |
| Home redesign | Editorial Discover layout with hero, rails, mosaic |
| Artwork layer | One `LovenArtworkCard` with three visual variants |
| Navigation clarity | Shell vs screen-owned headers; back-button fixes |
| Account split | “Account details” vs “Artist profile” are separate flows |
| Checkout honesty | No fake shipping/payment forms; order success screen |
| Orders polish | Item thumbnails, fetch full order details, stock refresh |

Some **legacy README references** (for example `confirm_order_screen.dart`) may still mention old filenames — the **live app** uses newer screens documented below.

### Why this document exists

You need to discuss UI/UX architecture with a supervisor **without reading Dart code**. This handbook explains:

1. What each important UI file is  
2. Why it exists  
3. How pieces connect  
4. What to say confidently in a meeting  

### How to read this document

- **Sections 1–3** — Big picture (start here if you are new)  
- **Sections 4–6** — Shared design system and consistency story  
- **Section 7** — Navigation (very important for understanding “weird” back behavior)  
- **Sections 8–10** — Home, artwork layer, every screen  
- **Sections 11–12** — User journeys and design reasoning  
- **Sections 13–14** — Removed files and master file table  
- **Sections 15–16** — Meeting prep and cheat sheet  

**Tip:** When you see a technical word, look for the **plain-English meaning in brackets** right after it.

---

## 2. The Big Design Idea Behind the App

### Art-first, not shopping-first

A generic shopping app optimizes for **speed and conversion**: big buy buttons, dense product grids, aggressive promotions.

LOVEN optimizes for **discovery and appreciation**:

- Large artwork imagery  
- Artist names and verification badges visible  
- Sections named like a gallery (“Masterpieces”, “Discover artists”)  
- Search and genre browsing feel exploratory, not transactional  

### Calm, editorial, premium visual style

**Editorial** [layout that feels like a magazine or gallery website, not a spreadsheet of products] means:

- A **hero area** at the top of Home  
- **Horizontal rails** of artworks (scroll sideways)  
- **Section headers** with “See all” links  
- Breathing room (`AppSpacing.screenPadding = 24px` gutters)  

**Premium** here does not mean flashy. It means **restraint**: consistent typography, soft borders, rounded cards, and a limited color palette tied to the LOVEN brand.

### Balancing beauty and clarity

Every screen must answer two questions for the user:

1. **Where am I?** (title, header, back button when needed)  
2. **What can I do next?** (primary button, list tiles, tabs)  

Beauty supports clarity — it does not replace it. That is why loading and empty states were standardized (users always know if content is loading, missing, or failed).

### Keeping LOVEN identity

The team did **not** copy another app pixel-for-pixel. Instead they:

- Used LOVEN brand blues and purples (`AppColors.brandPrimary`, etc.)  
- Built **shared components** that feel like one product  
- Chose gallery metaphors (Discover, Masterpieces, chips for genres)  

### What “visual consistency” means in this project

**Visual consistency** [the app looks and behaves like one product, not twenty separate mini-apps] means:

- The same primary button looks the same on Login, Checkout, and Feedback  
- Cards use the same corner radius and border (`LovenSurfaceCard`, `AppRadius.lg`)  
- Lists use the same thumbnail sizes (`AppSizes.listThumbSize`)  
- Error/empty patterns use `GalleryEmptyState` instead of random text on a blank page  

---

## 3. A Simple Mental Model of the UI Architecture

Think of the UI like building a house:

```
┌─────────────────────────────────────────────────────────────┐
│  DESIGN SYSTEM (paint, measurements, fonts)               │
│  core/res/ — AppColors, AppSpacing, AppTheme, etc.         │
├─────────────────────────────────────────────────────────────┤
│  SHARED WIDGETS (doors, windows, standard furniture)        │
│  core/widgets/ — LovenPrimaryButton, LovenArtworkCard, …    │
├─────────────────────────────────────────────────────────────┤
│  FEATURE SCREENS (rooms — cart room, home room, auth room)  │
│  features/*/view/screens/ — CartScreen, HomeScreen, …       │
├─────────────────────────────────────────────────────────────┤
│  NAVIGATION SHELL (hallway connecting main rooms)           │
│  NavigationScreen + NavigationWidget (bottom tabs)          │
├─────────────────────────────────────────────────────────────┤
│  ROUTER (address book — which screen opens for which URL)   │
│  core/router/ — AppRoutes, GoRouter route tables            │
└─────────────────────────────────────────────────────────────┘
```

### Key concepts in plain English

| Term | Plain English meaning | How LOVEN uses it |
|------|----------------------|-------------------|
| **Widget** [a single UI building block in Flutter] | Anything on screen: button, text, image, whole page | Every screen is a tree of widgets |
| **Scaffold** [the basic page skeleton: background + app bar area + body + optional bottom area] | The “frame” of a screen | Most screens wrap content in `Scaffold` |
| **Theme / ThemeData** [app-wide default colors, fonts, and styles] | The app’s visual defaults | `AppTheme.lightTheme` / `darkTheme` in `app_theme.dart` |
| **Design system** [shared rules for colors, spacing, type] | One source of truth for look-and-feel | `design_system.dart` barrel export |
| **Shared widget** [reusable UI component used in many places] | Standardized button, card, empty state | `loven_widgets.dart` exports |
| **Screen widget** [one full page the user navigates to] | Home, Cart, Login, etc. | Lives under `features/*/view/screens/` |
| **Route** [a URL path that opens a specific screen] | `/cart`, `/login`, `/my-profile` | Defined in `app_routes.dart` + route builders |
| **Navigation shell** [outer frame with bottom tabs that stays visible] | Main app frame after login/onboarding | `NavigationScreen` at `/` (Home route) |
| **Bottom sheet** [panel that slides up from the bottom] | Artwork detail, search sheet | `openArtworkDetail()`, Home search |
| **Dialog / modal** [popup overlay] | Logout confirm, report artwork | `AlertDialog`, `showDialog` |
| **Loading state** [UI shown while waiting for data] | Spinner + calm message | `GalleryLoadingState` |
| **Empty state** [UI shown when there is nothing to list] | Icon + title + optional action | `GalleryEmptyState` |
| **Error state** [UI shown when fetch failed] | Often reuses `GalleryEmptyState` with retry | Home, orders, cart |
| **Bloc / Cubit** [classes that hold screen data and loading logic — “state management”] | The brain behind the UI; screen listens and rebuilds | `HomeBloc`, `CartCubit`, `AuthCubit` |
| **State** [current data the UI is showing: loading, loaded, error] | What the screen displays right now | `HomeLoaded`, `CartLoaded`, etc. |

### Why this layered structure is better than random per-screen styling

**Old approach problems:**

- Each developer picked their own padding (16 vs 18 vs 22)  
- Five different “primary buttons” that looked slightly different  
- Some screens had no empty state — just blank white space  
- Duplicate artwork card layouts across Home and Favorites  

**New approach benefits:**

- Change button color once → updates everywhere  
- New screen looks “on brand” on day one by importing shared widgets  
- Users learn the app faster because patterns repeat  

---

## 4. Detailed Explanation of the Shared Design System Files

All paths are relative to: `MVP/frontend/loven/lib/`

### 4.1 `core/res/design_system.dart`

| | |
|---|---|
| **What it contains** | A single **export file** — it does not define tokens itself; it re-exports all token files |
| **Problem it solves** | Developers import one line instead of ten |
| **Usage** | `import 'package:loven/core/res/design_system.dart';` |
| **Say in meeting** | “We have one import that gives every screen access to colors, spacing, fonts, and theme.” |

### 4.2 `core/res/theme/app_colors.dart`

| | |
|---|---|
| **Class** | `AppColors` |
| **Contains** | Named colors: brand, surfaces, text, borders, buttons, status (success/warning/error), favorites, navigation glass |
| **Why not hard-coded hex in screens?** | Brand refresh becomes one-file change; no “almost the same blue” drift |
| **Examples** | `brandPrimary` (#293CAE), `canvas` (warm gallery background), `textMuted` (secondary labels) |
| **Used by** | Virtually all UI — theme, widgets, feature screens |
| **Say in meeting** | “Colors have semantic names like `textMuted`, not random hex values scattered in screens.” |

### 4.3 `core/res/theme/app_theme.dart`

| | |
|---|---|
| **Class** | `AppTheme` |
| **Contains** | `lightTheme` and `darkTheme` — full `ThemeData` [Flutter’s bundle of default styles for the whole app] |
| **Problem it solves** | Text fields, app bars, dividers, chips inherit consistent styling via `Theme.of(context)` |
| **Why it matters** | Dark mode toggle (`ThemeBloc`) switches between two complete themes |
| **Say in meeting** | “Screens should read styles from the theme, not invent new text field borders on every form.” |

### 4.4 `core/res/typography/app_text_styles.dart`

| | |
|---|---|
| **Class** | `AppTextStyles` |
| **Contains** | Reusable text styles — e.g. price display styles |
| **Problem it solves** | Price labels and special typography stay consistent on cards and detail views |
| **Say in meeting** | “Typography tokens stop every screen from picking random font weights for prices and labels.” |

### 4.5 `core/res/dimensions/app_spacing.dart`

| | |
|---|---|
| **Class** | `AppSpacing` |
| **Contains** | Numeric scale (`xs` 8, `lg` 16, `xxl` 24…) + semantic names (`screenPadding` 24, `sectionGap` 32, `bottomNavClearance` 88) |
| **Problem it solves** | Layout rhythm — screens align to the same grid |
| **Example** | Checkout footer and account lists both use `AppSpacing.screenPadding` for horizontal gutters |
| **Say in meeting** | “We use named spacing like `sectionGap` so sections breathe consistently.” |

### 4.6 `core/res/dimensions/app_radius.dart`

| | |
|---|---|
| **Class** | `AppRadius` |
| **Contains** | Corner radii: `sm`, `md`, `lg`, `pill` |
| **Used for** | Cards, buttons, chips, artwork thumbnails |
| **Say in meeting** | “Rounded corners are tokenized — cards and inputs share the same corner language.” |

### 4.7 `core/res/dimensions/app_sizes.dart`

| | |
|---|---|
| **Class** | `AppSizes` |
| **Contains** | Fixed dimensions: avatar sizes, icon sizes, list thumbnail size (72), floating nav height, shell logo height |
| **Used for** | Avatars, nav bar, artwork thumbnails in cart/orders |
| **Say in meeting** | “Thumbnail and avatar sizes are standardized so lists look aligned.” |

### 4.8 `core/res/dimensions/app_shadows.dart`

| | |
|---|---|
| **Class** | `AppShadows` |
| **Contains** | Shadow presets (e.g. floating nav bar shadow) |
| **Say in meeting** | “Elevation and shadows are centralized for the floating bottom navigation.” |

### 4.9 `core/res/dimensions/app_durations.dart`

| | |
|---|---|
| **Class** | `AppDurations` |
| **Contains** | Animation timing tokens |
| **Say in meeting** | “Motion timing can be consistent if we expand animations later.” |

### 4.10 `core/res/responsive/app_breakpoints.dart` & `responsive_extensions.dart` & `responsive_page.dart`

| | |
|---|---|
| **Purpose** | Responsive layout helpers for different screen widths |
| **Current usage** | Supporting structure; primary mobile layout drives most screens today |
| **Say in meeting** | “We have hooks for tablet/desktop refinement, but the MVP is mobile-first.” |

---

## 5. Detailed Explanation of the Shared UI Widgets

Import via: `import 'package:loven/core/widgets/loven_widgets.dart';`

### 5.1 `loven_widgets.dart`

**What it is:** A **barrel export file** [one import that exposes many widgets] — same idea as `design_system.dart` but for components.

---

### 5.2 `LovenPrimaryButton` — `loven_primary_button.dart`

| | |
|---|---|
| **Plain English** | The main action button (filled, brand-colored) |
| **Looks like** | Full-width or inline pill; optional icon; loading spinner when busy |
| **Prevents** | Every screen inventing a different blue button |
| **Used on** | Login, checkout footer, order success, signup success, empty-state actions |
| **UX benefit** | User always knows “this is the main action” |

---

### 5.3 `LovenSecondaryButton` — `loven_secondary_button.dart`

| | |
|---|---|
| **Plain English** | Secondary action (outline / quieter) |
| **Used on** | Checkout “back” steps, order success “View order history”, art detail “View cart” |
| **UX benefit** | Clear hierarchy: primary = commit, secondary = alternate path |

---

### 5.4 `LovenTextField` — `loven_text_field.dart`

| | |
|---|---|
| **Plain English** | Standard text input with LOVEN borders and padding |
| **Used on** | Auth forms, edit account, verification request, feedback |
| **Prevents** | Mismatched form field heights and focus colors |

---

### 5.5 `LovenSurfaceCard` — `loven_surface_card.dart`

| | |
|---|---|
| **Plain English** | White/elevated rounded rectangle container |
| **Looks like** | Soft border, optional tap ripple, inner padding |
| **Used on** | Account tiles wrapper, order cards, checkout account step, cart items |
| **UX benefit** | Content grouped into scannable blocks |

---

### 5.6 `LovenCircleAvatar` — `loven_circle_avatar.dart`

| | |
|---|---|
| **Plain English** | Circular profile/artist image with fallback initial |
| **Used on** | Home discover artists row, artists list, account header |
| **Prevents** | Broken image circles and inconsistent avatar sizes |

---

### 5.7 `GalleryLoadingState` — `gallery_loading_state.dart`

| | |
|---|---|
| **Plain English** | Centered spinner + optional calm message |
| **Message examples** | “Preparing discovery…”, “Loading orders…”, “Loading cart…” |
| **Used on** | Home, cart, orders, favorites, artworks list |
| **UX benefit** | User knows app is working, not frozen |

---

### 5.8 `GalleryEmptyState` — `gallery_empty_state.dart`

| | |
|---|---|
| **Plain English** | Icon + title + subtitle + optional action button |
| **Used on** | Empty cart, no orders, no favorites, filtered home with no results, errors |
| **UX benefit** | Empty pages feel intentional, not broken |

---

### 5.9 `GalleryChip` — `gallery_chip.dart`

| | |
|---|---|
| **Plain English** | Small pill for filters/categories |
| **Used on** | Home genre/filter UI, active filter indicator |
| **UX benefit** | Tappable, selected vs unselected states match design tokens |

---

### 5.10 `GallerySectionHeader` — `gallery_section_header.dart`

| | |
|---|---|
| **Plain English** | Section title row with optional “See all” action |
| **Used on** | Home discover sections |
| **UX benefit** | Editorial section rhythm on Home |

---

### 5.11 `LovenArtworkCard` — `loven_artwork_card.dart`

**The most important shared visual component for art display.** See Section 9 for deep dive.

---

### 5.12 `artwork_detail_opener.dart` — `openArtworkDetail()`

| | |
|---|---|
| **Plain English** | Single function that opens artwork detail as a **bottom sheet** [tall panel sliding up] |
| **Why one entry point** | Home, favorites, grids all open details the same way |
| **Opens** | `ArtDetailsScreen` at ~92% screen height |

---

### Shared vs feature-specific vs one-off widgets

| Type | Location | Example | When to use |
|------|----------|---------|-------------|
| **Shared** | `core/widgets/` | `LovenPrimaryButton` | Any feature, 2+ screens need same look |
| **Feature-specific** | `features/*/view/widgets/` | `checkout_stepper.dart`, `home_discover_hero.dart` | Used only in that feature |
| **One-off local** | Private classes inside a screen file (`_CartItemCard`) | Cart row layout | Not reused elsewhere; keeps file self-contained |

**Rule of thumb:** If two features need the same look, promote to `core/widgets/`.

---

## 6. How the App Achieved Visual Consistency

### From scattered styling to unified system

**Before:** Hard-coded `Color(0xFF...)`, random `EdgeInsets.all(18)`, duplicate card decorations.

**After:**

1. Tokens in `core/res/`  
2. Components in `core/widgets/`  
3. Screen code composes tokens + components  

### What became consistent

| Element | Shared solution |
|---------|----------------|
| Primary actions | `LovenPrimaryButton` |
| Cards / grouped content | `LovenSurfaceCard` |
| Form fields | `LovenTextField`, `CheckoutFieldSection` (checkout-specific but tokenized) |
| Avatars | `LovenCircleAvatar` |
| Loading | `GalleryLoadingState` |
| Empty / error | `GalleryEmptyState` |
| Artwork previews | `LovenArtworkCard` (3 variants) |
| List thumbnails | `AppSizes.listThumbSize` (72px) |

### Technical benefit

Less duplicate code → fewer bugs when brand colors change → faster feature development.

### Design benefit

Users feel subconscious trust: “This app is coherent.” That matters for an art marketplace where **perceived quality** affects willingness to buy.

---

## 7. Navigation, AppBar Ownership, and Screen Structure

### `navigation_screen.dart` — the shell

**Path:** `features/navigation/view/Screens/navigation_screen.dart`

**Plain English:** The **main app frame** after boot — holds four tabs in an `IndexedStack` [shows one tab at a time while keeping others alive]:

| Index | Tab | Screen |
|-------|-----|--------|
| 0 | Home | `HomeScreen` |
| 1 | Favorites | `FavoritesScreen` (login required) |
| 2 | Cart | `CartScreen` (login required) |
| 3 | Account | `AccountScreen` (guest or signed-in) |

**Optional `accountChild`:** When set, tab 3 shows a **different screen** instead of `AccountScreen` (e.g. Order History, Incoming Orders, Edit Account).

### `navigation_widget.dart` — bottom bar

**Path:** `features/navigation/view/widget/navigation_widget.dart`

**Plain English:** Floating glass-style bottom navigation + artist FAB (create artwork).

**Important fix:** Tab switches use `NavigationBarCubit.navigateTo(index)` — **not** `context.go()` — to avoid janky full route reloads when changing tabs.

### AppBar ownership contract

Documented in `NavigationScreen` comments:

| Situation | Who owns the top header? |
|-----------|-------------------------|
| Home tab | **HomeScreen** — editorial header with logo, search, theme, notifications |
| Cart tab | **CartScreen** — own AppBar with item count |
| Favorites tab | **Shell** — LOVEN logo AppBar + theme toggle |
| Account tab (default) | **Shell** — logo AppBar |
| Account tab with `accountChild` | **Child screen** — own AppBar (orders, notifications, etc.) |

**Why split ownership?** Home needs an editorial hero header, not a generic logo bar. Forcing one global AppBar made Home feel like every other tab.

### Back navigation — `router_helpers.dart`

**Functions:**

- `lovenLeavePushedScreen(context)` — pop if possible; else go to `/profile`  
- `lovenPushedScreenBackLeading(context)` — standard back button widget  

**Plain English:** Many account-related routes use `context.go()` which **replaces** the URL stack. Back cannot “pop” → fallback sends user to **Account hub** (`/profile`), now wrapped in `NavigationScreen(initialIndex: 3)` so bottom nav appears.

**Recent fixes:**

- `/profile` returns to shell with account tab (not bare page without nav)  
- Incoming orders opened with `push` where appropriate  
- My artist profile: settings icon removed → back button  

### Inside shell vs pushed separately

| Pattern | Example | Behavior |
|---------|---------|----------|
| Main tabs | `/` Home | `NavigationScreen` shell |
| Shell + child on account tab | `/orders/history` | Same shell, tab 3 shows `OrderHistoryScreen` |
| Full-screen push | `/checkout` | Separate route on top of stack |
| Public browse | `/artist/:id` | Standalone `ArtistProfileScreen`, no bottom tabs |

---

## 8. Home / Discovery Screen — Deep Explanation

### Main files

| File | Role |
|------|------|
| `features/home/View/Screens/home_screen.dart` | Main Home tab UI |
| `features/home/controller/bloc/home_bloc.dart` | Loads/filters artworks |
| `features/home/View/widgets/home_discover_hero.dart` | Featured hero carousel |
| `features/home/View/widgets/home_discover_artist_row.dart` | Horizontal artist avatars |
| `features/home/View/widgets/home_discover_masterpieces_mosaic.dart` | Mosaic grid section |
| `features/home/View/widgets/home_discover_section_header.dart` | Section titles |
| `features/home/View/widgets/home_artwork_opener.dart` | Alias to `openArtworkDetail` |

### What the user sees first

1. **Editorial header** — LOVEN branding, search entry, theme toggle, notifications badge  
2. **Hero** — large featured artwork rail  
3. **Discover sections** — masterpieces mosaic, artist row, category/genre exploration  
4. **Floating bottom nav** — always visible (shell)

### Why section order matters

Home tells a story: **inspire → browse artists → explore collections → refine search**. Transactional actions (cart) are available but not the first visual impression.

### Search and genre sheets

Tapping search opens a **bottom sheet** for text search and category chips. Filtering uses `HomeBloc` → `FilterArtworks` event. Active filters show a `GalleryChip` with clear action.

### Connection to shared cards

Home uses `LovenArtworkCard` variants (`overlay` in rails, `grid` in mosaic) — not custom one-off cards.

### Old problems vs improvements

| Old problem | Improvement |
|-------------|-------------|
| Inconsistent artwork tiles | Unified `LovenArtworkCard` |
| Weak loading/empty | `GalleryLoadingState` / `GalleryEmptyState` |
| Tab navigation jank | Cubit-based tab switch |
| Artist avatars broken/missing | `LovenCircleAvatar` with image fallback |

### What to say in a discussion

> “Home is designed as an editorial discovery surface, not a product grid. It uses shared artwork cards and standardized empty/loading states. The shell deliberately does not impose a generic AppBar on Home — Home owns its own header.”

---

## 9. The Artwork Presentation Layer

### `LovenArtworkCard`

**Path:** `core/widgets/loven_artwork_card.dart`

**Plain English:** The **standard way to show an artwork preview** anywhere in the app.

### Three variants

| Variant | Visual style | Typical use |
|---------|--------------|-------------|
| **`overlay`** | Image with gradient + title on image | Home hero rails, promotional tiles |
| **`grid`** | Image on top, metadata below | Masterpieces mosaic, artwork grids |
| **`compact`** | Small thumbnail + title + price in a row | Dense lists (where used) |

### `artwork_grid_widget.dart`

**Path:** `features/artwork/view/widgets/artwork_grid_widget.dart`

Reusable grid of artworks using `LovenArtworkCardVariant.grid` — used on artist profile and similar surfaces.

### `openArtworkDetail()`

Opens `ArtDetailsScreen` as bottom sheet — single entry point prevents “sometimes full page, sometimes sheet” confusion.

### Removed legacy art card files

Older per-screen card implementations were replaced by `LovenArtworkCard`. Git history shows removal of duplicate dashboard/home card experiments (`dashboard_page.dart` widgets in multiple folders).

### Why this layer matters

**Technically:** One place to fix favorite button, tap behavior, image loading.  
**Visually:** Art looks the same whether you find it on Home, Favorites, or Artist Profile.

---

## 10. Detailed Screen-by-Screen Explanation of the Entire App

> **Legend for “Status” column:**  
> **Strong** = polished, aligned with design system  
> **Good** = functional, mostly consistent  
> **Partial** = works but backend/UI mismatch or legacy patterns  
> **Legacy** = older patterns, admin cluster especially  

---

### 10.1 Splash

| | |
|---|---|
| **Route** | `/splash` |
| **File** | `features/splash/splash_screen.dart` |
| **Purpose** | Brand moment on cold start; minimum display duration |
| **User sees** | Animated LOVEN logo on warm canvas color |
| **Logic** | UI only — **router redirect policy** decides next screen (onboarding, home, login) |
| **Shared tokens** | `AppColors.canvas` |
| **Navigation** | Automatic — user does not tap |
| **Say in meeting** | “Splash is purely presentational; routing is centralized in the router, not hard-coded in the widget.” |
| **Status** | **Strong** |

---

### 10.2 Onboarding

| | |
|---|---|
| **Route** | `/onboarding` |
| **File** | `features/splash/onboarding_screen.dart` |
| **Purpose** | First-run introduction for new guests |
| **Navigation** | After completion → Home |
| **Status** | **Good** |

---

### 10.3 Navigation Shell

| | |
|---|---|
| **Route** | `/` (Home route hosts shell), also used by `/cart`, `/profile`, many `/orders/*`, etc. |
| **Files** | `navigation_screen.dart`, `navigation_widget.dart`, `navigation_bar_cubit.dart` |
| **Purpose** | Persistent bottom navigation between main destinations |
| **Special** | Artist role shows center FAB for create artwork |
| **Status** | **Strong** (after tab-switch fix) |

---

### 10.4 Home / Discovery

See **Section 8**.  
**Status:** **Strong** — flagship redesigned surface.

---

### 10.5 Favorites

| | |
|---|---|
| **Route** | Tab index 1 inside `/` shell |
| **File** | `features/favorites/view/screens/favorites_screen.dart` |
| **Purpose** | Saved artworks for signed-in users |
| **Guest** | “Sign in to view your favorites” gate |
| **States** | Loading / empty / grid of artwork cards |
| **Navigation** | Tap artwork → `openArtworkDetail` |
| **Status** | **Good** |

---

### 10.6 Cart

| | |
|---|---|
| **Route** | Tab index 2; also `/cart` → shell on cart tab |
| **File** | `features/cart/view/screens/cart_screen.dart` |
| **Purpose** | Review items, adjust quantity, proceed to checkout |
| **Layout** | List of `_CartItemCard` + summary footer |
| **Shared widgets** | `LovenSurfaceCard`, `LovenArtworkImage`, `LovenPrimaryButton`, `GalleryLoadingState`, `GalleryEmptyState` |
| **Navigation** | Checkout → `context.push('/checkout', extra: cart)` |
| **Status** | **Good** |

---

### 10.7 Checkout

| | |
|---|---|
| **Route** | `/checkout` |
| **File** | `features/cart/view/screens/checkout_screen.dart` |
| **Supporting widgets** | `checkout_account_step.dart`, `payment_step.dart`, `review_step.dart`, `checkout_footer.dart`, `checkout_stepper.dart`, `checkout_shared.dart`, `review_widgets.dart` |
| **Purpose** | Three-step honest checkout (no fake shipping/payment fields) |
| **Steps** | 1. **Account** — shows signed-in identity 2. **Confirm** — explains checkout reality 3. **Review** — cart lines + totals |
| **On success** | Clears cart → refreshes Home artworks → `/confirm-order` success screen |
| **Important design decision** | Backend does not store shipping/customer extended data yet — UI does **not** pretend to collect it |
| **Status** | **Good / honest MVP** |

---

### 10.8 Order Success

| | |
|---|---|
| **Route** | `/confirm-order` |
| **File** | `features/order/view/screens/order_success_screen.dart` |
| **Purpose** | Thank user, show order reference/count/total, actions to Home or Order History |
| **Replaces** | Old snackbar + redirect home; old `confirm_order_screen` concept |
| **Status** | **Strong** |

---

### 10.9 Artwork Detail (bottom sheet)

| | |
|---|---|
| **Route** | Not a route — modal bottom sheet |
| **File** | `features/home/View/widgets/art_details_screen.dart` |
| **Opened via** | `openArtworkDetail()` |
| **User sees** | Large image, title, artist, description, availability, price, quantity stepper, Add to cart |
| **Behavior** | Refreshes artwork from API on open (stock/sold-out accuracy); sold-out disables purchase |
| **Dialogs** | Report artwork dialog |
| **Status** | **Good** |

---

### 10.10 Artists List

| | |
|---|---|
| **Route** | `/artists` |
| **File** | `features/home/View/Screens/artists_list_screen.dart` |
| **Purpose** | Browse all artists |
| **Shared** | `LovenCircleAvatar`, loading/empty states |
| **Navigation** | Tap artist → public artist profile route |
| **Status** | **Good** |

---

### 10.11 Artworks List (by type)

| | |
|---|---|
| **Route** | `/artworks-list/:type` |
| **File** | `features/home/View/Screens/artworks_list_screen.dart` |
| **Purpose** | “See all” lists from Home sections |
| **States** | Loading, empty, retry via `FetchHomeData` |
| **Status** | **Good** |

---

### 10.12 Artist Profile — Owner (“My profile”)

| | |
|---|---|
| **Route** | `/my-profile` |
| **Files** | `artist_profile_screen.dart`, `artist_profile_hero_widget.dart`, `artist_about_card.dart`, `artwork_grid_widget.dart` |
| **Wrapped in** | `NavigationScreen` with `accountChild` |
| **Purpose** | Artist’s own storefront — hero, stats, edit CTA, artwork grid |
| **AppBar** | “My profile” + **back button** (settings icon removed) |
| **Separate from** | Account details (`/profile/edit`) — intentional product split |
| **Status** | **Good** |

---

### 10.13 Artist Profile — Public

| | |
|---|---|
| **Route** | `/artist/:artistId` |
| **File** | Same `ArtistProfileScreen` with `artistProfileId` set |
| **Purpose** | Buyer views an artist’s public portfolio |
| **Navigation** | From Home artist row, artists list |
| **Status** | **Good** |

---

### 10.14 Edit Artist Profile

| | |
|---|---|
| **Route** | `/artist-profile/edit` (requires `ArtistModel` extra) |
| **File** | `features/artist_profile/view/screens/edit_artist_profile_screen.dart` |
| **Purpose** | Edit artist storefront fields, bio, images |
| **Back** | `lovenPushedScreenBackLeading` |
| **Status** | **Good** |

---

### 10.15 Account Hub

| | |
|---|---|
| **Route** | `/profile` (also account tab in shell) |
| **File** | `features/account/view/screens/account_screen.dart` |
| **Purpose** | Single hub for guest + signed-in settings and links |
| **Sections** | Profile header, account details, artist tools (if artist), activity, support, logout |
| **Guest view** | Separate `_GuestAccountView` with login CTA |
| **Important links** | Edit account, My artist profile, Incoming orders, Order history, Change password, Feedback |
| **Status** | **Strong** |

---

### 10.16 Edit Account (“Account details”)

| | |
|---|---|
| **Route** | `/profile/edit` |
| **File** | `features/account/view/screens/edit_account_screen.dart` |
| **Purpose** | Name, email display, profile photo — **user account**, not artist storefront |
| **Wrapped in** | Navigation shell + `accountChild` |
| **Shared** | `CheckoutFieldSection`, `LovenTextField`, `LovenPrimaryButton` |
| **Status** | **Good** |

---

### 10.17 Notifications

| | |
|---|---|
| **Route** | `/notifications` |
| **File** | `features/notifications/view/screens/notifications_screen.dart` |
| **Tile widget** | `notification_list_tile.dart` |
| **Purpose** | In-app notification list |
| **Navigation** | `NotificationRouteResolver` → orders, cart, home depending on type |
| **Back** | `lovenPushedScreenBackLeading` |
| **Status** | **Good** |

---

### 10.18 Orders — Incoming (artist)

| | |
|---|---|
| **Route** | `/orders/incoming` (requires artist profile ID extra) |
| **File** | `features/order/view/screens/incoming_orders_screen.dart` |
| **Purpose** | Artist fulfills buyer orders — status updates |
| **Navigation** | Opened via `push` from account; back returns to account |
| **Status** | **Good** |

---

### 10.19 Orders — History (buyer)

| | |
|---|---|
| **Route** | `/orders/history` |
| **File** | `features/order/view/screens/order_history_screen.dart` |
| **Purpose** | Buyer’s past orders with item thumbnail strip |
| **Widget** | `order_item_display.dart` for thumbnails |
| **Navigation** | Tap order → `/orders/details` |
| **Status** | **Good** (after items enrichment) |

---

### 10.20 Orders — Details

| | |
|---|---|
| **Route** | `/orders/details` |
| **File** | `features/order/view/screens/order_details_screen.dart` |
| **Purpose** | Full order view — items with images, tracking block, totals |
| **Behavior** | Fetches order by ID from API on load |
| **Status** | **Good** |

---

### 10.21 Location & Address Form

| | |
|---|---|
| **Routes** | `/location`, `/location/address-form` |
| **Files** | `location_screen.dart`, `address_form_screen.dart` |
| **Purpose** | Location/address UI (partially ahead of full backend shipping support) |
| **Status** | **Partial** — UI exists; checkout intentionally does not depend on saved addresses yet |

---

### 10.22 Feedback

| | |
|---|---|
| **Route** | `/feedback` |
| **File** | `features/feedback/view/screens/feedback_screen.dart` |
| **Purpose** | User sends app feedback |
| **Shared** | Tokenized form patterns |
| **Status** | **Good** |

---

### 10.23 Verification Request (artist)

| | |
|---|---|
| **Route** | `/verification-request` |
| **File** | `features/verification_request/view/screens/verification_request_screen.dart` |
| **Purpose** | Artist applies for verified badge |
| **Status** | **Good** (recent token alignment) |

---

### 10.24 Auth — Login

| | |
|---|---|
| **Route** | `/login` |
| **File** | `features/auth/view/screens/login_page.dart` |
| **Purpose** | Email/password sign-in |
| **Shared** | `LovenPrimaryButton`, `LovenTextField`, design tokens |
| **Status** | **Good** |

---

### 10.25 Auth — Signup

| | |
|---|---|
| **Route** | `/signup`, `/auth` |
| **File** | `features/auth/view/screens/signup_page.dart` |
| **Purpose** | Register new account |
| **Status** | **Good** |

---

### 10.26 Auth — Verify Email

| | |
|---|---|
| **Route** | `/signup/verify-email` |
| **File** | `features/auth/view/screens/signup_verification_email_page.dart` |
| **Purpose** | Email verification step in signup funnel |
| **Status** | **Good** |

---

### 10.27 Auth — Signup Success

| | |
|---|---|
| **Route** | `/signup/success` |
| **File** | `features/auth/view/screens/signup_success_page.dart` |
| **Purpose** | Confirmation after verification — CTA to login |
| **Pattern** | Full-screen success with icon circle — same family as order success |
| **Status** | **Strong** |

---

### 10.28 Auth — Forgot Password

| | |
|---|---|
| **Route** | `/forgot-password` |
| **File** | `features/auth/view/screens/forgot_password_page.dart` |
| **Status** | **Good** |

---

### 10.29 Auth — Password Changed / Forgot Success

| | |
|---|---|
| **Route** | `/forgot-password/success` |
| **File** | `features/auth/view/screens/password_changed_page.dart` |
| **Status** | **Good** |

---

### 10.30 Auth — Change Password (signed in)

| | |
|---|---|
| **Route** | `/change-password` |
| **File** | `features/auth/view/screens/change_password_screen.dart` |
| **Back** | Standard pushed-screen back |
| **Status** | **Good** |

---

### 10.31 Removed auth screens (historical)

| File | Note |
|------|------|
| `new_password_page.dart` | Removed — flow consolidated |
| `verification_code_page.dart` | Removed |
| `edit_profile_screen.dart` (in auth/) | Replaced by account + artist edit split |

---

### 10.32 Create Artwork

| | |
|---|---|
| **Route** | `/artworks/create` |
| **File** | `features/artwork/view/screens/create_artwork_screen.dart` |
| **Purpose** | Artist uploads new listing |
| **Opened from** | Artist FAB on bottom nav |
| **Status** | **Good** |

---

### 10.33 Admin Screens

| Route | File | Purpose |
|-------|------|---------|
| `/admin` | `admin_dashboard_screen.dart` | Stats overview |
| `/admin/verification-requests` | `admin_verification_requests_screen.dart` | Review artist verification |
| `/admin/reports` | `admin_reports_screen.dart` | Content reports |
| `/admin/users` | `admin_users_screen.dart` | User management |

**Admin widgets:** `admin_stat_card.dart`, `admin_action_tile.dart`, `admin_user_card.dart`, `admin_section_header.dart`, `verification_status_chip.dart`, `empty_requests_widget.dart`

**Status:** **Legacy / functional** — separate visual language from consumer app; acceptable for internal admin but not redesigned to full gallery aesthetic.

---

### 10.34 Important Bottom Sheets & Dialogs

| UI | Trigger | File / function |
|----|---------|-----------------|
| Artwork detail sheet | Tap artwork | `openArtworkDetail()` |
| Home search sheet | Tap search on Home | Inside `home_screen.dart` |
| Logout confirm | Account logout | `account_screen.dart` dialog |
| Report artwork | Flag on art detail | `art_details_screen.dart` |
| ~~Delivery date picker~~ | ~~Removed~~ | `delivery_date_bottom_sheet.dart` deleted |

---

## 11. How Screens Connect Into User Journeys

### Journey A — Discover → Buy

```
Home (browse)
  → tap artwork → Art Details sheet
  → Add to cart
  → Cart tab
  → Checkout (account → confirm → review)
  → Order Success
  → optional: Order History
```

**Home artwork stock** refreshes after order so sold-out state updates.

### Journey B — Discover → Artist

```
Home artist row / Artists list
  → Public Artist Profile (/artist/:id)
  → tap artwork → Art Details
```

### Journey C — Account management

```
Account tab
  → Account details (edit name/photo)
  OR My artist profile (storefront)
  OR Change password
```

**Key product rule:** Account details ≠ Artist profile (different data, different screens).

### Journey D — Artist seller

```
Account tab
  → My artist profile
  → Edit artist profile
  → Incoming orders
  → (optional) Verification request
  → Create artwork (FAB)
```

### Journey E — Notifications

```
Notification tap
  → Resolver routes to order detail, cart, or home
```

### Journey F — Auth

```
Guest Account → Login/Signup
  → Verify email → Signup success → Login
  → Home shell
```

---

## 12. The Most Important Design Decisions and Why They Were Made

| Decision | Why |
|----------|-----|
| **Design tokens** | One change updates entire app; eliminates “similar but different” colors |
| **Shared widgets** | Buttons/cards/empty states behave identically — user trust |
| **Editorial Home** | Differentiates LOVEN as art marketplace, not commodity shop |
| **`LovenArtworkCard` variants** | Same data, flexible layout (rail vs grid vs row) without duplicating logic |
| **Split Account vs Artist profile** | User identity vs seller storefront are different mental models |
| **Split AppBar ownership** | Home needs custom header; cart needs own title; shell logo elsewhere |
| **Standardized loading/empty/error** | Never leave user staring at blank white screen |
| **Honest checkout** | UI credibility — don’t collect shipping/payment UI backend can’t store/process yet |
| **Central routing (`AppRoutes`)** | One registry for paths and auth guards |
| **`push` vs `go` discipline** | Back button behaves predictably |
| **Bottom sheet for art detail** | Keeps browse context — user doesn’t lose Home scroll position |

---

## 13. Removed, Replaced, or Archived UI Files — and Why

| File | What it did | Problem | Replaced by | Benefit |
|------|-------------|---------|-------------|---------|
| `upload_artwork_preview.dart` | Preview UI for upload | Unused duplicate | Create artwork screen flow | Less dead code |
| `delivery_date_bottom_sheet.dart` | Delivery date picker | Unsupported / unused in real checkout | Removed | No false delivery promises |
| `shipping_step.dart` | Fake full shipping form | Backend doesn’t persist shipping | `checkout_account_step.dart` | Honest checkout |
| `confirm_order_screen.dart` (legacy) | Old confirm UI | Redirected to cart / outdated | `order_success_screen.dart` at `/confirm-order` | Proper success moment |
| `settings_screen.dart` | Separate settings | Duplicate of account hub | `account_screen.dart` | Single account surface |
| `guest_settings_screen.dart` | Guest settings duplicate | Fragmented guest UX | Account guest view | One entry point |
| `edit_profile_screen.dart` (auth/) | Combined edit | Confused account vs artist | `edit_account_screen.dart` + `edit_artist_profile_screen.dart` | Clear user mental model |
| `profile_screen.dart` (auth/) | Old profile | Replaced by account hub | `account_screen.dart` | Consolidation |
| `new_password_page.dart` | Extra password step | Flow simplified | Forgot password + change password pages | Shorter funnel |
| `verification_code_page.dart` | OTP UI | Flow changed | Email verification page | Alignment with Firebase/backend |
| `logout_page.dart` | Dedicated logout screen | Unnecessary route | Logout dialog on account | Simpler UX |
| Multiple `dashboard_page.dart` | Old home dashboards | Pre-discover redesign | `home_screen.dart` discover layout | Modern editorial home |
| Old per-feature art cards | Different card UIs | Visual inconsistency | `LovenArtworkCard` | Unified art presentation |

**Note:** `README.md` may still list some removed filenames — trust **`lib/` + this doc** for current truth.

---

## 14. Master Reference Table — File → Purpose → Used By → Status

### Design system (`core/res/`)

| File path | Main symbol | Responsibility | Used by | Status |
|-----------|-------------|----------------|---------|--------|
| `core/res/design_system.dart` | export barrel | Single import for tokens | All UI | shared |
| `core/res/theme/app_colors.dart` | `AppColors` | Color tokens | Theme, widgets, screens | shared |
| `core/res/theme/app_theme.dart` | `AppTheme` | Light/dark themes | `LovenApp` | shared |
| `core/res/typography/app_text_styles.dart` | `AppTextStyles` | Typography tokens | Cards, prices | shared |
| `core/res/dimensions/app_spacing.dart` | `AppSpacing` | Spacing scale | All layouts | shared |
| `core/res/dimensions/app_radius.dart` | `AppRadius` | Corner radii | Cards, inputs | shared |
| `core/res/dimensions/app_sizes.dart` | `AppSizes` | Fixed sizes | Nav, thumbs, avatars | shared |
| `core/res/dimensions/app_shadows.dart` | `AppShadows` | Shadows | Floating nav | shared |
| `core/res/dimensions/app_durations.dart` | `AppDurations` | Animation timing | Splash, transitions | shared |

### Shared widgets (`core/widgets/`)

| File path | Main symbol | Responsibility | Used by | Status |
|-----------|-------------|----------------|---------|--------|
| `loven_widgets.dart` | export barrel | Widget import hub | Features | shared |
| `loven_primary_button.dart` | `LovenPrimaryButton` | Primary CTA | Auth, checkout, success | shared |
| `loven_secondary_button.dart` | `LovenSecondaryButton` | Secondary CTA | Checkout, details | shared |
| `loven_text_field.dart` | `LovenTextField` | Form input | Auth, account, forms | shared |
| `loven_surface_card.dart` | `LovenSurfaceCard` | Card container | Cart, orders, account | shared |
| `loven_circle_avatar.dart` | `LovenCircleAvatar` | Avatar | Home, artists, account | shared |
| `loven_artwork_card.dart` | `LovenArtworkCard` | Art preview variants | Home, grids, favorites | shared |
| `gallery_loading_state.dart` | `GalleryLoadingState` | Loading UI | Lists, home | shared |
| `gallery_empty_state.dart` | `GalleryEmptyState` | Empty/error UI | Lists, home | shared |
| `gallery_chip.dart` | `GalleryChip` | Filter chip | Home | shared |
| `gallery_section_header.dart` | `GallerySectionHeader` | Section title row | Home | shared |
| `artwork_detail_opener.dart` | `openArtworkDetail` | Open art sheet | Browse surfaces | shared |

### Router (`core/router/`)

| File path | Main symbol | Responsibility | Status |
|-----------|-------------|----------------|--------|
| `app_routes.dart` | `AppRoutes` | Path constants + auth guards | shared |
| `app_router.dart` | `AppRouter` | GoRouter assembly | active |
| `redirect_policy.dart` | `resolveRedirect` | Splash/auth redirects | active |
| `router_helpers.dart` | back helpers | Pop or fallback profile | shared |
| `routes/*.dart` | route builders | Wire paths → screens | active |

### Navigation feature

| File path | Main symbol | Responsibility | Status |
|-----------|-------------|----------------|--------|
| `navigation/view/Screens/navigation_screen.dart` | `NavigationScreen` | Tab shell | active |
| `navigation/view/widget/navigation_widget.dart` | `NavigationWidget` | Bottom nav + FAB | active |
| `navigation/controller/cubit/navigation_bar_cubit.dart` | `NavigationBarCubit` | Tab index state | active |

### Home feature

| File path | Main symbol | Responsibility | Status |
|-----------|-------------|----------------|--------|
| `home/View/Screens/home_screen.dart` | `HomeScreen` | Discover home | active |
| `home/View/widgets/home_discover_hero.dart` | hero widget | Featured rail | feature |
| `home/View/widgets/home_discover_artist_row.dart` | artist row | Artist avatars | feature |
| `home/View/widgets/home_discover_masterpieces_mosaic.dart` | mosaic | Grid section | feature |
| `home/View/widgets/art_details_screen.dart` | `ArtDetailsScreen` | Art detail sheet | feature |
| `home/controller/bloc/home_bloc.dart` | `HomeBloc` | Artwork fetch/filter | active |

### Cart / Checkout feature

| File path | Main symbol | Responsibility | Status |
|-----------|-------------|----------------|--------|
| `cart/view/screens/cart_screen.dart` | `CartScreen` | Shopping cart | active |
| `cart/view/screens/checkout_screen.dart` | `CheckoutScreen` | 3-step checkout | active |
| `cart/view/widgets/checkout_*.dart` | step widgets | Checkout UI parts | feature |
| `order/view/screens/order_success_screen.dart` | `OrderSuccessScreen` | Post-checkout | active |
| `order/view/widgets/order_item_display.dart` | order item UI | Thumbnails in orders | feature |

### Account / Artist / Auth / Admin

| File path | Screen | Status |
|-----------|--------|--------|
| `account/view/screens/account_screen.dart` | Account hub | active |
| `account/view/screens/edit_account_screen.dart` | Edit account | active |
| `artist_profile/view/screens/artist_profile_screen.dart` | Artist profile | active |
| `artist_profile/view/screens/edit_artist_profile_screen.dart` | Edit artist | active |
| `auth/view/screens/login_page.dart` | Login | active |
| `auth/view/screens/signup_page.dart` | Signup | active |
| (+ other auth pages listed in §10) | Auth funnel | active |
| `admin/view/screens/*.dart` | Admin tools | legacy/active |

---

## 15. Summary

### “What is the design system in your app?”

> “We centralized colors, spacing, typography, and themes in `core/res/`. Screens import one design-system file instead of hard-coding values. That keeps LOVEN visually consistent and makes brand updates much faster.”

### “Why did you redesign the Home screen?”

> “Home is the first impression. We moved it from a generic product list to an editorial Discover layout — hero, sections, artist row — because LOVEN is an art marketplace, not a discount shop. It uses shared artwork cards and standard loading/empty states.”

### “Why do you use shared widgets?”

> “Shared widgets like `LovenPrimaryButton` and `LovenSurfaceCard` mean every screen speaks the same visual language. Users learn the app faster, and developers don’t rebuild the same button five times with slightly different styling.”

### “Why were some files removed?”

> “We removed duplicate or misleading UI — fake shipping forms, unused preview sheets, old settings screens, legacy art cards — and replaced them with honest flows and one shared artwork card component. That reduces confusion for users and maintenance cost for the team.”

### “How did you improve consistency?”

> “Three layers: tokens for measurements and colors, shared widgets for components, and screen guidelines for AppBar ownership and empty/loading states. New screens compose those pieces instead of inventing local styles.”

### “What are the strongest parts of the UI now?”

> “Home Discover experience, the shared artwork card layer, standardized empty/loading states, the account hub consolidation, and honest checkout + order success flow.”

### “What problems still remain?”

> “Admin screens use an older visual cluster. Location/address UI exists but isn’t fully wired into checkout because backend shipping persistence isn’t ready. README still mentions some removed file names. Arabic/i18n is not implemented — all UI copy is English.”

### “Why is this structure better than before?”

> “Before, each screen was styled independently — inconsistent buttons, duplicate cards, confusing profile/settings/edit flows. Now the app has a clear hierarchy: tokens → shared widgets → feature screens → navigation shell. That’s how professional products scale UI without breaking identity.”

---

## 16. Beginner Cheat Sheet

1. **Widget** = any UI piece on screen.  
2. **Screen** = full page like Home or Cart.  
3. **Design system** = shared colors, spacing, fonts in `core/res/`.  
4. **Shared widgets** = reusable buttons, cards, empty states in `core/widgets/`.  
5. **Theme** = app-wide default styling; supports light/dark.  
6. **Route** = URL path that opens a screen (`/cart`, `/login`).  
7. **Navigation shell** = bottom tabs frame (`NavigationScreen`).  
8. **Home owns its own header** — not the generic shell AppBar.  
9. **Cart owns its own AppBar** too.  
10. **Favorites & default Account** use shell logo header.  
11. **`LovenArtworkCard`** = standard artwork preview (3 variants).  
12. **Art detail opens as bottom sheet**, not always a new page.  
13. **Account details** and **Artist profile** are intentionally separate.  
14. **Checkout is honest** — no fake shipping/payment collection.  
15. **Order success** is a dedicated screen at `/confirm-order`.  
16. **Loading** = `GalleryLoadingState`; **empty** = `GalleryEmptyState`.  
17. **Bloc/Cubit** = logic layer; UI listens and updates.  
18. **Back behavior** uses pop when possible, else Account hub.  
19. **`/profile`** now opens account tab **with** bottom navigation.  
20. **Incoming orders** should open with push so back feels natural.  
21. **My artist profile** has back button, not settings icon.  
22. **Sold-out** refreshes when opening artwork detail after purchase.  
23. **Order history** shows item thumbnails when backend returns items.  
24. **Admin UI** is functional but not fully redesigned.  
25. **Removed files** = less duplicate/misleading UI, not lost features.  
26. **Visual consistency** = users trust the app looks like one product.  
27. **Editorial Home** = gallery feel, not supermarket grid.  
28. **Tokens beat hard-coded numbers** for long-term maintenance.  
29. **README may be stale** — trust `lib/` structure and this doc.  
30. **This handbook** = your map to discuss UI confidently without reading Dart.

---

*End of UI/UX Architecture Guide*
