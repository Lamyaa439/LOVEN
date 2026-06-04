# LOVEN Flutter Frontend Map

**Project path:** `MVP/frontend/loven` (Flutter package name: `loven`).

This README is a **structured file and folder map** for the LOVEN MVP Flutter frontend. The codebase went through **phased architecture cleanup** (thin entry, `lib/app/` composition, modular router, frozen redirect policy, auth/account split, `AppRoutes` navigation). Use this document to find **ownership and responsibilities** quickly — not as full product or API documentation.

---
## High-level structure

```
loven/
├── lib/
│   ├── main.dart                 # Entry: bootstrap + runApp
│   ├── firebase_options.dart     # Generated Firebase config
│   ├── app/                      # Bootstrap, DI graph, root widget
│   ├── core/                     # Shared infrastructure
│   │   ├── config/               # Env / base URL
│   │   ├── error/                # AppException, Result (optional pattern)
│   │   ├── network/              # ApiClient, ApiEndpoints
│   │   ├── storage/              # Tokens, app flags
│   │   ├── router/               # GoRouter, routes, redirect policy
│   │   ├── res/theme/            # Colors, ThemeData
│   │   └── theme/                # ThemeBloc
│   └── features/                 # Product features (data / controller / view)
│       ├── auth/                 # Session, credentials, password flows
│       ├── account/              # Account hub & edit profile UI
│       ├── splash/               # Splash + onboarding
│       ├── navigation/           # Bottom shell
│       ├── home/                 # Home, discovery lists, settings tab
│       ├── admin/                # Admin dashboards
│       ├── artist_profile/       # Artist storefront
│       ├── artwork/              # Artwork catalog / create
│       ├── cart/                 # Cart & checkout
│       ├── order/                # Orders
│       ├── location/             # Addresses
│       ├── favorites/            # Favorites tab
│       ├── feedback/             # Feedback
│       ├── report/               # Reports (repo; admin-related)
│       ├── notifications/        # Notifications screen
│       └── verification_request/ # Artist verification flow
├── test/                         # Unit tests (auth state, redirect policy)
├── assets/                       # .env, images, fonts (see pubspec.yaml)
├── pubspec.yaml
└── firebase.json                 # Firebase project wiring
```

Excluded from this map: `build/`, `.dart_tool/`, `ios/Pods/`, `android/build/`, platform runner boilerplate, `widgetbook/` (design sandbox).

---

## Short overview

Hand-written source lives under **`lib/`**, grouped into **`app/`** (bootstrap + DI + root widget), **`core/`** (config, network, storage, router, theme), and **`features/`** (product domains). Session restore runs once from `AppDependencies`; JWT refresh is owned by `ApiClient`; navigation paths are centralized in `AppRoutes`.

**Excluded from per-file mapping:** `build/`, `.dart_tool/`, `ios/Pods/`, `android/build/`, generated caches, and most platform runner files. **`widgetbook/`** is a separate design sandbox — not part of the main app map.

---

## Folder-by-folder project map

### `lib/`

Root of all Dart application code. Contains entrypoint, Firebase options, `app/`, `core/`, and `features/`.

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `main.dart` | `main()` | Calls `bootstrap()`, then `runApp(LovenApp(...))` | **Stable** | Intentionally thin — no DI or routing here |
| `firebase_options.dart` | Generated Firebase config | Platform Firebase initialization values | **Stable** | Generated; do not hand-edit |

**Should live here:** only top-level entry + generated platform config.  
**Should not live here:** repositories, cubits, route tables, or feature UI.

---

### `lib/app/`

Application **composition layer**: async startup, singleton dependency graph, global providers, `MaterialApp.router`.

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `bootstrap.dart` | `bootstrap()` | `WidgetsFlutterBinding`, `AppEnv.load`, Firebase init, `AppPreferences.init` | **Stable** | No repositories |
| `dependencies.dart` | `AppDependencies` factory | Builds `ApiClient`, repos, `AuthCubit`, `AppRouter`; wires session-expired callback; **single** `restoreSession()` call | **Sensitive** | Grows when adding global singletons |
| `app.dart` | `LovenApp` | `MultiRepositoryProvider` / `MultiBlocProvider`, theme, `MaterialApp.router` | **Sensitive** | Large provider tree; `ChangeNotifierProvider` for splash notifier |

**Should live here:** app-wide wiring only.  
**Should not live here:** feature screens, business rules, or route path literals.

