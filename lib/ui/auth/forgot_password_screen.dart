import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/auth/presentation/recover_password_controller.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_bottom_action_bar.dart';
import 'package:student/shared/widget/app_button.dart';
import 'package:student/shared/widget/app_gradient_background.dart';
import 'package:student/shared/widget/app_text_field.dart';
import 'package:student/shared/widget/back_icon_button.dart';
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
        error: (e, _) => showErrorMessage(context, apiErrorMessage(context, e)),
      );
    });

    final isLoading = ref.watch(recoverPasswordControllerProvider).isLoading;
    final l10n = AppLocalizations.of(context);

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
                    AppSpacing.md,
                    AppSpacing.xl,
                    AppSpacing.xl,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const BackIconButton(),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          l10n.forgotTitle,
                          style: const TextStyle(
                            color: AppColors.deepGreen,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.forgotSubtitle,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AppTextField(
                          label: l10n.fieldPhone,
                          controller: _phoneController,
                          prefixText: '+998 ',
                          keyboardType: TextInputType.number,
                          inputFormatters: [UzPhoneFormatter()],
                          validator: (value) {
                            final digits = (value ?? '').replaceAll(' ', '');
                            if (digits.length != 9) {
                              return l10n.validationPhone;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: l10n.fieldNewPassword,
                          controller: _newPasswordController,
                          obscureText: true,
                          validator: (value) {
                            if ((value ?? '').length < 8) {
                              return l10n.validationPassword;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: l10n.fieldConfirmPassword,
                          controller: _confirmPasswordController,
                          obscureText: true,
                          validator: (value) {
                            if (value != _newPasswordController.text) {
                              return l10n.validationPasswordsMatch;
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AppBottomActionBar(
              children: [
                AppButton.filled(
                  label: l10n.forgotSubmit,
                  isLoading: isLoading,
                  onTap: _submit,
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
