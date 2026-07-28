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

# Format (the repo is kept dart-format clean)
dart format .

# Get dependencies
flutter pub get

# Regenerate launcher icons after changing assets/images/brand.png
dart run flutter_launcher_icons
```

Test coverage is minimal — `test/` mirrors `lib/` (currently only `test/shared/widget/app_button_test.dart`). `flutter analyze` is the main automated check.

```bash
flutter test                              # all tests
flutter test test/shared/widget/app_button_test.dart   # single file
```

## Architecture

Flutter app (package name: `student`) for the iTeach language-learning platform, targeting Uzbek students. **Clean Architecture** with three layers per domain:

```
lib/
├── app/               # App-wide infrastructure
│   ├── app.dart       # MaterialApp.router root
│   ├── data/network/  # Dio client, AuthInterceptor, TokenStorage, config.dart
│   ├── router/        # GoRouter setup (app_router.dart)
│   └── theme/         # AppTheme, AppRadius, AppSpacing
├── core/<domain>/     # One folder per feature domain
│   ├── data/          # model/ (*Response with fromJson/toEntity), repository/ (impls)
│   ├── domain/        # entity/, repository/ (I*Repository), usecase/
│   └── presentation/  # Riverpod controllers
├── shared/widget/     # Cross-feature widgets (AppHeader, BackIconButton, OtpField, …)
├── ui/<feature>/      # Screens + feature-local widget/ subfolder
└── utils/             # lib.dart (formatPhone/formatNumber), messenger.dart, uz_phone_formatter.dart
```

**Domains:** `assessments`, `assignments`, `auth`, `chat`, `courses`, `live_lessons`, `main`, `p2p`, `startup`, `tutors`, `user`

Not every domain has all three layers — `p2p` is socket/WebRTC-only (no data layer), `main` is just `navbar_controller.dart`, and `startup` keeps UI-only value objects in `domain/model/` (survey queries, illustrations) alongside its entities.

Shared widgets live in `lib/shared/widget/`, **not** under `lib/ui/`. A widget graduates there once a second feature needs it; otherwise it stays in `lib/ui/<feature>/widget/`.

### Data flow convention

`*Response` (data layer) → `.toEntity()` → `*Entity` (domain layer). **Screens import entities only, never response models.** Use cases are thin single-method wrappers (`class UseX { Future<T> call() => _repo.x(); }`) over a repository interface.

Each layer exposes a Riverpod provider next to its class:

```dart
final liveLessonsRepositoryProvider = Provider<ILiveLessonsRepository>(
  (ref) => LiveLessonsRepository(dio: ref.read(dioClientProvider)),
);
final useGetMyLiveLessonsProvider = Provider(...);
final myLiveLessonsProvider = AsyncNotifierProvider<MyLiveLessonsController, List<...>>(...);
```

List endpoints often return an envelope — `response.data['data'] as List` — while detail endpoints return the object directly. Check the endpoint before assuming.

### State management (Riverpod 3)

- `Provider` — repositories and use cases
- `AsyncNotifierProvider` / `NotifierProvider` — stateful controllers (`MyLiveLessonsController`, `P2pController`, `SkillQuestionsNotifier`)
- `StateProvider` / `StateNotifierProvider` — simple shared state (`currentUserProvider`, `navbarControllerProvider`, `chatMessagesProvider`)

**Gotcha:** in Riverpod 3 the legacy APIs (`StateProvider`, `StateNotifierProvider`, `StateNotifier`) require an extra `import 'package:flutter_riverpod/legacy.dart';`. Four files currently do this — new code should prefer `Notifier`/`AsyncNotifier`.

Controllers live in `core/<domain>/presentation/` and are consumed by screens in `ui/`.

### Networking

`dioClientProvider` (`lib/app/data/network/dio_client.dart`) builds the shared `Dio`:
- `baseUrl` = `baseApiUrl` from `config.dart`; 10s connect / 90s receive timeout (long receive is for AI assessment audio)
- `AuthInterceptor` — attaches the Bearer token to every request except `auth/refresh`. On 401 it refreshes once, serialising concurrent refreshes through a single `Completer` so only one refresh flies at a time, marks the retried request via `extra['retried']`, and on refresh failure clears tokens and `go`s to `LoginScreen`.
- `TalkerDioLogger` for request/response logging

JWTs are stored in `SharedPreferences` via `TokenStorage` (`access_token` / `refresh_token`). The refresh response is read tolerantly (`accessToken` or `access_token`).

**Local dev:** set `devHostUrl` in `lib/app/data/network/config.dart` to your machine's LAN IP (currently `http://192.168.0.2:8000`). Prod is `https://cp.i-teach.uz`. `kDebugMode` picks between them.

**Media URLs:** the API returns relative paths. The convention everywhere is
`url.startsWith('http') ? url : '$baseCdnUrl/$url'` where `baseCdnUrl = $hostUrl/public`.

### Error handling

