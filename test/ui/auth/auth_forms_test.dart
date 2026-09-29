import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/shared/widget/app_flat_pill_button.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_theme.dart';
import 'package:student/core/auth/data/repository/auth_repository.dart';
import 'package:student/core/auth/domain/entity/auth_entity.dart';
import 'package:student/core/auth/domain/entity/otp_purpose.dart';
import 'package:student/core/auth/domain/repository/i_auth_repository.dart';
import 'package:student/core/user/domain/entity/gender.dart';
import 'package:student/core/user/domain/entity/student_level.dart';
import 'package:student/core/auth/presentation/register_controller.dart';
import 'package:student/core/user/domain/entity/user_entity.dart';
import 'package:student/core/user/domain/usecase/use_get_me.dart';
import 'package:student/ui/auth/forgot_password_screen.dart';
import 'package:student/ui/auth/login_screen.dart';
import 'package:student/ui/auth/otp_screen.dart';
import 'package:student/ui/auth/register_screen.dart';

import '../../support/localized_app.dart';

/// Records what the new check-then-password login flow asks the API for,
/// and can be made to answer "no account" for either identity.
class _FakeAuthRepository implements IAuthRepository, IEmailAuthRepository {
  bool phoneExists = true;
  bool emailExists = true;
  final List<String> checkedPhones = [];
  final List<String> checkedEmails = [];

  @override
  Future<bool> checkPhoneExists(String phoneNumber) async {
    checkedPhones.add(phoneNumber);
    return phoneExists;
  }

  @override
  Future<bool> checkEmailExists(String email) async {
    checkedEmails.add(email);
    return emailExists;
  }

