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

# Regenerate lib/l10n/app_localizations*.dart after editing an .arb file
# (also runs automatically on `flutter pub get` and every build)
flutter gen-l10n
```

`test/` mirrors `lib/` (`test/ui/<feature>/`, `test/core/<domain>/`, `test/shared/widget/`). Most tests are widget tests of screens, plus `fromJson`/`toEntity` parsing tests for response models. `flutter analyze` and `flutter test` are the automated checks.

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
│   ├── locale/        # AppLanguage, LocaleStorage, localeControllerProvider
│   ├── router/        # GoRouter setup (app_router.dart)
│   ├── theme/         # AppTheme, AppColors, AppRadius, AppSpacing
│   └── upgrade/       # AppUpgradeAlert (store update prompt)
├── core/<domain>/     # One folder per feature domain
│   ├── data/          # model/ (*Response with fromJson/toEntity), repository/ (impls)
│   ├── domain/        # entity/, repository/ (I*Repository), usecase/
│   └── presentation/  # Riverpod controllers
├── l10n/              # .arb files + checked-in generated AppLocalizations
├── shared/widget/     # Cross-feature widgets (AppHeader, BackIconButton, OtpField, …)
├── ui/<feature>/      # Screens + feature-local widget/ subfolder
└── utils/             # lib.dart (formatPhone/formatNumber), messenger.dart, date_format.dart, uz_phone_formatter.dart
```

**Domains:** `assessments`, `auth`, `chat`, `courses`, `enrollments`, `groups`, `live_lessons`, `main`, `mentors`, `notifications`, `p2p`, `payments`, `plans`, `startup`, `user`

Not every domain has all three layers. `assessments` has no presentation layer, since `AiAssessmentScreen` drives it directly. `p2p` uses sockets and WebRTC only, with no data layer. `main` is just `navbar_controller.dart`. `startup` keeps UI-only value objects in `domain/model/` (survey queries, illustrations) alongside its entities.

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

**Gotcha:** in Riverpod 3 the legacy APIs (`StateProvider`, `StateNotifierProvider`, `StateNotifier`) require an extra `import 'package:flutter_riverpod/legacy.dart';`. Three files currently do this — new code should prefer `Notifier`/`AsyncNotifier`.

Controllers live in `core/<domain>/presentation/` and are consumed by screens in `ui/`.

### Networking

`dioClientProvider` (`lib/app/data/network/dio_client.dart`) builds the shared `Dio`:
- `baseUrl` = `baseApiUrl` from `config.dart`; 10s connect / 90s receive timeout (long receive is for AI assessment audio)
- `AuthInterceptor` — attaches the Bearer token to every request except `auth/refresh`. On 401 it refreshes once, serialising concurrent refreshes through a single `Completer` so only one refresh flies at a time, marks the retried request via `extra['retried']`, and on refresh failure clears tokens and `go`s to `LoginScreen`.
- `TalkerDioLogger` for request/response logging

JWTs are stored in `SharedPreferences` via `TokenStorage` (`access_token` / `refresh_token`). The refresh response is read tolerantly (`accessToken` or `access_token`).

**Host selection:** `lib/app/data/network/config.dart` currently hardcodes `hostUrl = mainHostUrl` (prod, `https://cp.i-teach.uz`), so **debug builds hit production**. The `kDebugMode ? devHostUrl : mainHostUrl` switch is commented out. For a local API, set `devHostUrl` to your machine's LAN IP (currently `http://192.168.0.2:8000`), then point `hostUrl` at it. Don't commit that change.

**Media URLs:** the API returns fully-qualified URLs for every file (course images, avatars, payment icons, recordings, …), so screens use them as-is — no CDN base to prepend. `resolveMediaUrl` (`lib/utils/lib.dart`) just turns an empty/missing value into `null` for callers that fall back to a placeholder.

### Error handling

`lib/utils/messenger.dart` is the single path for surfacing failures: `apiErrorMessage(error)` unwraps a `DioException` body (`message` as String or List) into a user-facing string, and `showErrorMessage(context, msg)` shows it as an error-coloured SnackBar after clearing any existing ones. Use both rather than hand-rolling SnackBars.

