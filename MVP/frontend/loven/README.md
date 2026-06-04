# LOVEN — Flutter Frontend

LOVEN is a Flutter MVP for an art marketplace. The frontend uses a **feature-first layout** with a thin **core** layer (config, network, storage, router) and an **`lib/app/`** composition layer. The codebase went through a **phased architecture cleanup** (contracts → session → routes → redirect policy → router modules → app bootstrap → auth/account split → navigation hygiene).

**This README is a project map for developers**, not full API or product documentation.

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

## Folder responsibilities

| Folder | Responsibility | Notes |
|--------|----------------|-------|
| `lib/app/` | Async startup, app-wide DI, `MaterialApp.router` + global providers | Single `restoreSession()` wired in `dependencies.dart` |
| `lib/core/config/` | `AppEnv` — bundled `.env`, base URL, timeouts | Do not read `dotenv` elsewhere |
| `lib/core/error/` | `AppException`, optional `Result<T>` | Repos mostly throw `AppException` via Dio |
| `lib/core/network/` | HTTP client, endpoint paths, transitional barrel | Prefer `api_endpoints.dart` + `api_client.dart` |
| `lib/core/storage/` | JWT storage (`TokenStorage`), onboarding flag (`AppPreferences`) | **No role** in storage |
| `lib/core/router/` | Route constants, guards, redirect policy, GoRouter assembly, route modules | Add paths to `app_routes.dart` first |
| `lib/core/res/theme/` | `AppColors`, `AppTheme` (light/dark) | Used by `app.dart` |
| `lib/core/theme/` | `ThemeBloc` (light/dark toggle) | Import here, not `main.dart` |
| `lib/features/auth/` | Login, signup, logout, session state, password recovery | **Not** account hub UI |
| `lib/features/account/` | `/profile` hub, `/profile/edit`, profile image upload service | Uses `AuthCubit` for session/profile API today |
| `lib/features/splash/` | Splash UI, onboarding carousel | Does not call `restoreSession` |
| `lib/features/navigation/` | `NavigationScreen` shell (tabs) | Guest vs signed-in tabs |
| `lib/features/home/` | Home feed, artist/artwork lists, art details, **settings tab** | Mixed `View/` vs `screens/` naming |
| `lib/features/admin/` | Admin dashboard, verification queue, reports | Session required; **no role guard on routes yet** |
| `lib/features/artist_profile/` | Public/my artist profile, edit artist profile | JWT role peek in one screen — see risks |
| `lib/features/artwork/` | Artwork repo, grid, create artwork | |
| `lib/features/cart/` | Cart cubit, cart/checkout screens | |
| `lib/features/order/` | Order history, details, incoming orders | |
| `lib/features/location/` | Saved addresses, address form | |
| `lib/features/favorites/` | Favorites tab content | |
| `lib/features/feedback/` | Feedback form | |
| `lib/features/report/` | Report repository | |
| `lib/features/notifications/` | Notifications screen | |
| `lib/features/verification_request/` | Artist verification request flow | Also used from admin routes |

---

## Important files

### Entry & composition

| File | What it does | Status | Notes / follow-up |
|------|----------------|--------|-------------------|
| `lib/main.dart` | `bootstrap()` then `runApp(LovenApp)` | **Stable** | Keep thin |
| `lib/app/bootstrap.dart` | `WidgetsFlutterBinding`, `AppEnv.load`, Firebase init, `AppPreferences.init` | **Stable** | No repositories here |
| `lib/app/dependencies.dart` | Builds `ApiClient`, repos, `AuthCubit`, `AppRouter`; wires session-expired callback; **one** `restoreSession()` | **Sensitive** | Grows when adding global deps |
| `lib/app/app.dart` | `MultiRepositoryProvider` / `MultiBlocProvider`, `MaterialApp.router` | **Sensitive** | `ChangeNotifierProvider` for splash notifier |
| `lib/firebase_options.dart` | Firebase platform options | **Stable** | Generated |

### Core — config, error, network, storage