  @override
  Future<AuthEntity> signIn({
    required String phoneNumber,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<AuthEntity> signInWithEmail({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  final List<({String? phoneNumber, String? email})> registerOtpRequests = [];

  @override
  Future<String> sendRegisterOtp({String? phoneNumber, String? email}) async {
    registerOtpRequests.add((phoneNumber: phoneNumber, email: email));
    return 'session-1';
  }

  @override
  Future<void> verifyRegisterOtp({
    required String sessionId,
    required String code,
  }) async {}

  final List<
    ({
      String firstName,
      String? lastName,
      String password,
      Gender gender,
      String? avatarPath,
    })
  >
  registrations = [];

  @override
  Future<AuthEntity> register({
    required String sessionId,
    required String firstName,
    String? lastName,
    required String password,
    StudentLevel? level,
    required Gender gender,
    String? avatarPath,
  }) async {
    registrations.add((
      firstName: firstName,
      lastName: lastName,
      password: password,
      gender: gender,
      avatarPath: avatarPath,
    ));
    return const AuthEntity(accessToken: 'a', refreshToken: 'r');
  }

  @override
  Future<void> sendOtp({
    required String phoneNumber,
    required OtpPurpose purpose,
  }) async {}

  @override
  Future<void> sendEmailOtp({
    required String email,
    required OtpPurpose purpose,
  }) async {}

  @override
  Future<void> recoverPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
  }) async {}
}

Future<void> _pump(
  WidgetTester tester,
  Widget screen, {
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(390, 844) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final container = ProviderContainer();
  addTearDown(container.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: localizedApp(
        theme: container.read(appThemeProvider),
        routerConfig: GoRouter(
          routes: [
            GoRoute(path: '/', builder: (_, _) => screen),
            // Stubbed: these tests check what the login screen hands over.
            GoRoute(
              path: OtpScreen.path,
              builder: (_, state) =>
                  Scaffold(body: Text('otp ${state.uri.query}')),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('LoginScreen', () {
    Future<_FakeAuthRepository> pumpLogin(WidgetTester tester) async {
      final repo = _FakeAuthRepository();
      await _pump(
        tester,
        const LoginScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
      );
      return repo;
    }

    testWidgets('Continue stays disabled until the phone number is full', (
      tester,
    ) async {
      final repo = await pumpLogin(tester);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(repo.checkedPhones, isEmpty);

      await tester.enterText(_field('login-phone-digits'), '90123456');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(repo.checkedPhones, isEmpty, reason: 'only 8 digits so far');

      await tester.enterText(_field('login-phone-digits'), '901234567');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(repo.checkedPhones, ['998901234567']);
    });

    testWidgets('an existing account reveals the password field', (
      tester,
    ) async {
      await pumpLogin(tester);

      await tester.enterText(_field('login-phone-digits'), '901234567');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Password'), findsOneWidget);
      // The headline also happens to read "Log in" in English — the button
      // relabels to it once confirmed, so there are now two.
      expect(find.text('Log in'), findsNWidgets(2));
    });

    testWidgets('no account sends a registration code and opens OTP', (
      tester,
    ) async {
      final repo = await pumpLogin(tester);
      repo.phoneExists = false;

      await tester.enterText(_field('login-phone-digits'), '901234567');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(repo.registerOtpRequests, [
        (phoneNumber: '998901234567', email: null),
      ]);
      expect(find.text('otp phone=998901234567&mode=register'), findsOneWidget);
    });

    testWidgets('no account by email registers with the email', (tester) async {
      final repo = await pumpLogin(tester);
      repo.emailExists = false;
      await tester.tap(find.text('Via email'));
      await tester.pumpAndSettle();

      await tester.enterText(_field('login-email'), 'Sevara@Example.com');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(repo.registerOtpRequests, [
        (phoneNumber: null, email: 'sevara@example.com'),
      ]);
      expect(
        find.text('otp email=sevara%40example.com&mode=register'),
        findsOneWidget,
      );
    });

    testWidgets('editing the phone after confirming hides the password field', (
      tester,
    ) async {
      await pumpLogin(tester);

      await tester.enterText(_field('login-phone-digits'), '901234567');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Password'), findsOneWidget);

      await tester.enterText(_field('login-phone-digits'), '901234560');
      await tester.pumpAndSettle();

      expect(find.text('Password'), findsNothing);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('moving the cursor in the phone keeps the password field', (
      tester,
    ) async {
      await pumpLogin(tester);

      final phone = _field('login-phone-digits');
      await tester.enterText(phone, '901234567');
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(phone).controller!.text, '90 123 45 67');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Password'), findsOneWidget);

      tester.widget<TextField>(phone).controller!.selection =
          const TextSelection(baseOffset: 0, extentOffset: 5);
      await tester.pumpAndSettle();

      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('typing the phone digit by digit enables Continue', (
      tester,
    ) async {
      await pumpLogin(tester);
      final phone = _field('login-phone-digits');
      AppFlatPillButton continueButton() => tester.widget<AppFlatPillButton>(
        find.widgetWithText(AppFlatPillButton, 'Continue'),
      );

      // Like a keyboard: each keystroke appends to the already-grouped text.
      for (final digit in '901234567'.split('')) {
        expect(continueButton().onTap, isNull);
        final current = tester.widget<TextField>(phone).controller!.text;
        await tester.enterText(phone, '$current$digit');
        await tester.pump();
      }

      expect(tester.widget<TextField>(phone).controller!.text, '90 123 45 67');
      expect(continueButton().onTap, isNotNull);
    });

    testWidgets('switching the login type clears the input', (tester) async {
      await pumpLogin(tester);
      final phone = _field('login-phone-digits');

      await tester.enterText(phone, '901234567');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Via email'));
      await tester.pumpAndSettle();
      final email = _field('login-email');
      expect(tester.widget<TextField>(email).controller!.text, isEmpty);

      await tester.enterText(email, 'student@mail.com');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Via phone'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(phone).controller!.text, isEmpty);
      expect(
        tester
            .widget<AppFlatPillButton>(
              find.widgetWithText(AppFlatPillButton, 'Continue'),
            )
            .onTap,
        isNull,
      );
    });

    testWidgets('switching to email swaps the input and the subtitle', (
      tester,
    ) async {
      await pumpLogin(tester);

      await tester.tap(find.text('Via email'));
      await tester.pumpAndSettle();

      expect(_field('login-email'), findsOneWidget);
      expect(find.text('example@mail.com'), findsOneWidget);
      expect(
        find.text('Enter your email to sign in to your account'),
        findsOneWidget,
      );
    });

    testWidgets('Telegram is enabled before anything is typed', (tester) async {
      await pumpLogin(tester);

      await tester.tap(find.text('Sign in via Telegram'));
      await tester.pumpAndSettle();

      expect(find.text("Telegram sign-in isn't available yet"), findsOneWidget);
    });

    testWidgets('Continue stays disabled until the email is valid', (
      tester,
    ) async {
      final repo = await pumpLogin(tester);
      await tester.tap(find.text('Via email'));
      await tester.pumpAndSettle();

      final email = _field('login-email');
      await tester.enterText(email, 'student@mail');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(repo.checkedEmails, isEmpty);

      await tester.enterText(email, 'student@mail.com');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(repo.checkedEmails, ['student@mail.com']);
    });
  });

  group('ForgotPasswordScreen', () {
    testWidgets('requires the confirmation to match', (tester) async {
      await _pump(tester, const ForgotPasswordScreen());

      await tester.enterText(find.byType(TextFormField).at(0), '901234567');
      await tester.enterText(find.byType(TextFormField).at(1), 'hunter2hunter');
      await tester.enterText(find.byType(TextFormField).at(2), 'different-one');
      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('has a show/hide toggle on both password fields', (
      tester,
    ) async {
      await _pump(tester, const ForgotPasswordScreen());

      expect(find.byIcon(Icons.visibility_off_outlined), findsNWidgets(2));
    });
  });

  group('RegisterScreen', () {
    /// Pumps the profile form the way the flow reaches it: a code was
    /// already sent to [phone] or [email] from the login screen.
    Future<_FakeAuthRepository> pumpRegister(
      WidgetTester tester, {
      String? phone = '998901234567',
      String? email,
      String? pickedAvatar,
    }) async {
      tester.view.physicalSize = const Size(390, 844) * 2;
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      final repo = _FakeAuthRepository();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(repo),
          avatarPickerProvider.overrideWithValue(() async => pickedAvatar),
          // The account is created before /me is fetched; failing here keeps
          // the test off the network and on this screen.
          useGetMeProvider.overrideWithValue(_FailingGetMe()),
        ],
      );
      addTearDown(container.dispose);
      await container
          .read(registerControllerProvider.notifier)
          .sendOtp(phoneNumber: email == null ? phone : null, email: email);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: localizedApp(
            theme: container.read(appThemeProvider),
            routerConfig: GoRouter(
              routes: [
                GoRoute(path: '/', builder: (_, _) => const RegisterScreen()),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return repo;
    }

    AppFlatPillButton submitButton(WidgetTester tester) =>
        tester.widget<AppFlatPillButton>(
          find.widgetWithText(AppFlatPillButton, 'Sign up'),
        );

    String fieldText(WidgetTester tester, String key) => tester
        .widget<TextField>(
          find
              .descendant(
                of: find.byKey(ValueKey(key)),
                matching: find.byType(TextField),
              )
              .first,
        )
        .controller!
        .text;

    testWidgets('shows the phone typed on login, read-only', (tester) async {
      await pumpRegister(tester);

      expect(find.text('Phone number'), findsOneWidget);
      expect(fieldText(tester, 'register-identity'), '+998 90 123 45 67');
      final field = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const ValueKey('register-identity')),
          matching: find.byType(TextField),
        ),
      );
      expect(field.readOnly, isTrue);
    });

    testWidgets('an email sign-up shows the email instead', (tester) async {
      await pumpRegister(tester, email: 'sevara@example.com');

      expect(find.text('Email address'), findsOneWidget);
      expect(fieldText(tester, 'register-identity'), 'sevara@example.com');
    });

    testWidgets(
      'Sign up waits for a first name, an 8-character password and a gender',
      (tester) async {
        await pumpRegister(tester);
        expect(submitButton(tester).onTap, isNull);

        // A last name and password alone aren't enough, nor is a blank first
        // name.
        await tester.enterText(
          find.byKey(const ValueKey('register-last-name')),
          'Karimova',
        );
        await tester.enterText(
          find.byKey(const ValueKey('register-first-name')),
          '   ',
        );
        await tester.enterText(
          find.byKey(const ValueKey('register-password')),
          'secret123',
        );
        await tester.pump();
        expect(submitButton(tester).onTap, isNull);

        await tester.enterText(
          find.byKey(const ValueKey('register-first-name')),
          'Sevara',
        );
        await tester.enterText(
          find.byKey(const ValueKey('register-password')),
          'short',
        );
        await tester.pump();
        expect(submitButton(tester).onTap, isNull);

        await tester.enterText(
          find.byKey(const ValueKey('register-password')),
          'secret123',
        );
        await tester.pump();
        expect(submitButton(tester).onTap, isNull);

        await tester.tap(find.text('Male'));
        await tester.pump();
        expect(submitButton(tester).onTap, isNotNull);
      },
    );

    testWidgets('sends trimmed first and last names, gender and avatar', (
      tester,
    ) async {
      final repo = await pumpRegister(tester, pickedAvatar: '/tmp/me.jpg');

      await tester.tap(find.text('Change photo'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('register-first-name')),
        '  Sevara ',
      );
      await tester.enterText(
        find.byKey(const ValueKey('register-last-name')),
        ' Karimova Aliyevna  ',
      );
      await tester.enterText(
        find.byKey(const ValueKey('register-password')),
        'secret123',
      );
      await tester.tap(find.text('Female'));
      await tester.pump();
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      expect(repo.registrations, [
        (
          firstName: 'Sevara',
          lastName: 'Karimova Aliyevna',
          password: 'secret123',
          gender: Gender.female,
          avatarPath: '/tmp/me.jpg',
        ),
      ]);
    });

    testWidgets('a blank last name is sent as null, without an avatar', (
      tester,
    ) async {
      final repo = await pumpRegister(tester);

      await tester.enterText(
        find.byKey(const ValueKey('register-first-name')),
        'Sevara',
      );
      await tester.enterText(
        find.byKey(const ValueKey('register-last-name')),
        '   ',
      );
      await tester.enterText(
        find.byKey(const ValueKey('register-password')),
        'secret123',
      );
      await tester.tap(find.text('Male'));
      await tester.pump();
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      expect(repo.registrations.single.firstName, 'Sevara');
      expect(repo.registrations.single.lastName, isNull);
      expect(repo.registrations.single.avatarPath, isNull);
      expect(repo.registrations.single.gender, Gender.male);
    });
  });
}

class _FailingGetMe implements UseGetMe {
  @override
  Future<UserEntity> call() async => throw Exception('offline');
}

/// The `TextField` inside the [AppTextField] keyed [key].
Finder _field(String key) => find.descendant(
  of: find.byKey(ValueKey(key)),
  matching: find.byType(TextField),
);
