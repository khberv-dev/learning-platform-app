import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/auth/presentation/login_controller.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_bottom_action_bar.dart';
import 'package:student/shared/widget/app_button.dart';
import 'package:student/shared/widget/app_gradient_background.dart';
import 'package:student/shared/widget/app_text_field.dart';
import 'package:student/shared/widget/auth_identity_switch.dart';
import 'package:student/ui/auth/forgot_password_screen.dart';
import 'package:student/ui/main/app_screen.dart';
import 'package:student/ui/startup/survey_screen.dart';
import 'package:student/utils/messenger.dart';
import 'package:student/utils/uz_phone_formatter.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const path = '/login';

  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AuthIdentityType _identityType = AuthIdentityType.phone;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(loginControllerProvider, (prev, next) {
      if (prev?.isLoading != true) return;
      next.whenOrNull(
        data: (_) => context.go(AppScreen.path),
        error: (e, _) => showErrorMessage(context, apiErrorMessage(context, e)),
      );
    });

    final isLoading = ref.watch(loginControllerProvider).isLoading;
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
                          l10n.loginTitle,
                          style: const TextStyle(
                            color: AppColors.deepGreen,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
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
                            key: const ValueKey('login-phone'),
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
                            key: const ValueKey('login-email'),
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
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                context.push(ForgotPasswordScreen.path),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.ink,
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: Text(l10n.loginForgotPassword),
                          ),
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
                  label: l10n.loginSubmit,
                  isLoading: isLoading,
                  onTap: _submit,
                ),
                AppButton.outlined(
                  label: l10n.registerTitle,
                  // Registration starts with the survey, not the form.
                  onTap: () => context.go(SurveyScreen.path),
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
    if (_identityType == AuthIdentityType.email) {
      ref
          .read(loginControllerProvider.notifier)
          .signInWithEmail(
            email: _emailController.text.trim().toLowerCase(),
            password: _passwordController.text,
          );
      return;
    }
    final digits = _phoneController.text.replaceAll(' ', '');
    ref
        .read(loginControllerProvider.notifier)
        .signIn(phoneNumber: '998$digits', password: _passwordController.text);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

bool _isValidEmail(String value) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim());
