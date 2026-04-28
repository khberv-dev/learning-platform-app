# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run on a connected device or simulator
flutter run

# Build
flutter build ios
flutter build apk

# Analyze (lint)
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/file_test.dart
```

## Architecture

This is a Flutter mobile app (package name `student`) using **Riverpod** for state management and **GoRouter** for navigation. It follows a layered clean architecture pattern.

### Layer structure under `lib/`

| Layer | Path | Responsibility |
|---|---|---|
| App config | `lib/app/` | Router, theme, entry point |
| Domain | `lib/core/domain/` | Entities, use cases, pure models |
| Data | `lib/core/data/` | Repositories that fetch/parse data |
| Presentation (controllers) | `lib/core/presentation/` | Riverpod `Notifier`/`StateProvider` controllers |
| UI | `lib/ui/` | Screens and widgets |

### Data flow

`UI screen` → watches a **controller provider** → controller calls a **use case provider** → use case calls a **repository provider** → repository reads from asset/API.

### Routing

Routes are declared in `lib/app/router/app_router.dart` as a flat `GoRouter` list. Each screen owns its path as a `static const path` string on the screen class (e.g., `SplashScreen.path = '/splash'`). The initial route is `/app` (the post-auth shell).

### State management conventions

- Controllers are `NotifierProvider` or `StateProvider` in `lib/core/presentation/`.
- Providers are `Provider` for stateless dependencies (repositories, use cases, theme, router).
- Every screen is a `ConsumerWidget` or `ConsumerStatefulWidget`; `ref.watch` for reactive state, `ref.read` for one-shot reads inside callbacks.

### Theme

Defined entirely in `lib/app/theme/app_theme.dart`. Primary color is `0xff18c96a` (green). Spacing constants live in `app_spacing.dart`, border radius in `app_radius.dart`.

### Assets

- `assets/icons/` — SVG icons rendered via `flutter_svg`
- `assets/images/` — PNG illustrations
- `assets/skill_quiz.json` — static quiz data (loaded at runtime via `rootBundle`)

### Navigation rule

**Always use `go_router` for navigation — never `Navigator` directly.** Use `context.go()` / `context.push()` / `context.pop()` in widgets. From non-widget code (interceptors, services) use the `GoRouter` instance from `appRouterProvider` and call `router.go()`.

### Network layer

Dio client lives at `lib/app/data/network/dio_client.dart` (provider: `dioClientProvider`).

- `AuthInterceptor` (`auth_interceptor.dart`) attaches the Bearer token on every request and handles token refresh on 401:
  1. Calls `POST /auth/refresh` with the stored refresh token.
  2. Saves the new tokens and retries the original request once (`extra['retried']`).
  3. If the refresh endpoint itself returns 401, clears tokens and navigates to `LoginScreen.path` via `GoRouter`.
  4. Concurrent 401s are serialised with a `Completer<String>` — only one refresh flies at a time.
- `TokenStorage` (`token_storage.dart`) persists access/refresh tokens in `SharedPreferences`.
- Replace `_baseUrl` in `dio_client.dart` with the real API base URL (e.g. via `--dart-define`).

### Key dependencies

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `go_router` | Declarative routing |
| `google_fonts` | Inter font |
| `flutter_svg` | SVG rendering |
| `dio` + `talker_dio_logger` | HTTP client + logging |
| `pinput` | OTP input field |
| `shared_preferences` | Local key-value storage |
