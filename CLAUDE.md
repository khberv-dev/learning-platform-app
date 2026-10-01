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

**Domains:** `assessments`, `auth`, `chat`, `courses`, `diagnostics`, `enrollments`, `groups`, `main`, `mentors`, `notifications`, `p2p`, `payments`, `plans`, `startup`, `subscriptions`, `user`

Not every domain has all three layers. `assessments` has no presentation layer, since `AiSpeakingPartnerScreen` drives it directly. `p2p` uses sockets and WebRTC only, with no data layer. `main` is just `navbar_controller.dart`. `diagnostics` is just crash reporting (see below). `startup` keeps UI-only value objects in `domain/model/` (survey queries, illustrations) alongside its entities.

Shared widgets live in `lib/shared/widget/`, **not** under `lib/ui/`. A widget graduates there once a second feature needs it; otherwise it stays in `lib/ui/<feature>/widget/`.

### Data flow convention

`*Response` (data layer) → `.toEntity()` → `*Entity` (domain layer). **Screens import entities only, never response models.** Use cases are thin single-method wrappers (`class UseX { Future<T> call() => _repo.x(); }`) over a repository interface.

Each layer exposes a Riverpod provider next to its class:

```dart
final groupsRepositoryProvider = Provider<IGroupsRepository>(
  (ref) => GroupsRepository(dio: ref.read(dioClientProvider)),
);
final useGetMyGroupsProvider = Provider(...);
final myGroupsControllerProvider = AsyncNotifierProvider<MyGroupsController, List<...>>(...);
```

List endpoints often return an envelope — `response.data['data'] as List` — while detail endpoints return the object directly. Check the endpoint before assuming.

### State management (Riverpod 3)

- `Provider` — repositories and use cases
- `AsyncNotifierProvider` / `NotifierProvider` — stateful controllers (`MyGroupsController`, `P2pController`, `SkillQuestionsNotifier`)
- `StateProvider` / `StateNotifierProvider` — simple shared state (`currentUserProvider`, `navbarControllerProvider`, `chatMessagesProvider`)

**Gotcha:** in Riverpod 3 the legacy APIs (`StateProvider`, `StateNotifierProvider`, `StateNotifier`) require an extra `import 'package:flutter_riverpod/legacy.dart';`. Three files currently do this — new code should prefer `Notifier`/`AsyncNotifier`.

Controllers live in `core/<domain>/presentation/` and are consumed by screens in `ui/`.

### Networking

`dioClientProvider` (`lib/app/data/network/dio_client.dart`) builds the shared `Dio`:
- `baseUrl` = `baseApiUrl` from `config.dart`; 10s connect / 90s receive timeout (long receive is for AI assessment audio)
- `AuthInterceptor` — attaches the Bearer token to every request except `auth/refresh`. On 401 it refreshes once, serialising concurrent refreshes through a single `Completer` so only one refresh flies at a time, marks the retried request via `extra['retried']`, and on refresh failure clears tokens and `go`s to `LoginScreen`.
- `TalkerDioLogger` for request/response logging

JWTs are stored in `SharedPreferences` via `TokenStorage` (`access_token` / `refresh_token`). The refresh response is read tolerantly (`accessToken` or `access_token`).

