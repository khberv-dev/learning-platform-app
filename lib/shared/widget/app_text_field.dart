import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';

/// Labelled pill input — a caption above a borderless white field.
///
/// Deliberately overrides the app-wide `inputDecorationTheme`, which draws a
/// 2px outline at [AppRadius.lg]; this form style has no visible border.
///
/// Pass [obscureText] to get a password field with a built-in show/hide
/// toggle — the caller doesn't manage that state.
class AppTextField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? hintText;

  /// Starts obscured and shows a visibility toggle.
  final bool obscureText;

  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;

  /// Fixed text before the input, e.g. a dialling code.
  final String? prefixText;

  final bool enabled;
  final ValueChanged<String>? onSubmitted;

  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
    this.prefixText,
    this.enabled = true,
    this.onSubmitted,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    const inputStyle = TextStyle(
      color: AppColors.ink,
      fontSize: 17,
      fontWeight: FontWeight.w700,
    );

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.round),
      borderSide: BorderSide.none,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          textCapitalization: widget.textCapitalization,
          onFieldSubmitted: widget.onSubmitted,
          style: inputStyle,
          cursorColor: AppColors.ink,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            hintText: widget.hintText,
            hintStyle: inputStyle.copyWith(color: AppColors.ink.withAlpha(90)),
            prefixText: widget.prefixText,
            prefixStyle: inputStyle,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: 15,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: border,
            disabledBorder: border,
            errorBorder: border,
            focusedErrorBorder: border,
            suffixIcon: widget.obscureText
                ? IconButton(
                    onPressed: () => setState(() => _obscured = !_obscured),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.transparent,
                    ),
                    tooltip: _obscured ? 'Show password' : 'Hide password',
                    icon: Icon(
                      _obscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.ink,
                      size: 22,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
