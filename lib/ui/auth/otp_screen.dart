import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/auth/presentation/otp_controller.dart';
import 'package:student/core/auth/presentation/recover_password_controller.dart';
import 'package:student/core/auth/presentation/register_controller.dart';
import 'package:student/ui/auth/login_screen.dart';
import 'package:student/ui/main/app_screen.dart';
import 'package:student/ui/shared/widget/otp_field.dart';
import 'package:student/utils/messenger.dart';

enum OtpMode { register, recoverPassword }

class OtpScreen extends ConsumerStatefulWidget {
  static const path = '/otp';

  final String phoneNumber;
  final OtpMode mode;

  const OtpScreen({super.key, required this.phoneNumber, required this.mode});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const _resendCooldown = 60;

  int _secondsLeft = _resendCooldown;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
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
    ref
        .read(otpControllerProvider.notifier)
        .sendOtp(phoneNumber: widget.phoneNumber);
    _startResendTimer();
  }

  void _onCodeCompleted(String code) {
    if (widget.mode == OtpMode.register) {
      ref.read(registerControllerProvider.notifier).confirmSignUp(code);
    } else {
      ref
          .read(recoverPasswordControllerProvider.notifier)
          .confirmRecovery(code);
    }
  }

  String get _formattedPhone {
    final digits = widget.phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('998')) {
      final local = digits.substring(3);
      return '+998 ${local.substring(0, 2)} ${local.substring(2, 5)} ${local.substring(5, 7)} ${local.substring(7)}';
    }
    return '+$digits';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == OtpMode.register) {
      ref.listen<AsyncValue<void>>(registerControllerProvider, (prev, next) {
        if (prev?.isLoading != true) return;
        next.whenOrNull(
          data: (_) => context.go(AppScreen.path),
          error: (e, _) => showErrorMessage(context, apiErrorMessage(e)),
        );
      });
    } else {
      ref.listen<AsyncValue<void>>(recoverPasswordControllerProvider, (
        prev,
        next,
      ) {
        if (prev?.isLoading != true) return;
        next.whenOrNull(
          data: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password updated successfully')),
            );
            context.go(LoginScreen.path);
          },
          error: (e, _) => showErrorMessage(context, apiErrorMessage(e)),
        );
      });
    }

    final isLoading = widget.mode == OtpMode.register
        ? ref.watch(registerControllerProvider).isLoading
        : ref.watch(recoverPasswordControllerProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              IconButton(
                onPressed: context.pop,
                icon: SvgPicture.asset('assets/icons/arrow_left.svg'),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Verify Your\nPhone Number',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'We sent a 6-digit code to $_formattedPhone',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Center(
                child: OtpField(
                  enabled: !isLoading,
                  onCompleted: _onCodeCompleted,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: _secondsLeft > 0
                    ? Text(
                        'Resend code in ${_secondsLeft}s',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      )
                    : TextButton(
                        onPressed: isLoading ? null : _resend,
                        child: const Text('Resend code'),
                      ),
              ),
              const Spacer(),
              if (isLoading) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