| File | What it does | Status | Notes / follow-up |
|------|----------------|--------|-------------------|
| `lib/core/config/app_env.dart` | Loads `assets/.env`, resolves API base URL | **Stable** | |
| `lib/core/error/app_exception.dart` | Canonical app/network error type | **Stable** | |
| `lib/core/error/result.dart` | `Result<T>` wrapper | **Transitional** | Not used app-wide yet; acceptable for now |
| `lib/core/network/api_client.dart` | Dio client, auth interceptors, **sole JWT refresh** on 401 | **Stable** | Session-expired callback from app layer |
| `lib/core/network/api_endpoints.dart` | All backend path constants | **Stable** | Single path registry |
| `lib/core/network/api_constants.dart` | Barrel re-export + `ApiConstants` typedef | **Transitional** | Many repos still import this |
| `lib/core/storage/token_storage.dart` | Access/refresh JWT only; purges legacy `user_role` key on clear | **Stable** | |
| `lib/core/storage/app_preferences.dart` | Onboarding completed flag | **Stable** | |

### Core — router

| File | What it does | Status | Notes / follow-up |
|------|----------------|--------|-------------------|
| `lib/core/router/app_routes.dart` | Path constants, guard registry, path builders (`artistPath`, etc.) | **Stable** | Update registry when adding protected routes |
| `lib/core/router/redirect_policy.dart` | Pure `resolveRedirect()` for GoRouter | **Stable** | Tested; depends on `auth_state.dart` |
| `lib/core/router/app_router.dart` | Assembles `GoRouter` (initial route, refresh, redirect, route list) | **Stable** | Keep thin |
| `lib/core/router/app_router_deps.dart` | Injected deps for route builders (`AuthCubit`, artist/verification repos) | **Stable** | |
| `lib/core/router/router_refresh.dart` | `GoRouterRefreshStream` for `AuthCubit` stream | **Stable** | |
| `lib/core/router/router_helpers.dart` | Invalid-route fallback, required string `extra` helper | **Stable** | |
| `lib/core/router/splash_min_duration_notifier.dart` | Minimum splash duration before redirect | **Stable** | `ChangeNotifier` |
| `lib/core/router/routes/app_route_table.dart` | Merges all route modules in order | **Sensitive** | Add modules here |
| `lib/core/router/routes/startup_routes.dart` | Splash, legacy splash alias, onboarding, home shell | **Stable** | |
| `lib/core/router/routes/account_routes.dart` | `/profile`, `/profile/edit` | **Stable** | |
| `lib/core/router/routes/auth_routes.dart` | Auth, login, signup, forgot-password, change-password | **Stable** | |
| `lib/core/router/routes/admin_routes.dart` | Admin routes (+ route-scoped cubit for verification list) | **Sensitive** | Role guard follow-up |
| `lib/core/router/routes/discovery_routes.dart` | Artists, artist profile, artworks list, settings, edit artist | **Stable** | |
| `lib/core/router/routes/commerce_routes.dart` | Notifications, orders, cart shell, location, feedback, verification, create artwork | **Stable** | |

### Core — theme

| File | What it does | Status | Notes / follow-up |
|------|----------------|--------|-------------------|
| `lib/core/res/theme/app_theme.dart` | Light/dark `ThemeData` | **Stable** | |
| `lib/core/res/theme/app_colors.dart` | Brand colors | **Stable** | |
| `lib/core/theme/theme_bloc.dart` | App-wide theme mode toggle | **Stable** | Provided in `app.dart` |

### Auth & account

| File | What it does | Status | Notes / follow-up |
|------|----------------|--------|-------------------|
| `lib/features/auth/controller/cubit/auth_state.dart` | Session types + `authStateHasSession` / `authStateSessionUser` | **Stable** | Router contract; lives under auth feature |
| `lib/features/auth/controller/cubit/auth_cubit.dart` | Session orchestration: restore, login, logout, profile hydrate | **Sensitive** | No direct `TokenStorage`; still has FCM/Firebase |
| `lib/features/auth/data/repositories/auth_repository.dart` | Login/register/logout, tokens, **`GET/PATCH /account/me`** | **Needs follow-up** | Account API still here |
| `lib/features/auth/data/models/user_model.dart` | User DTO incl. `systemRole` | **Stable** | Canonical role source |
| `lib/features/account/view/screens/account_screen.dart` | Account hub (`/profile`), guest + signed-in, logout via cubit | **Stable** | |
| `lib/features/account/view/screens/edit_account_screen.dart` | Edit account UI; image upload + `AuthCubit.updateProfile` | **Sensitive** | |
| `lib/features/account/data/services/profile_image_storage_service.dart` | Firebase Storage for profile images | **Stable** | |

