import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/auth/domain/entity/otp_purpose.dart';
import 'package:student/core/auth/presentation/otp_controller.dart';
import 'package:student/core/auth/presentation/recover_password_controller.dart';
import 'package:student/core/auth/presentation/register_controller.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_flat_pill_button.dart';
import 'package:student/shared/widget/otp_field.dart';
import 'package:student/ui/auth/login_screen.dart';
import 'package:student/ui/auth/register_screen.dart';
import 'package:student/utils/messenger.dart';

enum OtpMode { register, recoverPassword }

class OtpScreen extends ConsumerStatefulWidget {
  static const path = '/otp';

  final String phoneNumber;
  final String? email;
  final OtpMode mode;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.mode,
    this.email,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  /// The registration API allows one resend every 2 minutes. Recovery's own
  /// limit is a minute, but both screens wait the same 2.
  static const _resendCooldown = 120;

  int _secondsLeft = _resendCooldown;
  Timer? _resendTimer;
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _secondsLeft = _resendCooldown);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          t.cancel();
        }
      });
    });
  }

  void _resend() {
    if (widget.mode == OtpMode.register) {
      // Same identity, so the API reuses the session — and un-verifies it,
      // which is fine: the student hasn't got past this screen yet.
      _resendRegister();
    } else {
      ref
          .read(otpControllerProvider.notifier)
          .sendOtp(
            phoneNumber: widget.phoneNumber,
            purpose: OtpPurpose.recover,
          );
    }
    // Started even if the request fails: the API's own cooldown has begun
    // either way, and the countdown is what tells the student to wait.
    _startResendTimer();
  }

  Future<void> _resendRegister() async {
    final sent = await ref
        .read(registerControllerProvider.notifier)
        .sendOtp(
          phoneNumber: widget.email == null ? widget.phoneNumber : null,
          email: widget.email,
        );
    if (!sent && mounted) _showRegisterError();
  }

  Future<void> _onCodeCompleted(String code) async {
    if (widget.mode == OtpMode.recoverPassword) {
      ref
          .read(recoverPasswordControllerProvider.notifier)
          .confirmRecovery(code);
      return;
    }
    final verified = await ref
        .read(registerControllerProvider.notifier)
        .verifyOtp(code);
    if (!mounted) return;
    if (!verified) {
      _showRegisterError();
      return;
    }
    // Replaced rather than pushed: the code is spent, so backing out of the
    // profile form should land on the login screen, not on this one.
    context.pushReplacement(RegisterScreen.path);
  }

  void _showRegisterError() => showErrorMessage(
    context,
    apiErrorMessage(context, ref.read(registerControllerProvider).error!),
  );

  String get _formattedPhone {
    final digits = widget.phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('998')) {
      final local = digits.substring(3);
      return '+998 ${local.substring(0, 2)} ${local.substring(2, 5)} ${local.substring(5, 7)} ${local.substring(7)}';
    }
    return '+$digits';
  }

  bool get _codeComplete => _codeController.text.length == 6;

  void _submit() {
    if (_codeComplete) _onCodeCompleted(_codeController.text);
  }

  String get _countdown {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == OtpMode.recoverPassword) {
      ref.listen<AsyncValue<void>>(recoverPasswordControllerProvider, (
        prev,
        next,
      ) {
        if (prev?.isLoading != true) return;
        next.whenOrNull(
          data: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).otpPasswordUpdated),
              ),
            );
            context.go(LoginScreen.path);
          },
          error: (e, _) =>
              showErrorMessage(context, apiErrorMessage(context, e)),
        );
      });
    }

    // A recovery resend can be refused — one code a minute, five an hour — and
    // the student would otherwise be left watching a countdown for a code that
    // was never sent. (Registration reports its own, in [_resendRegister].)
    ref.listen<AsyncValue<void>>(otpControllerProvider, (prev, next) {
      if (prev?.isLoading != true) return;
      next.whenOrNull(
        error: (e, _) => showErrorMessage(context, apiErrorMessage(context, e)),
      );
    });

    final l10n = AppLocalizations.of(context);
    final isLoading = widget.mode == OtpMode.register
        ? ref.watch(registerControllerProvider).isLoading
        : ref.watch(recoverPasswordControllerProvider).isLoading;

    // The destination is bold and dark inside an otherwise grey sentence;
    // splitting on a stand-in keeps each language's word order.
    const marker = '\u0000';
    final sentence = widget.email == null
        ? l10n.otpSubtitle(marker)
        : l10n.otpEmailSubtitle(marker);
    final parts = sentence.split(marker);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  0,
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _BackButton(onTap: context.pop),
                    ),
                    Image.asset('assets/images/ic_key.png', width: 40),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.otpEnterCode,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _title,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: parts.first),
                            TextSpan(
                              text: widget.email ?? _formattedPhone,
                              style: const TextStyle(color: _destinationInk),
                            ),
                            if (parts.length > 1) TextSpan(text: parts.last),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    OtpField(
                      controller: _codeController,
                      enabled: !isLoading,
                      onChanged: (_) => setState(() {}),
                      onCompleted: _onCodeCompleted,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_secondsLeft > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.watch_later_rounded,
                            color: _timerBlue,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _countdown,
                            style: const TextStyle(
                              color: _timerBlue,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                children: [
                  AppFlatPillButton(
                    label: l10n.otpResend,
                    background: const Color(0xFFF2F2F6),
                    foreground: _ink,
                    onTap: _secondsLeft == 0 && !isLoading ? _resend : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppFlatPillButton(
                    label: l10n.commonContinue,
                    background: _brandGreen,
                    foreground: Colors.white,
                    onTap: _codeComplete && !isLoading ? _submit : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _brandGreen = Color(0xFF78C93C);
const _ink = Color(0xFF111827);
const _title = Color(0xFF15141A);
const _destinationInk = Color(0xFF343539);
const _muted = Color(0xFF989DB5);
const _timerBlue = Color(0xFF53ADF0);

/// The redesign's back button: a pale rounded square rather than the older
/// white circle of `BackIconButton`.
class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4F5FB),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/arrow_left.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(_ink, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}
