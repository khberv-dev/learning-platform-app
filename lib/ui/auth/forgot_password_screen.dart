import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/auth/presentation/recover_password_controller.dart';
import 'package:student/ui/auth/otp_screen.dart';
import 'package:student/utils/messenger.dart';
import 'package:student/utils/uz_phone_formatter.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  static const path = '/forgot-password';

  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _otpSent = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(recoverPasswordControllerProvider, (
      prev,
      next,
    ) {
      if (prev?.isLoading != true) return;
      next.whenOrNull(
        data: (_) {
          if (!_otpSent) {
            _otpSent = true;
            final digits = _phoneController.text.replaceAll(' ', '');
            context.push('${OtpScreen.path}?phone=998$digits&mode=recover');
          }
        },
        error: (e, _) => showErrorMessage(
          context,
          RecoverPasswordController.errorMessage(e),
        ),
      );
    });

    final isLoading = ref.watch(recoverPasswordControllerProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
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
                    'Reset Password',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Enter your phone number and a new password',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                      prefixText: '+998 ',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [UzPhoneFormatter()],
                    validator: (value) {
                      final digits = (value ?? '').replaceAll(' ', '');
                      if (digits.length != 9) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New password',
                    ),
                    validator: (value) {
                      if ((value ?? '').length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm password',
                    ),
                    validator: (value) {
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Send Code'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _otpSent = false;
    final digits = _phoneController.text.replaceAll(' ', '');
    ref
        .read(recoverPasswordControllerProvider.notifier)
        .prepareAndSendOtp(
          phoneNumber: '998$digits',
          newPassword: _newPasswordController.text,
        );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
