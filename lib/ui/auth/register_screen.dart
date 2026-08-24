import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/auth/presentation/register_controller.dart';
import 'package:student/core/startup/presentation/skill_quiz_result_controller.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_bottom_action_bar.dart';
import 'package:student/shared/widget/app_button.dart';
import 'package:student/shared/widget/app_gradient_background.dart';
import 'package:student/shared/widget/app_text_field.dart';
import 'package:student/shared/widget/auth_identity_switch.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _otpSent = false;
  AuthIdentityType _identityType = AuthIdentityType.phone;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(registerControllerProvider, (prev, next) {
      if (prev?.isLoading != true) return;
      next.whenOrNull(
        data: (_) {
          if (!_otpSent) {
            _otpSent = true;
            final query = _identityType == AuthIdentityType.phone
                ? {
                    'phone': '998${_phoneController.text.replaceAll(' ', '')}',
                    'mode': 'register',
                  }
                : {
                    'email': _emailController.text.trim().toLowerCase(),
                    'mode': 'register',
                  };
            context.push(
              Uri(path: OtpScreen.path, queryParameters: query).toString(),
            );
          }
        },
        error: (e, _) => showErrorMessage(context, apiErrorMessage(context, e)),
      );
    });

    final isLoading = ref.watch(registerControllerProvider).isLoading;
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
                        Text(
                          l10n.registerTitle,
                          style: const TextStyle(
                            color: AppColors.deepGreen,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        AppTextField(
                          label: l10n.fieldFullName,
                          controller: _fullNameController,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return l10n.validationFullName;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AuthIdentitySwitch(
                          value: _identityType,
                          phoneLabel: l10n.authUsePhone,
                          emailLabel: l10n.authUseEmail,
                          onChanged: (value) => setState(() {
                            _identityType = value;
                            _formKey.currentState?.reset();
                          }),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        if (_identityType == AuthIdentityType.phone)
                          AppTextField(
                            key: const ValueKey('register-phone'),
                            label: l10n.fieldPhone,
                            controller: _phoneController,
                            prefixText: '+998 ',
                            keyboardType: TextInputType.number,
                            inputFormatters: [UzPhoneFormatter()],
                            validator: (value) {
                              final digits = (value ?? '').replaceAll(' ', '');
                              return digits.length == 9
                                  ? null
                                  : l10n.validationPhone;
                            },
                          )
                        else
                          AppTextField(
                            key: const ValueKey('register-email'),
                            label: l10n.fieldEmail,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => _isValidEmail(value ?? '')
                                ? null
                                : l10n.validationEmail,
                          ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: l10n.fieldPassword,
                          controller: _passwordController,
                          obscureText: true,
                          validator: (value) {
                            if ((value ?? '').length < 8) {
                              return l10n.validationPassword;
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
                  label: l10n.registerSubmit,
                  isLoading: isLoading,
                  onTap: _submit,
                ),
                AppButton.outlined(
                  label: l10n.loginSubmit,
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
    if (_identityType == AuthIdentityType.email) {
      ref
          .read(registerControllerProvider.notifier)
          .prepareEmailAndSendOtp(
            firstName: _fullNameController.text.trim(),
            email: _emailController.text.trim().toLowerCase(),
            password: _passwordController.text,
            level: ref.read(skillQuizResultProvider),
          );
      return;
    }
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

bool _isValidEmail(String value) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim());

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

    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: double.infinity,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: l10n.registerLegalLead),
            TextSpan(text: l10n.registerLegalTerms, style: emphasis),
            TextSpan(text: l10n.registerLegalAnd),
            TextSpan(text: l10n.registerLegalPrivacy, style: emphasis),
          ],
        ),
        textAlign: TextAlign.center,
        style: base,
      ),
    );
  }
}
