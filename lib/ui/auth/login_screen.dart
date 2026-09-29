import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/auth/domain/usecase/use_check_identity_exists.dart';
import 'package:student/core/auth/presentation/login_controller.dart';
import 'package:student/core/auth/presentation/register_controller.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_flat_pill_button.dart';
import 'package:student/shared/widget/app_text_field.dart';
import 'package:student/shared/widget/back_icon_button.dart';
import 'package:student/shared/url_launcher.dart';
import 'package:student/ui/auth/forgot_password_screen.dart';
import 'package:student/ui/auth/otp_screen.dart';
import 'package:student/ui/main/app_screen.dart';
import 'package:student/ui/startup/onboarding_screen.dart';
import 'package:student/utils/messenger.dart';
import 'package:student/utils/uz_phone_formatter.dart';

const _brandGreen = Color(0xFF78C93C);
const _telegramBlue = Color(0xFF4A9FE0);
const _ink = Color(0xFF111827);
const _muted = Color(0xFF6B7280);

enum _IdentityMode { phone, email }

/// Redesigned login: phone (or email) first, checked against the API before
/// the password field appears at all — a student who mistypes a number never
/// even sees a password prompt for it.
///
/// Same "no hard-coded chrome" spirit as [LanguageScreen]/[OnboardingScreen],
/// but this one scrolls: unlike those, its content height changes (the
/// password field appears/disappears), so it keeps the classic
/// Expanded-scroll-area-plus-fixed-bottom-bar shape rather than a rigid
/// no-scroll Column.
class LoginScreen extends ConsumerStatefulWidget {
  static const path = '/login';

  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Holds the formatted `XX XXX XX XX` text; [_phoneDigits] strips it.
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  _IdentityMode _mode = _IdentityMode.phone;
  bool _identityConfirmed = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordEdited);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Controllers also notify on cursor moves and selection changes — only a
  // real text edit should count as editing the identity.
  String _lastPhoneText = '';
  String _lastEmailText = '';

  void _onPhoneChanged() {
    if (_phoneController.text == _lastPhoneText) return;
    _lastPhoneText = _phoneController.text;
    _onIdentityEdited();
  }

  void _onEmailChanged() {
    if (_emailController.text == _lastEmailText) return;
    _lastEmailText = _emailController.text;
    _onIdentityEdited();
  }

  // Editing the identity after it was confirmed invalidates that check — the
  // password field it revealed belonged to whatever was typed before.
  void _onIdentityEdited() {
    if (_identityConfirmed) {
      setState(() {
        _identityConfirmed = false;
        _passwordController.clear();
      });
    } else {
      setState(() {});
    }
  }

  void _onPasswordEdited() => setState(() {});

  String get _phoneDigits => _phoneController.text.replaceAll(' ', '');

  bool get _phoneComplete => _phoneDigits.length == 9;

  bool get _identityComplete =>
      _mode == _IdentityMode.phone ? _phoneComplete : _isValidEmail;

  bool get _isValidEmail => RegExp(
    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
  ).hasMatch(_emailController.text.trim());

  void _switchMode(_IdentityMode mode) {
    if (_mode == mode) return;
    // Each mode starts empty — a half-typed phone shouldn't linger behind
    // the email tab (or vice versa) and reappear on switching back.
    _phoneController.clear();
    _emailController.clear();
    setState(() {
      _mode = mode;
      _identityConfirmed = false;
      _passwordController.clear();
    });
  }

  Future<void> _onPrimaryTap() async {
    if (_identityConfirmed) {
      _submitSignIn();
    } else {
      await _checkIdentity();
    }
  }

  Future<void> _checkIdentity() async {
    setState(() => _isChecking = true);
    final phone = _mode == _IdentityMode.phone ? '998$_phoneDigits' : null;
    final email = _mode == _IdentityMode.email
        ? _emailController.text.trim().toLowerCase()
        : null;
    try {
      final exists = phone != null
          ? await ref.read(useCheckIdentityExistsProvider).call(phone)
          : await ref.read(useCheckIdentityExistsProvider).callEmail(email!);
      if (!mounted) return;
      if (exists) {
        setState(() {
          _identityConfirmed = true;
          _isChecking = false;
        });
        return;
      }
      // No account yet — this identity registers instead: send it a code
      // and carry on in OtpScreen, then RegisterScreen.
      final register = ref.read(registerControllerProvider.notifier);
      final sent = await register.sendOtp(phoneNumber: phone, email: email);
      if (!mounted) return;
      setState(() => _isChecking = false);
      if (!sent) {
        showErrorMessage(
          context,
          apiErrorMessage(context, ref.read(registerControllerProvider).error!),
        );
        return;
      }
      context.push(
        Uri(
          path: OtpScreen.path,
          queryParameters: {
            'phone': ?phone,
            'email': ?email,
            'mode': 'register',
          },
        ).toString(),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isChecking = false);
      showErrorMessage(context, apiErrorMessage(context, e));
    }
  }

  void _submitSignIn() {
    if (_mode == _IdentityMode.email) {
      ref
          .read(loginControllerProvider.notifier)
          .signInWithEmail(
            email: _emailController.text.trim().toLowerCase(),
            password: _passwordController.text,
          );
    } else {
      ref
          .read(loginControllerProvider.notifier)
          .signIn(
            phoneNumber: '998$_phoneDigits',
            password: _passwordController.text,
          );
    }
  }

  void _onTelegramTap() {
    showErrorMessage(
      context,
      AppLocalizations.of(context).loginTelegramUnavailable,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(loginControllerProvider, (prev, next) {
      if (prev?.isLoading != true) return;
      next.whenOrNull(
        data: (_) => context.go(AppScreen.path),
        error: (e, _) => showErrorMessage(context, apiErrorMessage(context, e)),
      );
    });

    final l10n = AppLocalizations.of(context);
    final isSigningIn = ref.watch(loginControllerProvider).isLoading;

    final primaryEnabled = _identityConfirmed
        ? _passwordController.text.length >= 8 && !isSigningIn
        : _identityComplete && !_isChecking;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.md,
                  AppSpacing.xl,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BackIconButton(
                      // Reached with `go` from splash, logout and the level
                      // quiz — nothing to pop then, so fall back to the start.
                      onTap: () => context.canPop()
                          ? context.pop()
                          : context.go(OnboardingScreen.path),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Center(
                      child: Image.asset(
                        'assets/images/ic_login.png',
                        width: 40,
                        height: 40,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Center(
                      child: Text(
                        l10n.loginTitle,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Center(
                      child: Text(
                        _mode == _IdentityMode.phone
                            ? l10n.loginSubtitlePhone
                            : l10n.loginSubtitleEmail,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Center(
                      child: _ModeSwitcher(
                        mode: _mode,
                        phoneLabel: l10n.loginTabPhone,
                        emailLabel: l10n.loginTabEmail,
                        onChanged: _isChecking ? null : _switchMode,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (_mode == _IdentityMode.phone)
                      AppTextField(
                        key: const ValueKey('login-phone-digits'),
                        label: l10n.fieldPhone,
                        controller: _phoneController,
                        prefixText: '+998',
                        hintText: '00 000 00 00',
                        keyboardType: TextInputType.number,
                        inputFormatters: [UzPhoneFormatter()],
                        // Stays editable even once confirmed — correcting a
                        // typo here is what resets the confirmation, via
                        // _onIdentityEdited. Only locked mid-request.
                        enabled: !_isChecking,
                      )
                    else
                      AppTextField(
                        key: const ValueKey('login-email'),
                        label: l10n.fieldEmail,
                        controller: _emailController,
                        hintText: 'example@mail.com',
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ],
                        enabled: !_isChecking,
                      ),
                    if (_identityConfirmed) ...[
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        label: l10n.fieldPassword,
                        controller: _passwordController,
                        hintText: l10n.loginPasswordHint,
                        obscureText: true,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              context.push(ForgotPasswordScreen.path),
                          style: TextButton.styleFrom(
                            foregroundColor: _brandGreen,
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: Text(l10n.loginForgotPassword),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
              child: Column(
                children: [
                  AppFlatPillButton(
                    label: _identityConfirmed
                        ? l10n.loginSubmit
                        : l10n.commonContinue,
                    background: _brandGreen,
                    foreground: Colors.white,
                    onTap: primaryEnabled ? _onPrimaryTap : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _OrDivider(label: l10n.loginOr),
                  const SizedBox(height: AppSpacing.md),
                  AppFlatPillButton(
                    label: l10n.loginTelegram,
                    background: _telegramBlue,
                    foreground: Colors.white,
                    icon: Image.asset(
                      'assets/images/ic_telegram.png',
                      height: 18,
                    ),
                    onTap: _onTelegramTap,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _LegalNotice(l10n: l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mode switcher ────────────────────────────────────────────────────────────

class _ModeSwitcher extends StatelessWidget {
  final _IdentityMode mode;
  final String phoneLabel;
  final String emailLabel;
  final ValueChanged<_IdentityMode>? onChanged;

  const _ModeSwitcher({
    required this.mode,
    required this.phoneLabel,
    required this.emailLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isPhone = mode == _IdentityMode.phone;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E9EE),
        borderRadius: BorderRadius.circular(999),
      ),
      // Both tabs share the wider label's width, so the white thumb can
      // slide between two equal halves instead of jumping between tabs.
      child: IntrinsicWidth(
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                alignment: isPhone
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _ModeTab(
                    label: phoneLabel,
                    isSelected: isPhone,
                    onTap: onChanged == null
                        ? null
                        : () => onChanged!(_IdentityMode.phone),
                  ),
                ),
                Expanded(
                  child: _ModeTab(
                    label: emailLabel,
                    isSelected: !isPhone,
                    onTap: onChanged == null
                        ? null
                        : () => onChanged!(_IdentityMode.email),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _ModeTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          style: TextStyle(
            color: isSelected ? _ink : _muted,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          child: Text(label, textAlign: TextAlign.center, maxLines: 1),
        ),
      ),
    );
  }
}

// ── Big identity inputs ─────────────────────────────────────────────────────

// ── "or" divider ─────────────────────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
  final String label;

  const _OrDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFD1D5DB))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            label,
            style: const TextStyle(color: _muted, fontSize: 13),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFD1D5DB))),
      ],
    );
  }
}

// ── Legal notice ─────────────────────────────────────────────────────────────

const _publicOfferUrl = 'https://i-teach.uz/docs/public_agreement.html';

class _LegalNotice extends ConsumerStatefulWidget {
  final AppLocalizations l10n;

  const _LegalNotice({required this.l10n});

  @override
  ConsumerState<_LegalNotice> createState() => _LegalNoticeState();
}

class _LegalNoticeState extends ConsumerState<_LegalNotice> {
  late final _offerTap = TapGestureRecognizer()..onTap = _open;

  Future<void> _open() async {
    final opened = await ref.read(inAppBrowserLauncherProvider)(
      Uri.parse(_publicOfferUrl),
    );
    if (!opened && mounted) {
      showErrorMessage(context, widget.l10n.registerLegalOpenFailed);
    }
  }

  @override
  void dispose() {
    _offerTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(color: _muted, fontSize: 12, height: 1.4);
    const link = TextStyle(
      color: _brandGreen,
      fontWeight: FontWeight.w800,
      decoration: TextDecoration.underline,
      decorationColor: _brandGreen,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: widget.l10n.loginLegalLead),
          TextSpan(
            text: widget.l10n.loginLegalOffer,
            style: link,
            recognizer: _offerTap,
          ),
          TextSpan(text: widget.l10n.loginLegalTail),
        ],
      ),
      textAlign: TextAlign.center,
      style: base,
    );
  }
}
