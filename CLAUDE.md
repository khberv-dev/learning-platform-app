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
│   ├── data/network/  # Dio client, AuthInterceptor, TokenStorage, config.dart
│   ├── router/        # GoRouter setup (app_router.dart)
│   └── theme/         # AppTheme, AppRadius, AppSpacing
├── core/<domain>/     # One folder per feature domain
│   ├── data/          # API models (fromJson), repository implementations
│   ├── domain/        # Entities, repository interfaces (I*Repository), use cases
│   └── presentation/  # Riverpod Notifier/Provider controllers
├── ui/<feature>/      # Screens and widgets (pure UI, reads from core providers)
└── utils/             # Shared helpers: showErrorMessage, uz_phone_formatter
```

**Domains:** `auth`, `assessments`, `assignments`, `courses`, `p2p`, `startup`, `tutors`, `user`, `main`

### State management

Riverpod is used throughout. The pattern is:
- `Provider` for repositories and use cases
- `NotifierProvider` for stateful controllers (e.g., `P2pController`, `SkillQuestionsNotifier`)
- `StateProvider` for simple shared state (e.g., `currentUserProvider`, `navbarControllerProvider`)

Controllers live in `core/<domain>/presentation/` and are consumed by screens in `ui/`. Screens only import entities — never response models.

### Networking

`dioClientProvider` (`lib/app/data/network/dio_client.dart`) creates a `Dio` instance with:
- `baseUrl` = `baseApiUrl` from `config.dart` (debug: `http://192.168.1.2:8000/api/`, prod: `https://cp.i-teach.uz/api/`)
- `AuthInterceptor` — attaches Bearer token to all requests except `auth/refresh`; serialises concurrent refresh calls (only one in-flight at a time) and retries; redirects to login on failed refresh
- `TalkerDioLogger` for request/response logging in debug

**Local dev:** change `devHostUrl` in `lib/app/data/network/config.dart` to your machine's IP. `baseCdnUrl` (`$hostUrl/public`) is used for media assets.

JWT tokens are stored in `SharedPreferences` via `TokenStorage` (`access_token` / `refresh_token` keys).

### Routing

All routes are registered flat in `app_router.dart` (GoRouter). Each screen declares its own `static const path` string. Navigate via `context.go(Screen.path)` or `context.push(...)`. Parameterised routes use `pathParameters` or `uri.queryParameters` (e.g., `CourseDetailScreen`, `LessonScreen`).

The main shell is `AppScreen` (`/app`) — an `IndexedStack` of four tabs (Home, Courses, Tutors, Profile) driven by `navbarControllerProvider`.

### Data flow convention

`*Response` (data layer) → `.toEntity()` → `*Entity` (domain layer). Screens only import entities, never response models. Use cases are thin wrappers that call repository methods and return entities.

### P2P calling

`P2pController` manages the full lifecycle: Socket.IO connection to `$hostUrl/match` for matchmaking → WebRTC peer connection via `flutter_webrtc` for audio-only calls. The controller uses a sealed `P2pState` hierarchy (`P2pIdle`, `P2pSearching`, `P2pMatched`, `P2pConnecting`, `P2pConnected`, `P2pEnded`, `P2pError`) with a `P2pRole` enum (`caller`/`callee`). ICE candidates arriving before the remote description is set are buffered in `_pendingCandidates` and flushed after `setRemoteDescription`.

### AI assessment

Audio is recorded locally with the `record` package, then sent as `multipart/form-data` to `assessments/conversations/{id}/messages`. A conversation is created first via `assessments/conversations`. The backend returns assessment turns with feedback.

### Theme

Material 3 with Inter (Google Fonts). Primary color: `#18c96a` (green). Background: `#f6f7fa`. Shared spacing constants in `AppSpacing`, radii in `AppRadius`.