---

### `lib/core/`

Shared infrastructure used across features. No product screens.

**Subfolders:** `config/`, `error/`, `network/`, `storage/`, `router/` (+ `router/routes/`), `res/theme/`, `theme/`.

**Should live here:** cross-cutting contracts (env, HTTP, tokens, routes, redirect rules).  
**Should not live here:** feature-specific UI or domain models (except router’s dependency on `auth_state.dart` today).

---

### `lib/core/config/`

Environment and runtime configuration.

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `app_env.dart` | `AppEnv` | Loads bundled `assets/.env` via `flutter_dotenv`; exposes `baseUrl`, timeouts | **Stable** | Single env entry point |

---

### `lib/core/error/`

Shared error types and optional result wrapper.

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `app_exception.dart` | `AppException` | Canonical app/network error type for repositories | **Stable** | |
| `result.dart` | `Result<T>` | Success/failure wrapper pattern | **Transitional** | Defined but not used app-wide — **acceptable for now** |

---

### `lib/core/network/`

HTTP client and API path registry.

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `api_endpoints.dart` | `ApiEndpoints` | All backend path constants (auth, account, cart, orders, admin, etc.) | **Stable** | Includes `currentUser = '/account/me'` |
| `api_client.dart` | `ApiClient`, interceptors | Dio client, auth headers, **sole `POST /refresh` on 401** | **Stable** | Session-expired callback injected from app layer |
| `api_constants.dart` | Re-exports + typedef | Barrel: exports `ApiClient`, `ApiEndpoints`; `typedef ApiConstants = ApiEndpoints` | **Transitional** | 9 feature repos still import this file |

---

### `lib/core/storage/`

Local persistence for tokens and lightweight flags.

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `token_storage.dart` | `TokenStorage` | Secure storage for access/refresh JWT; `clearAllTokens()` also removes legacy `user_role` key | **Stable** | **Does not store role** |
| `app_preferences.dart` | `AppPreferences` | `hasCompletedOnboarding` via `shared_preferences` | **Stable** | Used by redirect policy |

---

### `lib/core/router/`

GoRouter assembly, route registry, redirect policy, splash timing, router helpers.

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `app_routes.dart` | `AppRoutes` | Path constants, guard sets, path builders (`artistPath`, `artworksListPath`, `signupFromGuest`) | **Stable** | Update guard registry when adding protected routes |
| `redirect_policy.dart` | `resolveRedirect()` | Pure redirect matrix for `GoRouter.redirect` | **Stable** | Tested in `test/redirect_policy_test.dart`; imports `auth_state.dart` from features |
| `app_router.dart` | `AppRouter` | Builds `GoRouter` (initial route, refresh, redirect, route list) | **Stable** | ~57 lines — keep thin |
| `app_router_deps.dart` | `AppRouterDeps` | Repos/cubits needed by route builders | **Stable** | |
| `router_refresh.dart` | `GoRouterRefreshStream` | Rebuilds router when `AuthCubit` emits | **Stable** | |
| `router_helpers.dart` | Helpers | Invalid-route fallback; required `extra` string helper | **Stable** | |
| `splash_min_duration_notifier.dart` | `ChangeNotifier` | Minimum splash duration before leaving splash route | **Stable** | Provided via `ChangeNotifierProvider` in `app.dart` |

**Should live here:** routing infrastructure only.  
**Should not live here:** feature business logic or widgets (except route `builder` imports in `routes/`).

---

### `lib/core/router/routes/`

Route **modules** merged into `app_route_table.dart`. Each file returns a `List<RouteBase>`.

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `app_route_table.dart` | `buildAppRoutes()` | Concatenates all route modules in fixed order | **Sensitive** | Register new modules here |
| `startup_routes.dart` | Splash, legacy splash redirect, onboarding, home shell | Boot and main shell routes | **Stable** | |
| `account_routes.dart` | `/profile`, `/profile/edit` | Account hub + edit (widgets from `features/account`) | **Stable** | |
| `auth_routes.dart` | Auth/login/signup/password recovery routes | Credential flows under `features/auth` | **Stable** | |
| `admin_routes.dart` | `/admin/*` | Admin dashboard, verification list, reports placeholder | **Needs follow-up** | Session-only; **no admin role guard** on routes; route-scoped `VerificationRequestCubit` |
| `discovery_routes.dart` | Artists, artist profile, artworks list, settings, edit artist | Discovery and settings tab route | **Stable** | `settings` route → `settings_screen.dart` in home |
| `commerce_routes.dart` | Notifications, orders, cart shell, location, feedback, verification, create artwork | Commerce and utility routes | **Stable** | Also creates route-scoped `VerificationRequestCubit` for artist verification screen |

