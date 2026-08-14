import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/auth/presentation/register_controller.dart';
import 'package:student/core/startup/presentation/skill_quiz_result_controller.dart';
import 'package:student/shared/widget/app_bottom_action_bar.dart';
import 'package:student/shared/widget/app_button.dart';
import 'package:student/shared/widget/app_gradient_background.dart';
import 'package:student/shared/widget/app_text_field.dart';
import 'package:student/ui/auth/login_screen.dart';
import 'package:student/ui/auth/otp_screen.dart';
import 'package:student/utils/messenger.dart';
import 'package:student/utils/uz_phone_formatter.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  static const path = '/register';

  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _otpSent = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(registerControllerProvider, (prev, next) {
      if (prev?.isLoading != true) return;
      next.whenOrNull(
        data: (_) {
          if (!_otpSent) {
            _otpSent = true;
            final digits = _phoneController.text.replaceAll(' ', '');
            context.push('${OtpScreen.path}?phone=998$digits&mode=register');
          }
        },
        error: (e, _) => showErrorMessage(context, apiErrorMessage(e)),
      );
    });

    final isLoading = ref.watch(registerControllerProvider).isLoading;

    return Scaffold(
      body: AppGradientBackground(
        child: Column(
          children: [
            Expanded(
              child: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.xl,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.xxl),
                        const Text(
                          'Create account',
                          style: TextStyle(
                            color: AppColors.deepGreen,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        AppTextField(
                          label: 'Full name',
                          controller: _fullNameController,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Enter your full name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: 'Phone number',
                          controller: _phoneController,
                          prefixText: '+998 ',
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
                        AppTextField(
                          label: 'Password',
                          controller: _passwordController,
                          obscureText: true,
                          validator: (value) {
                            if ((value ?? '').length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const _LegalNotice(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AppBottomActionBar(
              children: [
                AppButton.filled(
                  label: 'Create account',
                  isLoading: isLoading,
                  onTap: _submit,
                ),
                AppButton.outlined(
                  label: 'Log in',
                  onTap: () => context.go(LoginScreen.path),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _otpSent = false;
    final digits = _phoneController.text.replaceAll(' ', '');
    ref
        .read(registerControllerProvider.notifier)
        .prepareAndSendOtp(
          firstName: _fullNameController.text.trim(),
          phoneNumber: '998$digits',
          password: _passwordController.text,
          // Null when the placement quiz was skipped or closed early, which
          // leaves the API to apply its own default level.
          level: ref.read(skillQuizResultProvider),
        );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _LegalNotice extends StatelessWidget {
  const _LegalNotice();

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(
      color: AppColors.ink,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1.4,
    );
    const emphasis = TextStyle(fontWeight: FontWeight.w800);

    return const SizedBox(
      width: double.infinity,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: 'By creating an account you agree to our\n'),
            TextSpan(text: 'Terms of Use', style: emphasis),
            TextSpan(text: ' and '),
            TextSpan(text: 'Privacy Policy', style: emphasis),
          ],
        ),
        textAlign: TextAlign.center,
        style: base,
      ),
    );
  }
}
