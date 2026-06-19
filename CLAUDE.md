# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run the app (defaults to connected device/emulator)
flutter run

# Run on a specific device
flutter run -d <device-id>

# Analyze for lints/type errors
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Get dependencies
flutter pub get
```

## Architecture

This is a Flutter app (package: `student`) for a language-learning platform targeting Uzbek students. It follows **Clean Architecture** with three distinct layers per domain:

```
lib/
├── app/               # App-wide infrastructure
│   ├── data/network/  # Dio client, AuthInterceptor, TokenStorage, config
│   ├── router/        # GoRouter setup (app_router.dart)
│   └── theme/         # AppTheme, AppRadius, AppSpacing
├── core/<domain>/     # One folder per feature domain
│   ├── data/          # API models (fromJson), repository implementations
│   ├── domain/        # Entities, repository interfaces (I*Repository), use cases
│   └── presentation/  # Riverpod Notifier/Provider controllers
└── ui/<feature>/      # Screens and widgets (pure UI, reads from core providers)
```

**Domains:** `auth`, `assessments`, `assignments`, `courses`, `p2p`, `startup`, `tutors`, `user`, `main`

### State management

Riverpod is used throughout. The pattern is:
- `Provider` for repositories and use cases
- `NotifierProvider` for stateful controllers (e.g., `P2pController`, `SkillQuestionsNotifier`)
- `StateProvider` for simple shared state (e.g., `currentUserProvider`, `navbarControllerProvider`)

Controllers live in `core/<domain>/presentation/` and are consumed by screens in `ui/`.

### Networking

`dioClientProvider` (`lib/app/data/network/dio_client.dart`) creates a `Dio` instance with:
- `baseUrl` = `baseApiUrl` from `config.dart` (dev: `http://192.168.0.22:8000/api/`, prod: `https://cp.i-teach.uz/api/`)
- `AuthInterceptor` — attaches Bearer token to all requests except `auth/refresh`; handles 401s by serialising concurrent refresh calls (only one flies at a time) and retrying; redirects to login on failed refresh
- `TalkerDioLogger` for request/response logging in debug

JWT tokens are stored in `SharedPreferences` via `TokenStorage` (`access_token` / `refresh_token` keys).

### Routing

All routes are registered flat in `app_router.dart` (GoRouter). Each screen declares its own `static const path` string. Navigation is done via `context.go(Screen.path)` or `context.push(...)`.

### P2P calling

`P2pController` manages the full lifecycle: Socket.IO connection to `$hostUrl/match` for matchmaking → WebRTC peer connection via `flutter_webrtc` for audio calls. The controller uses a sealed `P2pState` hierarchy (`P2pIdle`, `P2pSearching`, `P2pMatched`, `P2pConnecting`, `P2pConnected`, `P2pEnded`, `P2pError`).

### AI assessment

Audio is recorded locally, then sent as `multipart/form-data` to `assessments/conversations/{id}/messages`. The backend streams back assessment turns. Conversations are created first via `assessments/conversations`.

### Theme

Material 3 with Inter (Google Fonts). Primary color: `#18c96a` (green). Background: `#f6f7fa`. Shared spacing constants in `AppSpacing`, radii in `AppRadius`.

### Data flow convention

`*Response` (data layer) → `.toEntity()` → `*Entity` (domain layer). Screens only import entities, never response models. Use cases are thin wrappers that call repository methods and return entities.