---

### `lib/core/res/theme/`

Visual theme tokens (colors + `ThemeData`).

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `app_colors.dart` | Color constants | Brand palette for light/dark | **Stable** | |
| `app_theme.dart` | `AppTheme` | `ThemeData` for light and dark modes | **Stable** | Used by `LovenApp` |

---

### `lib/core/theme/`

Runtime theme mode toggle (separate from static `ThemeData`).

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `theme_bloc.dart` | `ThemeBloc` | Toggles light/dark; consumed by navigation shell | **Stable** | Import from here, not `main.dart` |

**Note:** Theme is split across `core/res/theme/` (static) and `core/theme/` (bloc). **Acceptable for now.**

---

### `lib/features/`

Product features. Typical layout: `controller/` (or `controller/cubit/`), `data/`, `view/`, sometimes `model/`.

**Should live here:** feature UI, cubits/blocs, repositories, feature models.  
**Should not live here:** global router policy, env loading, or duplicate session restore.

---

### `lib/features/auth/`

**Session and credentials:** login, signup, password flows, `AuthCubit` / `AuthRepository`. Not the account hub UI (see `account/`).

#### `lib/features/auth/controller/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| *(no files at this level)* | — | Cubit lives in `controller/cubit/` | — | |

#### `lib/features/auth/controller/cubit/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `auth_state.dart` | `AuthState`, helpers | Session types (`AuthInitial`, `AuthGuest`, `AuthSuccess`, …); `authStateHasSession`, `authStateSessionUser` | **Stable** | Router contract; role on `UserModel.systemRole` |
| `auth_cubit.dart` | `AuthCubit` | Restore, login, logout, guest mode, profile hydrate/update, FCM hooks | **Sensitive** | No direct `TokenStorage`; still owns profile API via repository |

#### `lib/features/auth/data/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `models/user_model.dart` | `UserModel` | User DTO incl. `systemRole` | **Stable** | Canonical role in session state |

#### `lib/features/auth/data/repositories/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `auth_repository.dart` | `AuthRepository` | Login/register/logout, token persist, `restoreAuthenticatedUser`, **`GET/PATCH /account/me`** | **Needs follow-up** | Account UI moved out; account API still here |

#### `lib/features/auth/view/`

Screens only (no `widgets/` subfolder currently).

#### `lib/features/auth/view/screens/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `login_page.dart` | Login UI | Email/password login via `AuthCubit` | **Stable** | |
| `signup_page.dart` | Signup UI | Registration + role selection | **Stable** | |
| `signup_verification_email_page.dart` | Email step | Post-signup email verification entry | **Stable** | |
| `signup_success_page.dart` | Success UI | Post-signup; `context.go(AppRoutes.home)` | **Acceptable for now** | Redirect policy may also apply |
| `forgot_password_page.dart` | Forgot password | Starts recovery flow | **Stable** | |
| `verification_code_page.dart` | OTP UI | Code entry for recovery/signup | **Stable** | |
| `new_password_page.dart` | New password | Set password after code | **Stable** | |
| `password_changed_page.dart` | Confirmation | Navigates to login via `AppRoutes` | **Stable** | |
| `change_password_screen.dart` | Change password | Authenticated password change | **Stable** | |

---

### `lib/features/account/`

**Account hub UI** at `/profile` and `/profile/edit`. Uses `AuthCubit` for session and profile persistence today.

#### `lib/features/account/data/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| *(no files at `data/` root)* | — | Service under `data/services/` | — | |

#### `lib/features/account/data/services/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `profile_image_storage_service.dart` | Firebase upload helper | Profile image upload to Firebase Storage | **Stable** | |

#### `lib/features/account/view/`

#### `lib/features/account/view/screens/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `account_screen.dart` | Account hub | Guest + signed-in menus; logout via `AuthCubit`; links via `AppRoutes` | **Stable** | Primary profile tab destination |
| `edit_account_screen.dart` | Edit profile UI | Loads/updates user via `AuthCubit.loadCurrentUser` / `updateProfile` | **Sensitive** | Data still in `AuthRepository` |