**Host selection:** `lib/app/data/network/config.dart` sets `hostUrl = kDebugMode ? devHostUrl : mainHostUrl`, so debug builds hit a local API at `devHostUrl` (a LAN IP that changes with the developer's network) and release builds hit production (`https://cp.i-teach.uz`). A commented-out `hostUrl = mainHostUrl` line is the toggle for pointing debug at prod. This file changes often as the IP changes; commit it as-is along with everything else — don't flag it. `baseApiUrl` is `$hostUrl/api/v$apiVersion/` (currently v2).

**Media URLs:** the API returns fully-qualified URLs for every file (course images, avatars, payment icons, recordings, …), so screens use them as-is — no CDN base to prepend. `resolveMediaUrl` (`lib/utils/lib.dart`) just turns an empty/missing value into `null` for callers that fall back to a placeholder. They're signed Google Cloud Storage links that **expire after 6 hours** (stable for about 3, so caching by URL works). Never persist them; a 403 on a file means it has expired, and refetching the screen's data gets a fresh one.

### Error handling

`lib/utils/messenger.dart` is the single path for messages. `apiErrorMessage(context, error)` unwraps a `DioException` body (`message` as String or List) into a user-facing string. `showErrorMessage` / `showSuccessMessage(context, title, {detail})` show an `AppFloatingMessage` (`lib/shared/widget/app_floating_message.dart`), the redesign's pale red/green pill with a white badge, a coloured bold title and an optional grey detail line. It isn't a SnackBar: it's an entry on the **root `Overlay`**, pinned under the top safe area. It slides down from above the screen, stays 4s, then slides back up, and a tap or upward swipe dismisses it early. A new message replaces the current one outright. `showErrorOn` / `showSuccessOn` take an `OverlayState` captured with `messageOverlayOf(context)`, for when the screen may be gone by the time the outcome is known. Never use `SnackBar`/`ScaffoldMessenger` directly; there is no neutral variant, so pick success or error.

Course content (lesson detail, lesson materials, tasks) answers **403** when the student isn't enrolled. `isForbidden(error)` detects it, and `LessonLoadError` (`ui/courses/widget/`) turns it into a "buy a plan" prompt instead of an error.

**Crash reporting:** `main.dart` wraps everything in `runZonedGuarded` and installs `FlutterError.onError` / `PlatformDispatcher.instance.onError`, each forwarding to `reportAppError` (`lib/core/diagnostics/error_reporting.dart`). That function is release-build-only (`kReleaseMode`), builds its own bare `Dio` (not `dioClientProvider` — no Riverpod container exists this early, and it must never get pulled into the main client's auth-refresh flow), and posts `{ device, message }` to the public `app-reports` endpoint. It attaches the stored access token as a Bearer header when there is one, since the backend resolves `AppReport.userId` from that token itself rather than a body field — the endpoint has no other place to take a user id from and works fine unauthenticated. Never throws; a failed report must not cause a second crash.

### Routing

All routes are registered flat in `app_router.dart`. Each screen declares its own `static const path`. Navigate with `context.go(Screen.path)` / `context.push(...)`.

Parameter passing is inconsistent by design of the individual routes — some use `pathParameters` (`CourseDetailScreen`, `MentorProfileScreen`), most use `uri.queryParameters` (`OtpScreen`, `TasksScreen`, `LessonScreen`, `ChatRoomScreen`), and `TaskResultsScreen` takes its data via `state.extra`. Follow whatever the existing route does.

`SplashScreen` (`/`) is the auth gate. After its animation it routes to one of:
- `OnboardingScreen` if there is no token
- `AppScreen` if the token is valid and `/me` succeeds (this seeds `currentUserProvider`)
- `NoConnectionScreen` on a 5xx or network error
- `LoginScreen` otherwise

If no language has been chosen yet, it goes through `LanguageScreen` first.

Auth works with either a phone number or an email, toggled by `AuthIdentitySwitch` (`AuthIdentityType.phone`/`.email`). `LoginScreen` is a two-step flow. First the student taps Continue, which calls the public `GET auth/check-phone` / `auth/check-email` (`{exists: bool}`, via `UseCheckIdentityExists`). If the identity exists, the password field appears and the normal sign-in call runs. If it doesn't, **the same screen starts registration**, which is session-based:

1. `POST auth/register/otp/send` returns a `sessionId`. A resend to the same identity reuses the session, with a 2-minute cooldown.
2. `OtpScreen` sends `POST auth/register/otp/verify`.
3. It then replaces itself with `RegisterScreen`, which asks for the profile: an optional avatar, a required first name and an optional last name (separate fields, both trimmed before sending), a password, and an optional gender. The verified phone/email is shown read-only, taken from `RegisterController.phoneNumber`/`email`.
4. `POST auth/register` completes it as **multipart** form data (optional `avatar` image file), with the level from `skillQuizResultProvider`.

`RegisterController` holds the `sessionId`. Its steps return `bool` instead of screens listening to its state, because the login and OTP screens stay mounted under the later steps and would react to them. The placement quiz ends on `LoginScreen`, not `RegisterScreen`. Password recovery still uses the older `auth/otp/send` (purpose `recover`). The identity field must stay editable after the check succeeds, because editing it is what resets the confirmed state. The Telegram button has no backend support yet and only shows a "not available yet" message.

### Main shell

`AppScreen` (`/app`) is an `IndexedStack` of five tabs — Home, Courses, Mission, Study, Profile — driven by `navbarControllerProvider`. Mission is `RoadmapPage` (`ui/roadmap/`), the CEFR ladder drawn as a zigzag of pillars (`RoadmapLayout`); it's a tab only, with no route of its own. It is the first point where a valid token is guaranteed, so it also starts push messaging and checks for completed purchases on app resume (see below).

The navbar is static — five fixed items (indices 0–4 in that order; Courses is 1), `AppNavbar.onItemClick` just sets `navbarControllerProvider`. Chat has no tab of its own: `StudyPage` shows each group's mentor and an "open chat" button for that group's room.

### Realtime (Socket.IO)

Two namespaces, both connected with `setTransports(['websocket'])`, `disableAutoConnect()`, and `setAuth({'token': accessToken})`:

- `$hostUrl/match` — P2P matchmaking (`P2pController`)
- `$hostUrl/chat` — chat messages (`ChatMessagesNotifier`)

Chat messages are kept **newest-first** in state to pair with `ListView(reverse: true)`; the API already returns DESC. `addMessage` dedupes by id, since a message can arrive both from the POST response and the socket echo.

### P2P calling

`P2pController` runs the full lifecycle: Socket.IO matchmaking → `flutter_webrtc` peer connection for audio-only calls. State is a sealed `P2pState` hierarchy (`P2pIdle`, `P2pSearching`, `P2pMatched`, `P2pConnecting`, `P2pConnected`, `P2pEnded`, `P2pError`) with a `P2pRole` enum (`caller`/`callee`). ICE candidates that arrive before the remote description is set are buffered in `_pendingCandidates` and flushed after `setRemoteDescription`.

### AI speaking partner

`AiSpeakingPartnerScreen` (`/ai-speaking-partner`, `ui/ai_assessment/`) is a free, unscored, real-time voice
conversation in English. The home page's "AI suhbatdosh" tile opens it. It starts on an intro, and Start asks for
the microphone. It then fetches an AssemblyAI key from the API (`assessmentRepositoryProvider.getAssemblyAiKey`)
and runs `AssemblyAiVoiceAgent` (`core/assessments/data/`), which streams mic audio over a WebSocket and plays back
the agent's replies. The agent's state (connecting / listening / thinking / speaking) drives the dark in-call view (`AiCallView`).
A green blob marks whoever has the floor: the AI while `speaking`, the student while it's `listening`.
The view shows an elapsed clock that starts on connect, and the call **auto-ends after 10 minutes**
(`callLimit`). Mic mute stops sending audio (`micMuted`). The speaker button silences the AI's voice
(`outputMuted`) rather than switching to the loudspeaker. `flutter_pcm_sound` has no output routing, so a real
speaker toggle would need a new native dependency. Ending, by the red button or the back arrow, leaves the
screen, which disposes the agent. The agent's system prompt is a friendly conversation partner and never
grades the student. Hearing the student
(`listening`) records streak activity. `AiResultsScreen` is a leftover of the old scored assessment and nothing
links to it.

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

`AppUpgradeAlert` wraps the app (from `MaterialApp.router`'s `builder`, so it has a Navigator and localizations). Once the splash screen is gone, it shows a store-update prompt as a **bottom sheet**. `upgrader` still does the version check and store lookup; a subclassed `UpgradeAlertState.showTheDialog` swaps its stock dialog for the sheet.

- **Release:** the sheet is unmissable. The scrim, drag and back gesture don't close it. It stays up after "Update" opens the store, and `durationUntilAlertAgain: Duration.zero` shows it again on every launch until the app is updated.
- **Debug:** a stand-in store always reports a newer version, so the sheet appears once per launch and can be dismissed. The `dismissible` parameter (default `kDebugMode`) lets tests check the release behaviour.

### Groups and mentors

There is no more 1:1 mentor booking. A student's only mentor relationship is through their
**groups**. A group is a named cohort studying one `course`, with a single `primaryMentor`, a student
roster and a schedule, and it's fully admin-managed. A student can be in several groups, one per
course. `GET student/groups/me` (`core/groups/`) is paginated (`{ data, total, … }`, empty if
ungrouped). `GroupResponse` still falls back to the older `mentors` role list for the primary mentor.
`StudyPage` (`ui/study/`, the navbar's Study tab) shows each group as a card and then its mentors:
- **Card:** the group picture, name, member count, and a "join the group" button into that group's chat room.
  `GET student/chat/rooms` returns one room per group, matched by `room.group.id`. The button is hidden when
  the group has no room.
- **Mentors:** the primary mentor, then any `supportMentors`. The API sends none at the moment, so that row
  only appears if it does.

With no groups, it shows a "buy a course" prompt that opens the Courses tab. A student who already owns a
course but isn't grouped yet sees "you'll be added soon" instead. The `core/mentors/` domain is still separate and still
lets a student view one mentor's profile and leave feedback (`GET student/mentors/:id`, `POST
student/mentors/:id/feedbacks`) — there's no browse-all-mentors listing anymore, since the only way
to reach a mentor profile now is through your own group.

### Profile and subscriptions

A subscription is paid access to one course for a period. A student can hold several, one per course
(`core/subscriptions/`, `GET student/subscriptions`, paginated). `SubscriptionEntity.isCurrentAt(now)`
means flagged `isActive` *and* not yet past `end`. `ProfilePage` picks its plan card via `PlanStatus.of`
(`ui/profile/widget/subscription_card.dart`):
- **Active:** one blue card per current subscription, soonest to end first.
- **None:** a "choose a plan" card that opens the Courses tab, since plans are sold per course.
- **Expired:** a "renew" card for the one that ended last, opening that course's plans.

`AppScreen` refetches subscriptions on every post-checkout resume. Language, log out and delete account
all confirm in bottom sheets (`language_sheet.dart`, and the shared `showConfirmSheet` in
`lib/shared/widget/app_confirm_sheet.dart`), not dialogs.

### Live lessons

**Removed for now, pending a refactored version.** The app has no live lessons or recordings: no
`live_lessons` domain, no `student/live-lessons` or `student/live-lesson-recordings/my` calls, no
home-page live/upcoming sections, and no "Live sessions" tab on the Courses page (which is now a
single list with no tab bar).

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

**A full visual redesign is in progress, one screen at a time.** For a screen being redesigned, the reference mockups the user supplies override everything below (colours, spacing, shared widgets). Sample exact colours from the screenshots rather than reusing old theme constants. So far `LanguageScreen`, `OnboardingScreen` and `LoginScreen` are redesigned. Screens not yet touched still use the old system described here.

Redesigned startup/auth screens share one layout: a `Column` with an `Expanded` top image (`BoxFit.cover`, `Alignment.topCenter`, in a `ClipRect`) above a bottom card pinned flush to the bottom, and no scroll view. **`Expanded` must not be placed directly inside a `Stack`.** That fails at runtime with a `ParentDataWidget` assertion, which `flutter analyze` doesn't catch. Only a widget test that pumps the screen reveals it.

Material 3. Seed/primary `#18c96a` (green), scaffold background `#f6f7fa`, `onSurface` `#111827`, `onSurfaceVariant` `#6b7280`. Light mode only — there is no dark theme. Brand colours outside the `ColorScheme` (dark-teal `ink`, panel/streak/promo fills) live in `AppColors`; add new ones there rather than inlining hex values. Spacing constants in `AppSpacing` (4/8/12/16/24/32), radii in `AppRadius` (8/12/16/9999).

**Typeface: M PLUS Rounded 1c app-wide**, standing in for SF Pro Rounded — Apple's font licence forbids embedding SF Pro (or its rounded variant) in an app bundle, and it isn't installed on Android at all, so an openly-licensed (OFL) rounded look-alike is bundled instead and applied on both platforms. `app_theme.dart` sets it via `ThemeData.light().textTheme.apply(fontFamily: 'MPLUSRounded1c')` (plus `primaryTextTheme`), which rewrites every default text style's font while leaving size/weight/color alone — that reaches both `Theme.of(context).textTheme.*` usages and the plain `TextStyle(...)` literals most screens use, since those inherit `fontFamily` from the ambient `DefaultTextStyle` when they don't set their own. Font files live in `assets/fonts/MPLUSRounded1c/` (7 weights, 100–900), registered under `flutter.fonts` in `pubspec.yaml`. Don't add real SF Pro/SF Pro Rounded files to the repo — same licence restriction as before, now just naming the rounded variant too.

The font files are **subsetted** to Latin, Cyrillic, general punctuation and arrows, with the CJK glyphs stripped out. Any character outside those ranges renders as a missing-glyph box, so if new copy needs one, re-subset from a fresh download. The font also renders bold text noticeably wider than the old system font, so check tightly sized bold rows with a widget test (fixes used so far: `FittedBox(fit: BoxFit.scaleDown)`, or `Flexible` + ellipsis).

### Text fields

`AppTextField` (`lib/shared/widget/app_text_field.dart`) is the redesign's form input, used on login, register and forgot password. It has a grey caption above a borderless `#F2F4F9` field that is 52pt tall with a 16pt radius. It's meant to sit on a **white** background, since `#F2F4F9` vanishes on the old `#F1F1F3` screen colour. `prefixText` (e.g. `+998`) is always visible and followed by a thin divider, unlike Material's own `prefixText`. `obscureText` adds its own show/hide toggle. A `key` on it lands on the wrapper, so tests reach the input with `find.descendant(of: find.byKey(...), matching: find.byType(TextField))`. Chat, task and feedback inputs are their own widgets and don't use it.

### Buttons

There are two shared button styles:

- `AppFlatPillButton` (`lib/shared/widget/app_flat_pill_button.dart`) is the **redesign's** button: a flat pill with a soft drop shadow and caller-supplied `background`/`foreground`. `onTap: null` gives a pale, washed-out tint rather than dimming the opacity. Use it on redesigned screens.
- `AppButton` (`lib/shared/widget/app_button.dart`) is the old style, still used on every screen that hasn't been redesigned yet. It is a chunky pill with a solid 3D bottom edge that sinks on press. Three variants: `.filled` (primary CTA, theme green + gloss stripes), `.outlined` (dark teal border/text), `.white` (neutral secondary). Total height is `height + depth` (default 56 + 6), so don't wrap it in a fixed-height `SizedBox`; width comes from the parent. `onTap: null` disables; `isLoading` swaps in a spinner and blocks taps.

Material's `FilledButton`/`OutlinedButton`/`ElevatedButton` are no longer used anywhere in `lib/`. `TextButton` survives only for inline links (Forgot Password, Resend code) and `AlertDialog` actions.

Navbar and several UI icons are SVGs in `assets/icons/` rendered with `flutter_svg` and tinted via `ColorFilter`. **SVG gotcha:** Figma exports often wrap the artwork in an inner-shadow `filter` plus a full-canvas `clip-path` and `mask`. `flutter_svg` draws nothing for that combination, with no error. Strip the wrappers and keep the drawing `<path>`s (as done for `trash.svg` and `crown.svg`). A golden render is the only way to catch it.

## Backend

The NestJS API is a separate project. **Never edit backend files** — describe the required API change as instructions instead.
