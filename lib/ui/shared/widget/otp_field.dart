import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:student/app/theme/app_radius.dart';

class OtpField extends StatelessWidget {
  final Function(String) onCompleted;
  final bool enabled;

  const OtpField({super.key, required this.onCompleted, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 72,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(100),
          width: 3,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Theme.of(context).colorScheme.primary.withAlpha(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 3,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 3,
        ),
      ),
    );

    return Pinput(
      enabled: enabled,
      length: 6,
      autofocus: true,
      defaultPinTheme: defaultPinTheme,
      submittedPinTheme: submittedPinTheme,
      focusedPinTheme: focusedPinTheme,
      onCompleted: onCompleted,
    );
  }
}