---

### `lib/features/splash/`

Boot branding and first-run onboarding (no session restore).

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `splash_screen.dart` | Splash UI | Branding; calls `SplashMinDurationNotifier.markReady()` | **Stable** | Does not call `restoreSession` |
| `onboarding_screen.dart` | Onboarding carousel | Sets onboarding pref; navigates with `AppRoutes` | **Stable** | |

---

### `lib/features/navigation/`

Bottom navigation shell wrapping home, favorites, cart, profile tab.

#### `lib/features/navigation/controller/cubit/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `navigation_bar_cubit.dart` | Tab index cubit | Selected bottom-nav index | **Stable** | |
| `navigation_bar_state.dart` | State class | Index state for nav bar | **Stable** | |

#### `lib/features/navigation/view/`

#### `lib/features/navigation/view/Screens/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `navigation_screen.dart` | Shell scaffold | Hosts tab bodies; theme toggle; guest CTA uses `AppRoutes.auth` | **Stable** | Legacy `Screens/` casing |

#### `lib/features/navigation/view/widget/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `navigation_widget.dart` | Bottom bar UI | Tab bar widget | **Stable** | |

---

### `lib/features/home/`

Home feed, discovery lists, art details, settings tab route, guest settings. Mixed folder naming (`View/` vs `screens/`).

#### `lib/features/home/controller/bloc/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `home_bloc.dart` | `HomeBloc` | Loads home feed data via `ArtworkRepository` | **Stable** | |
| `home_event.dart` | Events | `FetchHomeData`, etc. | **Stable** | |
| `home_state.dart` | States | Loading/success/error for home | **Stable** | |

#### `lib/features/home/View/Screens/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `home_screen.dart` | Home tab | Featured/new arrivals, notifications, artist links | **Stable** | Uses `AppRoutes` builders |
| `artists_list_screen.dart` | Artists list | Browse artists | **Stable** | |
| `artworks_list_screen.dart` | Artworks list | Filtered artwork list by category param | **Stable** | |
| `settings_screen.dart` | Settings tab UI | Overlapping account menu (profile edit, orders, logout, artist profile) | **Needs follow-up** | Duplicates much of `account_screen.dart`; route `/settings` |

#### `lib/features/home/View/widgets/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `art_card.dart` | Artwork card | Grid/list card; guest auth CTA | **Stable** | |
| `art_details_screen.dart` | Art detail page | Artwork detail, favorites/cart actions | **Stable** | Some `context.go` after actions |
| `filterSearch.dart` | Search/filter UI | Home filtering widget | **Acceptable for now** | Legacy file name casing |
| `home_drawer.dart` | Drawer | Side drawer (mostly commented legacy token clear) | **Acceptable for now** | |

#### `lib/features/home/screens/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `guest_settings_screen.dart` | Guest settings | Pushes `AppRoutes.auth` for sign-in | **Stable** | |

---

### `lib/features/admin/`

Admin dashboards (session required; role not enforced on routes).

#### `lib/features/admin/view/screens/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `admin_dashboard_screen.dart` | Admin home | Links to verification queue and reports | **Stable** | Logout via cubit only |
| `admin_verification_requests_screen.dart` | Verification queue | Lists/approves requests via route-scoped cubit | **Stable** | |
| `admin_reports_screen.dart` | Placeholder | “Coming soon” reports UI | **Acceptable for now** | Not wired to `ReportRepository` UI yet |

#### `lib/features/admin/view/widgets/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `admin_section_header.dart` | Header widget | Section title styling | **Stable** | |
| `admin_verification_request_card.dart` | List card | Single verification request row | **Stable** | |
| `empty_requests_widget.dart` | Empty state | No requests placeholder | **Stable** | |
| `verification_status_chip.dart` | Chip UI | Status label chip | **Stable** | |

---

### `lib/features/artist_profile/`

Public and “my” artist profile, edit artist profile.

#### `lib/features/artist_profile/controller/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `artist_profile_cubit.dart` | Cubit | Load/update artist profile | **Stable** | |
| `artist_profile_state.dart` | State | Loading/success/error + artist data | **Stable** | |

#### `lib/features/artist_profile/data/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `artist_repository.dart` | `ArtistRepository` | Artist API calls via `ApiClient` | **Stable** | Imports `api_constants.dart` |

