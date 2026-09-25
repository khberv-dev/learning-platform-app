import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/auth/presentation/register_controller.dart';
import 'package:student/core/startup/presentation/skill_quiz_result_controller.dart';
import 'package:student/core/user/domain/entity/gender.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_bottom_action_bar.dart';
import 'package:student/shared/widget/app_button.dart';
import 'package:student/shared/widget/app_gradient_background.dart';
import 'package:student/shared/widget/app_text_field.dart';
import 'package:student/shared/url_launcher.dart';
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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _otpSent = false;
  AuthIdentityType _identityType = AuthIdentityType.phone;
  Gender? _gender;

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
                          label: l10n.fieldFirstName,
                          controller: _firstNameController,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return l10n.validationFirstName;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: l10n.fieldLastName,
                          controller: _lastNameController,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _GenderSwitch(
                          value: _gender,
                          label: l10n.fieldGender,
                          maleLabel: l10n.genderMale,
                          femaleLabel: l10n.genderFemale,
                          onChanged: (value) => setState(() => _gender = value),
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
    final lastName = _lastNameController.text.trim();
    if (_identityType == AuthIdentityType.email) {
      ref
          .read(registerControllerProvider.notifier)
          .prepareEmailAndSendOtp(
            firstName: _firstNameController.text.trim(),
            lastName: lastName.isEmpty ? null : lastName,
            email: _emailController.text.trim().toLowerCase(),
            password: _passwordController.text,
            level: ref.read(skillQuizResultProvider),
            gender: _gender,
          );
      return;
    }
    final digits = _phoneController.text.replaceAll(' ', '');
    ref
        .read(registerControllerProvider.notifier)
        .prepareAndSendOtp(
          firstName: _firstNameController.text.trim(),
          lastName: lastName.isEmpty ? null : lastName,
          phoneNumber: '998$digits',
          password: _passwordController.text,
          // Null when the placement quiz was skipped or closed early, which
          // leaves the API to apply its own default level.
          level: ref.read(skillQuizResultProvider),
          gender: _gender,
        );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

bool _isValidEmail(String value) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim());

/// Optional — tapping the already-selected segment clears it, since the API
/// is happy to apply its own default when nothing is sent.
class _GenderSwitch extends StatelessWidget {
  final Gender? value;
  final String label;
  final String maleLabel;
  final String femaleLabel;
  final ValueChanged<Gender?> onChanged;

  const _GenderSwitch({
    required this.value,
    required this.label,
    required this.maleLabel,
    required this.femaleLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<Gender>(
            segments: [
              ButtonSegment(value: Gender.male, label: Text(maleLabel)),
              ButtonSegment(value: Gender.female, label: Text(femaleLabel)),
            ],
            selected: value == null ? const {} : {value!},
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            onSelectionChanged: (selection) =>
                onChanged(selection.isEmpty ? null : selection.first),
          ),
        ),
      ],
    );
  }
}

const publicOfferUrl = 'https://i-teach.uz/docs/public_agreement.html';
const privacyPolicyUrl = 'https://i-teach.uz/docs/privacy-policy.html';

class _LegalNotice extends ConsumerStatefulWidget {
  const _LegalNotice();

  @override
  ConsumerState<_LegalNotice> createState() => _LegalNoticeState();
}

class _LegalNoticeState extends ConsumerState<_LegalNotice> {
  late final _offerTap = TapGestureRecognizer()
    ..onTap = () => _open(publicOfferUrl);
  late final _privacyTap = TapGestureRecognizer()
    ..onTap = () => _open(privacyPolicyUrl);

  Future<void> _open(String url) async {
    final opened = await ref.read(inAppBrowserLauncherProvider)(Uri.parse(url));
    if (!opened && mounted) {
      showErrorMessage(
        context,
        AppLocalizations.of(context).registerLegalOpenFailed,
      );
    }
  }

  @override
  void dispose() {
    _offerTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(
      color: AppColors.ink,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1.4,
    );
    const link = TextStyle(
      fontWeight: FontWeight.w800,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.ink,
    );

    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: double.infinity,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: l10n.registerLegalLead),
            TextSpan(
              text: l10n.registerLegalOffer,
              style: link,
              recognizer: _offerTap,
            ),
            TextSpan(text: l10n.registerLegalAnd),
            TextSpan(
              text: l10n.registerLegalPrivacy,
              style: link,
              recognizer: _privacyTap,
            ),
            TextSpan(text: l10n.registerLegalTail),
          ],
        ),
        textAlign: TextAlign.center,
        style: base,
      ),
    );
  }
}