**Crash reporting:** `main.dart` wraps everything in `runZonedGuarded` and installs `FlutterError.onError` / `PlatformDispatcher.instance.onError`, each forwarding to `reportAppError` (`lib/core/diagnostics/error_reporting.dart`). That function is release-build-only (`kReleaseMode`), builds its own bare `Dio` (not `dioClientProvider` — no Riverpod container exists this early, and it must never get pulled into the main client's auth-refresh flow), and posts `{ device, message }` to the public `app-reports` endpoint. It attaches the stored access token as a Bearer header when there is one, since the backend resolves `AppReport.userId` from that token itself rather than a body field — the endpoint has no other place to take a user id from and works fine unauthenticated. Never throws; a failed report must not cause a second crash.

### Routing

All routes are registered flat in `app_router.dart`. Each screen declares its own `static const path`. Navigate with `context.go(Screen.path)` / `context.push(...)`.

Parameter passing is inconsistent by design of the individual routes — some use `pathParameters` (`CourseDetailScreen`, `MentorProfileScreen`), most use `uri.queryParameters` (`OtpScreen`, `TasksScreen`, `LessonScreen`, `ChatRoomScreen`), and `LiveSessionScreen` takes the whole entity via `state.extra`. Follow whatever the existing route does.

`SplashScreen` (`/`) is the auth gate. After its animation it routes to one of:
- `OnboardingScreen` if there is no token
- `AppScreen` if the token is valid and `/me` succeeds (this seeds `currentUserProvider`)
- `NoConnectionScreen` on a 5xx or network error
- `LoginScreen` otherwise

If no language has been chosen yet, it goes through `LanguageScreen` first.

Auth works with either a phone number or an email, toggled by `AuthIdentitySwitch` (`AuthIdentityType.phone`/`.email`).

### Main shell

`AppScreen` (`/app`) is an `IndexedStack` of four tabs — Home, Courses, Mentors, Profile — driven by `navbarControllerProvider`. It is the first point where a valid token is guaranteed, so it also starts push messaging and checks for completed purchases on app resume (see below).

**Gotcha:** the navbar always has four items, but when `hasChatRoomsProvider` is true item **index 2** swaps from *Mentor* (the Mentors tab) to *Chat*, and tapping it pushes `ChatRoomScreen` for the first room instead of changing `navbarIndex` — so the Mentors tab is unreachable from the navbar for students who have a chat room. Any change to nav item order must keep `AppNavbar`'s list and `AppScreen.onNavItemClick`'s index-2 special case in sync.

### Realtime (Socket.IO)

Two namespaces, both connected with `setTransports(['websocket'])`, `disableAutoConnect()`, and `setAuth({'token': accessToken})`:

- `$hostUrl/match` — P2P matchmaking (`P2pController`)
- `$hostUrl/chat` — chat messages (`ChatMessagesNotifier`)

Chat messages are kept **newest-first** in state to pair with `ListView(reverse: true)`; the API already returns DESC. `addMessage` dedupes by id, since a message can arrive both from the POST response and the socket echo.

### P2P calling

`P2pController` runs the full lifecycle: Socket.IO matchmaking → `flutter_webrtc` peer connection for audio-only calls. State is a sealed `P2pState` hierarchy (`P2pIdle`, `P2pSearching`, `P2pMatched`, `P2pConnecting`, `P2pConnected`, `P2pEnded`, `P2pError`) with a `P2pRole` enum (`caller`/`callee`). ICE candidates that arrive before the remote description is set are buffered in `_pendingCandidates` and flushed after `setRemoteDescription`.

### AI assessment

Create a conversation via `POST assessments/conversations`, then record audio locally with the `record` package and upload each turn as `multipart/form-data` (field `audio`, `turn.m4a`, `audio/mp4`) to `assessments/conversations/{id}/messages`. The backend returns the assessment turn with feedback.

### Push notifications

In `main`, `Firebase.initializeApp()` runs inside a try/catch, so a device without Play Services still starts the app and only loses push. Options come from the native `GoogleService-Info.plist` / `google-services.json`. `lib/firebase_options.dart` exists but isn't used.

`PushMessagingService` (`core/notifications/presentation/`) owns the FCM lifecycle:
- `start()` requests permission, registers the device as a session via the API, and shows foreground pushes through `LocalNotifications`.
- `signOut()` deletes that session. It needs the bearer token, so it **must run before tokens are cleared**.
- A push's `data.route` names the screen to open on tap.
- The background handler must stay top-level with `@pragma('vm:entry-point')`.

### Payments

Checkout happens on the payment provider's website, so the app is never told the result. Before handing off, `purchaseWatchProvider` records which course ids the student already owns. On each app resume, `AppScreen` refetches `myCoursesControllerProvider` and compares. A new course means the purchase succeeded: it shows `showPurchaseSuccessDialog` and stops the watch. Otherwise it keeps watching until the next resume.

### Streak activity

The streak counts UTC days on which `POST user/me/activity` was called. Study actions call `ref.read(activityRecorderProvider).record()` (`core/user/presentation/activity_recorder.dart`): the AI speaking partner starting to listen, a lesson video's first play, and opening a lesson's tasks. The recorder skips calls once today has succeeded, swallows failures, and invalidates `streakProvider` when the API says the day was newly recorded. Hook new study features into it the same way.

### App updates

`AppUpgradeAlert` wraps the app (from `MaterialApp.router`'s `builder`, so it has a Navigator and localizations) and shows `upgrader`'s store prompt once the splash screen is gone. Setting `minSupportedAppVersion` in `app_upgrade_alert.dart` makes the prompt unskippable for older builds. Use that when an API change breaks old clients.

### Groups and mentors

There is no more 1:1 mentor booking — a student's only mentor relationship is through their
current **group**, a named cohort (mentor team + student roster + schedule) that's fully
admin-managed (`core/groups/`, `GET student/groups/me`, nullable if ungrouped). `MyGroupCard`
shows it at the top of `MentorsPage`. The `core/mentors/` domain is still separate and still lets a
student browse mentor profiles and leave feedback (`GET student/mentors`, `POST
student/mentors/:id/feedbacks`) — it just no longer has a per-mentor schedule or booking action.

### Live lessons

Two distinct concepts with confusingly similar names:
- `courses/domain/entity/live_lesson_entity.dart` — a recorded session tied to a **group**
  (`GET student/live-lesson-recordings/my`), played back with `video_player` + `chewie` in
  `LiveSessionScreen`. The API only attaches the group relation here, not a mentor, so the card
  shows the group's title (`groupTitle`) rather than a mentor name.
- `live_lessons/domain/entity/live_lesson_scheduled_entity.dart` — an upcoming scheduled lesson for
  the student's current group, from `GET student/live-lessons`, shown on the home page. This one
  does carry a flat `mentor` relation (whoever scheduled it).

### Localization

The app ships in **Uzbek, Russian and English**, via `flutter_localizations` + `gen-l10n`. Strings live in `lib/l10n/app_{en,ru,uz}.arb`; `app_en.arb` is the template (add a key there first, then translate it in the other two). The generated `app_localizations*.dart` files sit next to them and **are checked in** — regenerate with `flutter gen-l10n` after any `.arb` edit. Missing translations fall back to the English template instead of throwing, and are listed in `l10n_untranslated.txt` (`{}` means complete).

- Screens read `AppLocalizations.of(context)` — non-null, since everything is under `MaterialApp`. Convention is `final l10n = AppLocalizations.of(context);` at the top of `build` when a screen uses more than one or two strings.
- Anything shown to a student belongs in the `.arb`, including empty states, validation messages and semantics labels. Keys are screen-prefixed camelCase (`coursesMyCourses`, `otpResendIn`); shared wording goes under `common*`.
- Counts use ICU plurals (`courseLessonCount`, `plansDuration`) so Russian gets its one/few/many forms. Numbers that need grouping declare `"format": "decimalPattern"`.
- **Dates and times** go through `lib/utils/date_format.dart`, which wraps `MaterialLocalizations` — never hand-roll a month table or an AM/PM suffix.
- `AppLanguage` (`lib/app/locale/app_language.dart`) is the list of shipped languages, in the order `supportedLocales` uses; Uzbek is first, so an unmatched device language falls back to it. Each option is labelled in its own language.
- The chosen language lives in `localeControllerProvider` and is persisted by `LocaleStorage` (`app_language` in `SharedPreferences`). `main` reads it before `runApp` and seeds `startupLanguageProvider`, so the first frame is already in the right language. Null means "never chosen", which is what sends `SplashScreen` to `LanguageScreen` (`/language?next=…`, carrying the destination it had worked out). It can be changed later from the profile's settings card.
- Tests pump screens through `test/support/localized_app.dart` (`localizedApp` / `localizedHome`) — a bare `MaterialApp` has no delegates and any localized screen will throw. They default to English, and take a `locale:` to check another.
- Not localized: server-sent error messages (`apiErrorMessage` only translates its own fallback) and the Android notification channel name.

### Theme

Material 3. Seed/primary `#18c96a` (green), scaffold background `#f6f7fa`, `onSurface` `#111827`, `onSurfaceVariant` `#6b7280`. Light mode only — there is no dark theme. Brand colours outside the `ColorScheme` (dark-teal `ink`, panel/streak/promo fills) live in `AppColors`; add new ones there rather than inlining hex values. Spacing constants in `AppSpacing` (4/8/12/16/24/32), radii in `AppRadius` (8/12/16/9999).

**Typography is deliberately not set.** `app_theme.dart` overrides no `textTheme`/`fontFamily`, so `ThemeData` resolves the platform system font — SF Pro on iOS/macOS, Roboto on Android. Apple's font licence forbids embedding SF Pro in an app bundle, so it must come from the OS; don't add it to `assets/` or set a `fontFamily`.

### Buttons

`AppButton` (`lib/shared/widget/app_button.dart`) is the only button style — a chunky pill with a solid 3D bottom edge that sinks on press. Three variants: `.filled` (primary CTA, theme green + gloss stripes), `.outlined` (dark teal border/text), `.white` (neutral secondary). Total height is `height + depth` (default 56 + 6), so don't wrap it in a fixed-height `SizedBox`; width comes from the parent. `onTap: null` disables; `isLoading` swaps in a spinner and blocks taps.

Material's `FilledButton`/`OutlinedButton`/`ElevatedButton` are no longer used anywhere in `lib/`. `TextButton` survives only for inline links (Forgot Password, Resend code) and `AlertDialog` actions.

Navbar and several UI icons are SVGs in `assets/icons/` rendered with `flutter_svg` and tinted via `ColorFilter`.

## Backend

The NestJS API is a separate project. **Never edit backend files** — describe the required API change as instructions instead.