#### `lib/features/artist_profile/model/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `artist_model.dart` | `ArtistModel` | Artist DTO | **Stable** | |

#### `lib/features/artist_profile/view/screens/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `artist_profile_screen.dart` | Profile UI | Public/owner views; artist actions | **Needs follow-up** | `_getRoleFromToken()` uses **new** `TokenStorage()` + JWT decode — bypasses `AuthCubit` |
| `edit_artist_profile_screen.dart` | Edit UI | Updates via `ArtistProfileCubit` | **Stable** | |

#### `lib/features/artist_profile/view/widgets/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `artist_header_widget.dart` | Header | Artist header section | **Stable** | |

---

### `lib/features/artwork/`

Artwork catalog, create flow, image upload.

#### `lib/features/artwork/controller/cubit/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `artwork_cubit.dart` | Cubit | Artwork list/create state | **Stable** | Global provider in `app.dart` |
| `artwork_state.dart` | State | Artwork cubit states | **Stable** | |

#### `lib/features/artwork/data/repositories/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `artwork_repository.dart` | Repository | Artwork CRUD/list API | **Stable** | `api_constants` import |

#### `lib/features/artwork/data/services/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `artwork_image_storage_service.dart` | Firebase helper | Artwork image upload | **Stable** | |

#### `lib/features/artwork/view/screens/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `create_artwork_screen.dart` | Create UI | New artwork form | **Stable** | |

#### `lib/features/artwork/view/widgets/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `artwork_grid_widget.dart` | Grid | Artwork grid; guest → `AppRoutes.auth` | **Stable** | |

---

### `lib/features/cart/`

Shopping cart and order confirmation.

#### `lib/features/cart/controller/cubit/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `cart_cubit.dart` | Cubit | Cart load/update/checkout | **Stable** | |
| `cart_state.dart` | State | Cart items, loading, errors | **Stable** | |

#### `lib/features/cart/data/models/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `cart_model.dart` | Cart DTO | Cart aggregate | **Stable** | |
| `cart_item_model.dart` | Item DTO | Line item model | **Stable** | |

#### `lib/features/cart/data/repositories/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `cart_repository.dart` | Repository | Cart API | **Stable** | `api_constants` import |

#### `lib/features/cart/view/screens/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `cart_screen.dart` | Cart tab | Cart list and actions | **Stable** | |
| `confirm_order_screen.dart` | Checkout UI | Confirm order; links to location | **Stable** | |

#### `lib/features/cart/view/widgets/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `cart_item_widget.dart` | Line item UI | Single cart row | **Stable** | |
| `delivery_date_bottom_sheet.dart` | Bottom sheet | Delivery date picker | **Stable** | |

---

### `lib/features/order/`

Order history, details, incoming orders (artist).

#### `lib/features/order/controller/cubit/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `order_cubit.dart` | Cubit | Order lists and updates | **Stable** | |
| `order_state.dart` | State | Order loading/data states | **Stable** | |

#### `lib/features/order/data/repositories/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `order_repository.dart` | Repository | Order API | **Stable** | `api_constants` import |

#### `lib/features/order/view/screens/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `order_history_screen.dart` | History list | Buyer order history | **Stable** | |
| `order_details_screen.dart` | Detail UI | Single order view | **Stable** | |
| `incoming_orders_screen.dart` | Incoming list | Seller incoming orders | **Stable** | |

---

### `lib/features/location/`

Saved addresses and address form.

#### `lib/features/location/view/screens/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `location_screen.dart` | Address list | Manage delivery addresses | **Stable** | |
| `address_form_screen.dart` | Form UI | Add/edit address | **Stable** | |

---

### `lib/features/favorites/`

Favorites tab content.

#### `lib/features/favorites/controller/cubit/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `favorites_cubit.dart` | Cubit | Load/toggle favorites | **Stable** | |
| `favorites_state.dart` | State | Favorites list state | **Stable** | |

#### `lib/features/favorites/data/repositories/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `favorites_repository.dart` | Repository | Favorites API | **Stable** | `api_constants` import |

#### `lib/features/favorites/view/screens/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `favorites_screen.dart` | Favorites tab | Saved artworks list | **Stable** | |

#### `lib/features/favorites/view/widgets/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `favorite_artwork_card.dart` | Card UI | Favorite item card | **Stable** | |

---

### `lib/features/feedback/`

User feedback form.