**Auth screens** (`lib/features/auth/view/screens/`): `login_page`, `signup_page`, `signup_verification_email_page`, `signup_success_page`, `forgot_password_page`, `verification_code_page`, `new_password_page`, `password_changed_page`, `change_password_screen` — credential/recovery flows. Some still call `context.go(AppRoutes.*)` after success; redirect policy also applies. **Acceptable for now**; optional cleanup.

### Splash & navigation

| File | What it does | Status | Notes / follow-up |
|------|----------------|--------|-------------------|
| `lib/features/splash/splash_screen.dart` | Branded splash; calls `SplashMinDurationNotifier.markReady()` | **Stable** | Does not restore session |
| `lib/features/splash/onboarding_screen.dart` | Onboarding; sets prefs; `context.go(AppRoutes.*)` | **Stable** | |
| `lib/features/navigation/view/Screens/navigation_screen.dart` | Bottom nav shell (home / favorites / cart / profile tab) | **Stable** | Uses `AppRoutes.auth` for guest CTA |

### Other feature entry points (grouped)

| Area | Key files | Status | Notes |
|------|-----------|--------|-------|
| **Home** | `home_screen.dart`, `artists_list_screen.dart`, `artworks_list_screen.dart`, `art_card.dart`, `art_details_screen.dart`, `settings_screen.dart`, `home_bloc.dart` | Mixed | `settings_screen` overlaps account hub menu; navigation uses `AppRoutes` |
| **Admin** | `admin_dashboard_screen.dart`, `admin_verification_requests_screen.dart`, `admin_reports_screen.dart` | Needs follow-up | Logout via cubit; no admin **role** route guard |
| **Artist profile** | `artist_profile_screen.dart`, `edit_artist_profile_screen.dart`, `artist_repository.dart`, `artist_profile_cubit.dart` | Needs follow-up | Screen reads JWT from `TokenStorage` for role |
| **Cart / order** | `cart_cubit.dart`, `cart_repository.dart`, `cart_screen.dart`, `confirm_order_screen.dart`, `order_cubit.dart`, `order_*_screen.dart` | Stable pattern | Repos use `api_constants` import |
| **Artwork** | `artwork_repository.dart`, `create_artwork_screen.dart`, `artwork_grid_widget.dart` | Stable pattern | |
| **Location** | `location_screen.dart`, `address_form_screen.dart` | Stable | `AppRoutes` navigation |
| **Favorites / feedback / notifications / verification** | respective `view/screens`, `controller/cubit`, `data/repositories` | Stable pattern | Standard feature layout |

### Tests

| File | What it does | Status |
|------|----------------|--------|
| `test/redirect_policy_test.dart` | Redirect matrix (splash, guest, session, admin landing) | **Stable** |
| `test/auth_cubit_test.dart` | `authStateHasSession` / state shape | **Stable** |

### Root config (non-`lib`)

| File | What it does | Notes |
|------|----------------|-------|
| `pubspec.yaml` | Dependencies, fonts, assets incl. `assets/.env` | |
| `assets/.env` | `BASE_URL` (local; not always in repo) | Required per `AppEnv` |
| `firebase.json` | Firebase hosting/config reference | |

---

## Current architecture status

**Already improved**

- Thin `main.dart`; composition in `lib/app/`
- Single JWT refresh owner (`ApiClient`); restore orchestration via `AuthRepository` + `AuthCubit`
- Role only on `AuthSuccess.user.systemRole` / `authStateSessionUser()` — not in `TokenStorage`
- Frozen-style contracts: `AppEnv`, `ApiEndpoints`, `TokenStorage`, `AppPreferences`, `auth_state` helpers
- `AppRoutes` registry + `redirect_policy.dart` with unit tests
- Modular router (`routes/*.dart`); slim `app_router.dart`
- Auth UI vs **account** UI split (`features/account/`)
- Feature navigation uses **`AppRoutes`** (no raw path strings in `lib/features/**`)
- No active `Navigator` bypass to splash; `SplashMinDurationNotifier` uses `ChangeNotifierProvider`

**Stable / freeze-ready (change only with team agreement)**

- `app_routes.dart`, `redirect_policy.dart`, `api_endpoints.dart`, `token_storage.dart`, `app_preferences.dart`, `app_env.dart`, `app_exception.dart`, `auth_state.dart`, `bootstrap.dart`, router helpers/refresh

**Transitional**

