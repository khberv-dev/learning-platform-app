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

### UI conventions

- **Widget folder:** Every non-trivial widget used by a screen lives in a `widget/` subfolder next to the screen file (e.g. `lib/ui/profile/widget/avatar_card.dart`). Keep screen files thin — they compose widgets, not define them.
- **Shared utilities:** Reusable pure-Dart helpers (`formatNumber`, `formatPhone`, etc.) go in `lib/utils/lib.dart`. Never define them locally inside a screen or widget file.

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

### Clean Architecture

Every feature is split across three layers — **no layer may import from a layer above it**.

| Layer | Path | Rule |
|---|---|---|
| Domain | `lib/core/<feature>/domain/` | Pure Dart only. No Flutter, no Dio, no Riverpod. |
| Data | `lib/core/<feature>/data/` | Implements domain interfaces. Imports Dio, SharedPreferences, etc. |
| Presentation | `lib/core/<feature>/presentation/` | Riverpod controllers only. Imports use cases, never repositories directly. |

**Usecase naming convention:**
- Class: `UseFeatureName` — e.g. `UseSignIn`, `UseLoadSkillQuiz`
- File: `use_feature_name.dart` — e.g. `use_sign_in.dart`, `use_load_skill_quiz.dart`
- Provider: `useFeatureNameProvider` — e.g. `useSignInProvider`

**Domain** contains:
- `entity/` — immutable plain Dart classes
- `repository/` — abstract `IXxxRepository` interface
- `usecase/` — one `call()` method, depends only on the interface

**Data** contains:
- `model/` — JSON-parsing classes with `fromJson` + `.toEntity()` conversion
- `repository/` — concrete class implementing `IXxxRepository`; exposes a Riverpod `Provider`

**Presentation** contains:
- `AsyncNotifier` (async operations) or `Notifier` (sync state)
- Exposes `xxxControllerProvider`
- Error messages extracted via a static `errorMessage(Object error)` helper on the controller class, not in the UI

**Auth controller pattern:** after a successful sign-in or sign-up, always fetch the current user and hydrate `currentUserProvider`:
```dart
await ref.read(useSignInProvider).call(...);
final user = await ref.read(useGetMeProvider).call();
ref.read(currentUserProvider.notifier).state = user;
```

**Riverpod gotchas:**
- `FamilyAsyncNotifier` is not available in this version — use `FutureProvider.family` for parameterized async data instead.
- `StateProvider` requires `import 'package:flutter_riverpod/legacy.dart'`.

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

### Lint rules to keep in mind

- `curly_braces_in_flow_control_structures` — always wrap `if`/`else` bodies in braces, even single-line returns.
- `unnecessary_underscores` — use named params (`e, st`) instead of `_, __` in `.when()` / `.whenOrNull()` callbacks.

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
| `chewie` + `video_player` | Video playback (tutor intro videos) |
| `package_info_plus` | App version string |
