import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/auth/presentation/register_controller.dart';
import 'package:student/core/startup/presentation/skill_quiz_result_controller.dart';
import 'package:student/core/user/domain/entity/gender.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_flat_pill_button.dart';
import 'package:student/shared/widget/app_text_field.dart';
import 'package:student/ui/auth/login_screen.dart';
import 'package:student/ui/auth/widget/auth_back_button.dart';
import 'package:student/ui/main/app_screen.dart';
import 'package:student/utils/lib.dart';
import 'package:student/utils/messenger.dart';

/// Picks an image from the gallery and returns its local path, or null when
/// the student backs out. Swappable for tests, where image_picker's platform
/// channel doesn't exist.
typedef AvatarPicker = Future<String?> Function();

final avatarPickerProvider = Provider<AvatarPicker>(
  (ref) => () async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    return picked?.path;
  },
);

/// The last registration step. The phone/email was already verified by code
/// (login → `OtpScreen`), so it's only shown here, not edited.
class RegisterScreen extends ConsumerStatefulWidget {
  static const path = '/register';

  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  late final _identityController = TextEditingController(text: _identityText());
  String? _avatarPath;
  Gender? _gender;

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_rebuild);
    _passwordController.addListener(_rebuild);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _identityController.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  String _identityText() {
    final register = ref.read(registerControllerProvider.notifier);
    return register.email ??
        (register.phoneNumber == null ? '' : formatPhone(register.phoneNumber));
  }

  bool get _canSubmit =>
      _firstNameController.text.trim().isNotEmpty &&
      _passwordController.text.length >= 8 &&
      _gender != null;

  Future<void> _pickAvatar() async {
    final path = await ref.read(avatarPickerProvider)();
    if (path != null && mounted) setState(() => _avatarPath = path);
  }

  Future<void> _submit() async {
    final lastName = _lastNameController.text.trim();
    final registered = await ref
        .read(registerControllerProvider.notifier)
        .complete(
          firstName: _firstNameController.text.trim(),
          lastName: lastName.isEmpty ? null : lastName,
          password: _passwordController.text,
          // Null when the placement quiz was skipped or closed early, which
          // leaves the API to apply its own default level.
          level: ref.read(skillQuizResultProvider),
          gender: _gender!,
          avatarPath: _avatarPath,
        );
    if (!mounted) return;
    if (registered) {
      context.go(AppScreen.path);
    } else {
      showErrorMessage(
        context,
        apiErrorMessage(context, ref.read(registerControllerProvider).error!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLoading = ref.watch(registerControllerProvider).isLoading;
    final isEmail = ref.read(registerControllerProvider.notifier).email != null;

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                0,
              ),
              child: SizedBox(
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      // The OTP screen replaced itself with this one, so
                      // back lands on login.
                      child: AuthBackButton(
                        onTap: () => context.canPop()
                            ? context.pop()
                            : context.go(LoginScreen.path),
                      ),
                    ),
                    Text(
                      l10n.registerPersonalInfo,
                      style: const TextStyle(
                        color: _title,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xl,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: _AvatarPicker(
                        path: _avatarPath,
                        onTap: isLoading ? null : _pickAvatar,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: GestureDetector(
                        onTap: isLoading ? null : _pickAvatar,
                        child: Text(
                          l10n.registerChangePhoto,
                          style: const TextStyle(
                            color: Color(0xFF53ADF0),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppTextField(
                      key: const ValueKey('register-first-name'),
                      label: l10n.registerFirstName,
                      controller: _firstNameController,
                      hintText: l10n.registerFirstNameHint,
                      textCapitalization: TextCapitalization.words,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: _fieldGap),
                    AppTextField(
                      key: const ValueKey('register-last-name'),
                      label: l10n.registerLastName,
                      controller: _lastNameController,
                      hintText: l10n.registerLastNameHint,
                      textCapitalization: TextCapitalization.words,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: _fieldGap),
                    AppTextField(
                      key: const ValueKey('register-identity'),
                      label: isEmail ? l10n.fieldEmail : l10n.fieldPhone,
                      controller: _identityController,
                      hintText: isEmail ? 'example@mail.com' : '+998',
                      readOnly: true,
                    ),
                    const SizedBox(height: _fieldGap),
                    AppTextField(
                      key: const ValueKey('register-password'),
                      label: l10n.fieldPassword,
                      controller: _passwordController,
                      hintText: l10n.registerPasswordHint,
                      obscureText: true,
                      enabled: !isLoading,
                    ),
                    _Labelled(
                      label: l10n.registerGender,
                      child: Column(
                        children: [
                          _GenderOption(
                            label: l10n.genderMale,
                            accent: const Color(0xFF53ADF0),
                            selected: _gender == Gender.male,
                            onTap: () => setState(() => _gender = Gender.male),
                          ),
                          const SizedBox(height: AppSpacing.sm + 4),
                          _GenderOption(
                            label: l10n.genderFemale,
                            accent: const Color(0xFFC385F8),
                            selected: _gender == Gender.female,
                            onTap: () =>
                                setState(() => _gender = Gender.female),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: AppFlatPillButton(
                label: l10n.registerSubmit,
                background: const Color(0xFF78C93C),
                foreground: Colors.white,
                onTap: _canSubmit && !isLoading ? _submit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _background = Colors.white;
const _title = Color(0xFF15141A);
const _label = Color(0xFF717384);
const _fill = Color(0xFFF2F4F9);

/// Label-to-label spacing between stacked fields, per the mockup.
const _fieldGap = 20.0;

/// A round photo slot: the picked image, or a grey person placeholder.
class _AvatarPicker extends StatelessWidget {
  final String? path;
  final VoidCallback? onTap;

  const _AvatarPicker({required this.path, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipOval(
          child: path == null
              ? const ColoredBox(
                  color: Color(0xFFF5F5F5),
                  child: Center(
                    child: Icon(
                      Icons.person_outline_rounded,
                      size: 48,
                      color: Color(0xFFA4A7AD),
                    ),
                  ),
                )
              : Image.file(File(path!), fit: BoxFit.cover),
        ),
      ),
    );
  }
}

/// A grey caption above a non-text control, styled like [AppTextField]'s.
class _Labelled extends StatelessWidget {
  final String label;
  final Widget child;

  const _Labelled({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: _fieldGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _label,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

/// A pale-grey pill row: a round badge, the label, and a radio on the right —
/// green with a check once chosen.
class _GenderOption extends StatelessWidget {
  final String label;

  /// The badge's colour once chosen; grey until then.
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: _fill,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: selected ? accent : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    size: 24,
                    color: selected ? Colors.white : const Color(0xFF9D9EAA),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: _title,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF66D46F) : null,
                    shape: BoxShape.circle,
                    border: selected
                        ? null
                        : Border.all(
                            color: const Color(0xFFD5D7DA),
                            width: 1.5,
                          ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Color(0xFF395363),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