- `api_constants.dart` barrel — prefer direct `api_endpoints` / `api_client` imports in new code
- `AuthRepository` still owns `/account/me` while UI is in `account/`
- `Result<T>` defined but unused
- `redirect_policy` imports `auth_state` from `features/auth` (core → feature dependency)
- Some auth screens still call `context.go` after success (router policy often aligns anyway)

**Still needs work**

- `AccountRepository` boundary for profile PATCH / optional move off `AuthCubit.updateProfile`
- Admin **role-based** route guard (session-only today on `/admin/*`)
- Duplicate menus: `account_screen` vs `home/.../settings_screen.dart`
- `artist_profile_screen.dart` JWT/role logic via `TokenStorage` instead of auth state
- Global vs route-scoped `VerificationRequestCubit` duplication
- Normalize legacy folder casing (`View/` vs `view/`) over time

---

## What still needs attention

| Area | Remaining issue | Suggested next cleanup |
|------|-----------------|-------------------------|
| **Account data** | `AuthRepository` still has `GET/PATCH /account/me` | Add `AccountRepository`; thin `AuthCubit` delegation |
| **Network imports** | 9 feature repos import `api_constants.dart` | Mechanical migrate to `api_endpoints.dart` |
| **Admin security** | Any signed-in user can open `/admin` URLs | Role check in `redirect_policy` or `AppRoutes` helper |
| **Settings vs account** | Two overlapping account menus | Product decision: merge or split responsibilities clearly |
| **Artist profile** | `_getRoleFromToken()` uses `TokenStorage` + JWT decode | Use `authStateSessionUser()` / cubit |
| **Auth navigation** | Post-signup/login `context.go` in some screens | Rely on redirect after state emit only |
| **Verification cubit** | App-level provider + admin route `BlocProvider` | Pick one ownership |
| **Theme paths** | `core/res/theme` vs `core/theme/theme_bloc` | Optional consolidate docs/paths |

---

## Files and areas that should not be changed lightly

Treat as **contracts** (coordinate with team before behavioral changes):

- `lib/core/router/app_routes.dart` (paths + guard registry)
- `lib/core/router/redirect_policy.dart`
- `lib/core/config/app_env.dart`
- `lib/core/network/api_endpoints.dart`
- `lib/core/storage/token_storage.dart`
- `lib/features/auth/controller/cubit/auth_state.dart`
- `lib/core/network/api_client.dart` (refresh + interceptors)
- `test/redirect_policy_test.dart`

## Files that are still sensitive and need care

- `lib/app/dependencies.dart` — session bootstrap wiring
- `lib/app/app.dart` — global provider list
- `lib/features/auth/data/repositories/auth_repository.dart`
- `lib/features/auth/controller/cubit/auth_cubit.dart`
- `lib/core/router/routes/*.dart` — new screens and route-level `BlocProvider`s
- `lib/features/auth/view/screens/*` — credential flows
- `lib/features/home/View/Screens/settings_screen.dart`
- `lib/features/artist_profile/view/screens/artist_profile_screen.dart`

---

## Team note

**New routes**

1. Add path constant(s) to `lib/core/router/app_routes.dart` (and guard registry if protected/guest/public).
2. Add a `GoRoute` in the appropriate `lib/core/router/routes/*.dart` module.
3. Register the module in `app_route_table.dart` if new file.
4. Do **not** hardcode path strings in widgets — use `AppRoutes` or path builders (`artistPath`, `signupFromGuest`, etc.).

**New app-wide dependencies**

- Construct in `lib/app/dependencies.dart`.
- Expose via `RepositoryProvider` / `BlocProvider` in `lib/app/app.dart` only if widgets need `context.read`.

**Account UI**

- `lib/features/account/` (screens, account-specific services).
- Routes stay `/profile` and `/profile/edit` via `account_routes.dart`.

**Auth / session**

- Credentials, logout, session state: `lib/features/auth/` (`AuthCubit`, `AuthRepository`, auth screens).
- Router reads session via `auth_state.dart` helpers — do not reintroduce role in `TokenStorage`.

**Navigation**

- Use `go_router` + `AppRoutes`.
- Logout: `context.read<AuthCubit>().logout()` — let redirect policy react; avoid manual `go('/auth')` after logout unless product requires it.

**Tests**

- Update `test/redirect_policy_test.dart` when changing redirect rules or guard registry.

---

*Last aligned with phased cleanup through Phase 7 + provider fix for `SplashMinDurationNotifier`.*