#### `lib/features/feedback/controller/cubit/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `feedback_cubit.dart` | Cubit | Submit feedback | **Stable** | |
| `feedback_state.dart` | State | Submit loading/result | **Stable** | |

#### `lib/features/feedback/data/repositories/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `feedback_repository.dart` | Repository | Feedback API | **Stable** | `api_constants` import |

#### `lib/features/feedback/view/screens/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `feedback_screen.dart` | Feedback UI | Feedback form screen | **Stable** | |

---

### `lib/features/notifications/`

Notifications screen (UI only in this feature).

#### `lib/features/notifications/view/screens/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `notifications_screen.dart` | Notifications UI | Placeholder/list screen for notifications route | **Acceptable for now** | No dedicated cubit/repo in feature folder |

---

### `lib/features/report/`

Report submission API layer (no `view/` — used via global `ReportCubit`).

#### `lib/features/report/controller/cubit/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `report_cubit.dart` | Cubit | Submit content reports | **Stable** | Provided in `app.dart` |
| `report_state.dart` | State | Report submit state | **Stable** | |

#### `lib/features/report/data/repositories/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `report_repository.dart` | Repository | `POST /reports/` | **Stable** | `api_constants` import; admin reports UI not wired |

---

### `lib/features/verification_request/`

Artist verification request flow (also used from admin routes).

#### `lib/features/verification_request/controller/cubit/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `verification_request_cubit.dart` | Cubit | Create/list/update verification requests | **Sensitive** | **Three instances:** global in `app.dart`, route-scoped in `admin_routes`, `commerce_routes` |
| `verification_request_state.dart` | State | Request list/form states | **Stable** | |

#### `lib/features/verification_request/data/repositories/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `verification_request_repository.dart` | Repository | Verification API | **Stable** | `api_constants` import |

#### `lib/features/verification_request/view/screens/`

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `verification_request_screen.dart` | Artist form UI | Submit verification request | **Stable** | Uses global cubit from `app.dart` |

---

### `test/`

Unit tests for frozen contracts (not feature UI).

| File | What it contains | What it does | Status | Notes |
|------|------------------|--------------|--------|-------|
| `redirect_policy_test.dart` | Redirect tests | Guards splash/guest/session/admin landing matrix | **Stable** | Update when changing `redirect_policy.dart` |
| `auth_cubit_test.dart` | Auth state tests | `authStateHasSession` / state shape | **Stable** | |

---

## Root-level important files

| File | Purpose | Notes |
|------|---------|-------|
| `pubspec.yaml` | Dependencies, fonts, asset bundles | Declares `assets/.env`, images, icons, fonts; `provider`, `go_router`, `flutter_bloc`, `dio`, Firebase packages |
| `assets/.env` | Bundled env (`BASE_URL`, etc.) | Loaded by `AppEnv` — required at runtime |
| `.env` | Local/dev copy | May exist at project root; **pubspec bundles `assets/.env`** |
| `analysis_options.yaml` | Analyzer/linter config | Uses `flutter_lints` |
| `firebase.json` | Firebase project config | Hosting/tooling reference |
| `flutter_native_splash.yaml` | Splash generator config | Build-time splash assets |
| `ios/`, `android/`, `web/`, `macos/`, `linux/`, `windows/` | Platform runners | Standard Flutter embedding — not mapped file-by-file |
| `widgetbook/` | Component sandbox | Separate app; not production architecture |

---

## Current architecture status

**Already improved**

- Thin `main.dart`; composition in `lib/app/`
- Single JWT refresh owner (`ApiClient`); session restore via `AuthRepository` + one `AuthCubit.restoreSession()` in `dependencies.dart`
- Role on `UserModel.systemRole` / `authStateSessionUser()` — **not** in `TokenStorage`
- Frozen-style contracts: `AppEnv`, `ApiEndpoints`, `TokenStorage`, `AppPreferences`, `auth_state` helpers
- `AppRoutes` registry + tested `redirect_policy.dart`
- Modular router (`core/router/routes/*.dart`); slim `app_router.dart`
- Auth screens vs **account** hub split (`features/account/`)
- Feature navigation uses **`AppRoutes`** (no raw `'/...'` path strings under `lib/features/**`)
- `SplashMinDurationNotifier` uses `ChangeNotifierProvider` (not `RepositoryProvider`)

**Stable / freeze-ready**

