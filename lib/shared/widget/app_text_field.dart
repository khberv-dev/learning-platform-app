import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/l10n/app_localizations.dart';

/// Labelled form input — a grey caption above a borderless, pale-grey
/// rounded field. Sits on a white background.
///
/// Deliberately overrides the app-wide `inputDecorationTheme`, which draws a
/// 2px outline; this form style has no visible border.
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

  /// Fixed text before the input, e.g. a dialling code. Always shown (unlike
  /// Material's `prefixText`), followed by a thin divider.
  final String? prefixText;

  final bool enabled;

  /// Shown but not editable, e.g. an already-verified phone number.
  final bool readOnly;

  /// Off for emails and similar, where the keyboard's corrections get in
  /// the way.
  final bool autocorrect;

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
    this.readOnly = false,
    this.autocorrect = true,
    this.onSubmitted,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

const _fill = Color(0xFFF2F4F9);
const _text = Color(0xFF15141A);
const _label = Color(0xFF717384);
const _hint = Color(0xFF989DB5);
const _divider = Color(0xFFE5E7EA);

const _inputStyle = TextStyle(
  color: _text,
  fontSize: 16,
  fontWeight: FontWeight.w600,
);

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide.none,
    );
    final prefix = widget.prefixText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: _label,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          textCapitalization: widget.textCapitalization,
          autocorrect: widget.autocorrect,
          enableSuggestions: widget.autocorrect,
          onFieldSubmitted: widget.onSubmitted,
          style: _inputStyle,
          cursorColor: _text,
          decoration: InputDecoration(
            filled: true,
            fillColor: _fill,
            hintText: widget.hintText,
            hintStyle: _inputStyle.copyWith(
              color: _hint,
              fontWeight: FontWeight.w500,
            ),
            // 16 in from the edge, or 12 past the prefix's divider.
            contentPadding: EdgeInsets.fromLTRB(
              prefix == null ? AppSpacing.lg : AppSpacing.md,
              14,
              AppSpacing.lg,
              14,
            ),
            prefixIcon: prefix == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.lg),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(prefix, style: _inputStyle),
                        const SizedBox(width: AppSpacing.md),
                        Container(width: 1, height: 20, color: _divider),
                      ],
                    ),
                  ),
            prefixIconConstraints: const BoxConstraints(),
            border: border,
            enabledBorder: border,
            focusedBorder: border,
            disabledBorder: border,
            errorBorder: border,
            focusedErrorBorder: border,
            suffixIcon: widget.obscureText
                ? Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: IconButton(
                      onPressed: () => setState(() => _obscured = !_obscured),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent,
                      ),
                      tooltip: _obscured
                          ? AppLocalizations.of(context).commonShowPassword
                          : AppLocalizations.of(context).commonHidePassword,
                      icon: Icon(
                        _obscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: _label,
                        size: 22,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