`lib/utils/messenger.dart` is the single path for surfacing failures: `apiErrorMessage(error)` unwraps a `DioException` body (`message` as String or List) into a user-facing string, and `showErrorMessage(context, msg)` shows it as an error-coloured SnackBar after clearing any existing ones. Use both rather than hand-rolling SnackBars.

### Routing

All routes are registered flat in `app_router.dart`. Each screen declares its own `static const path`. Navigate with `context.go(Screen.path)` / `context.push(...)`.

Parameter passing is inconsistent by design of the individual routes — some use `pathParameters` (`CourseDetailScreen`, `TutorProfileScreen`), most use `uri.queryParameters` (`OtpScreen`, `TasksScreen`, `LessonScreen`, `ChatRoomScreen`), and `LiveSessionScreen` takes the whole entity via `state.extra`. Follow whatever the existing route does.

`SplashScreen` (`/`) is the auth gate: it plays a 4-second animation, then routes to `OnboardingScreen` (no token), `AppScreen` (token + `/me` succeeds, seeding `currentUserProvider`), `NoConnectionScreen` (5xx or network error) or `LoginScreen` (anything else).

### Main shell

`AppScreen` (`/app`) is an `IndexedStack` of four tabs — Home, Courses, Tutors, Profile — driven by `navbarControllerProvider`.

**Gotcha:** the navbar always has four items, but when `hasChatRoomsProvider` is true item **index 2** swaps from *Mentor* (the Tutors tab) to *Chat*, and tapping it pushes `ChatRoomScreen` for the first room instead of changing `navbarIndex` — so the Tutors tab is unreachable from the navbar for students who have a chat room. Any change to nav item order must keep `AppNavbar`'s list and `AppScreen.onNavItemClick`'s index-2 special case in sync.

### Realtime (Socket.IO)

Two namespaces, both connected with `setTransports(['websocket'])`, `disableAutoConnect()`, and `setAuth({'token': accessToken})`:

- `$hostUrl/match` — P2P matchmaking (`P2pController`)
- `$hostUrl/chat` — chat messages (`ChatMessagesNotifier`)

Chat messages are kept **newest-first** in state to pair with `ListView(reverse: true)`; the API already returns DESC. `addMessage` dedupes by id, since a message can arrive both from the POST response and the socket echo.

### P2P calling

`P2pController` runs the full lifecycle: Socket.IO matchmaking → `flutter_webrtc` peer connection for audio-only calls. State is a sealed `P2pState` hierarchy (`P2pIdle`, `P2pSearching`, `P2pMatched`, `P2pConnecting`, `P2pConnected`, `P2pEnded`, `P2pError`) with a `P2pRole` enum (`caller`/`callee`). ICE candidates that arrive before the remote description is set are buffered in `_pendingCandidates` and flushed after `setRemoteDescription`.

### AI assessment

Create a conversation via `POST assessments/conversations`, then record audio locally with the `record` package and upload each turn as `multipart/form-data` (field `audio`, `turn.m4a`, `audio/mp4`) to `assessments/conversations/{id}/messages`. The backend returns the assessment turn with feedback.

### Live lessons

Two distinct concepts with confusingly similar names:
- `courses/domain/entity/live_lesson_entity.dart` — a recorded session attached to a course, played back with `video_player` + `chewie` in `LiveSessionScreen`
- `live_lessons/domain/entity/live_lesson_scheduled_entity.dart` — an upcoming scheduled lesson from `live-lessons/my`, shown on the home page

### Theme

Material 3. Seed/primary `#18c96a` (green), scaffold background `#f6f7fa`, `onSurface` `#111827`, `onSurfaceVariant` `#6b7280`. Light mode only — there is no dark theme. Spacing constants in `AppSpacing` (4/8/12/16/24/32), radii in `AppRadius` (8/12/16/9999).

**Typography is deliberately not set.** `app_theme.dart` overrides no `textTheme`/`fontFamily`, so `ThemeData` resolves the platform system font — SF Pro on iOS/macOS, Roboto on Android. Apple's font licence forbids embedding SF Pro in an app bundle, so it must come from the OS; don't add it to `assets/` or set a `fontFamily`.

### Buttons

`AppButton` (`lib/shared/widget/app_button.dart`) is the only button style — a chunky pill with a solid 3D bottom edge that sinks on press. Three variants: `.filled` (primary CTA, theme green + gloss stripes), `.outlined` (dark teal border/text), `.white` (neutral secondary). Total height is `height + depth` (default 56 + 6), so don't wrap it in a fixed-height `SizedBox`; width comes from the parent. `onTap: null` disables; `isLoading` swaps in a spinner and blocks taps.

Material's `FilledButton`/`OutlinedButton`/`ElevatedButton` are no longer used anywhere in `lib/`. `TextButton` survives only for inline links (Forgot Password, Resend code) and `AlertDialog` actions.

Navbar and several UI icons are SVGs in `assets/icons/` rendered with `flutter_svg` and tinted via `ColorFilter`.

## Backend

The NestJS API is a separate project. **Never edit backend files** — describe the required API change as instructions instead.