- `app_routes.dart`, `redirect_policy.dart`, `api_endpoints.dart`, `token_storage.dart`, `app_preferences.dart`, `app_env.dart`, `app_exception.dart`, `auth_state.dart`, `bootstrap.dart`, router refresh/helpers

**Transitional**

- `api_constants.dart` barrel (9 repos still import it)
- `AuthRepository` still owns `GET/PATCH /account/me` while account UI is in `features/account/`
- `Result<T>` unused
- `redirect_policy` → `features/auth` import for `AuthState`
- Theme split: `core/res/theme/` vs `core/theme/theme_bloc.dart`
- Some auth screens call `context.go(AppRoutes.home)` after success

**Still needs follow-up**

- `AccountRepository` + thinner `AuthCubit` profile ownership
- Admin **role guard** on `/admin/*` (session-only today)
- `settings_screen.dart` vs `account_screen.dart` menu overlap
- `artist_profile_screen.dart` JWT role peek via `TokenStorage()`
- Consolidate `VerificationRequestCubit` ownership (global vs route-scoped)
- Normalize legacy `View/` / `Screens/` folder casing over time

---

## Follow-up / known issues

| Area | Current issue | Why it matters | Suggested follow-up |
|------|---------------|----------------|---------------------|
| Account data | `AuthRepository` has `GET/PATCH /account/me` | Wrong boundary after account UI split | Add `AccountRepository`; move profile PATCH |
| Network imports | 9 repos import `api_constants.dart` | Hides canonical `api_endpoints` | Mechanical rename imports |
| Admin routes | No `systemRole == 'admin'` check on `/admin/*` | Non-admin signed-in users can open admin URLs | Guard in `redirect_policy` or `AppRoutes` |
| Settings vs account | Two menus (`settings_screen`, `account_screen`) | Confusing UX and duplicate logout/links | Product merge or clear split |
| Artist profile | `_getRoleFromToken()` + `TokenStorage()` | Bypasses session contract | Use `authStateSessionUser()` |
| Verification cubit | Global + 2 route-scoped providers | Stale state risk between admin/artist flows | Single ownership strategy |
| Admin reports | Placeholder screen | `ReportRepository` exists but no admin list UI | Wire when product ready |
| Auth navigation | Post-login `context.go` in some screens | Redundant with redirect policy | Optional simplify to emit-only |

---

## Stable / do not change lightly

- `lib/core/router/app_routes.dart`
- `lib/core/router/redirect_policy.dart`
- `lib/core/config/app_env.dart`
- `lib/core/network/api_endpoints.dart`
- `lib/core/network/api_client.dart` (refresh behavior)
- `lib/core/storage/token_storage.dart`
- `lib/features/auth/controller/cubit/auth_state.dart`
- `lib/app/bootstrap.dart`
- `test/redirect_policy_test.dart`

## Still sensitive / likely to change

- `lib/app/dependencies.dart`
- `lib/app/app.dart` (global provider list)
- `lib/features/auth/data/repositories/auth_repository.dart`
- `lib/features/auth/controller/cubit/auth_cubit.dart`
- `lib/core/router/routes/*.dart` (new routes, route-level `BlocProvider`s)
- `lib/features/home/View/Screens/settings_screen.dart`
- `lib/features/artist_profile/view/screens/artist_profile_screen.dart`
- `lib/core/router/routes/admin_routes.dart`

---

## Team guidance

- **New routes:** add constants to `app_routes.dart` (and guard registry) → add `GoRoute` in the right `routes/*.dart` file → register in `app_route_table.dart` if new module.
- **New app-wide dependencies:** construct in `dependencies.dart`; expose in `app.dart` only if widgets need `context.read`.
- **Account UI:** `lib/features/account/` (`/profile`, `/profile/edit`).
- **Auth / session:** `lib/features/auth/` (`AuthCubit`, `AuthRepository`, credential screens).
- **Navigation:** use `go_router` + **`AppRoutes`** (or path builders); avoid raw path strings in features.
- **Logout:** `AuthCubit.logout()` — avoid manual `go('/auth')` after logout unless required; redirect policy handles navigation.
- **Do not add** business logic to `bootstrap.dart`, `redirect_policy.dart`, or route path literals outside `app_routes.dart`.
- **Tests:** update `test/redirect_policy_test.dart` when changing redirect rules or guard sets.

---

*Map last aligned with post–Phase 7 cleanup (modular router, auth/account split, `AppRoutes` navigation, thin `main.dart`).*
