import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

/// Six big bold digits with no boxes: pale `0` placeholders that fill in as
/// the code is typed, per the redesign's OTP screen.
class OtpField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String> onCompleted;
  final bool enabled;

  const OtpField({
    super.key,
    required this.onCompleted,
    this.controller,
    this.onChanged,
    this.enabled = true,
  });

  static const _ink = Color(0xFF111827);
  static const _placeholder = Color(0xFFA5A6B9);
  static const _digitStyle = TextStyle(
    fontSize: 44,
    fontWeight: FontWeight.w800,
    color: _ink,
  );

  @override
  Widget build(BuildContext context) {
    const theme = PinTheme(width: 36, height: 60, textStyle: _digitStyle);

    return Pinput(
      controller: controller,
      enabled: enabled,
      length: 6,
      autofocus: true,
      defaultPinTheme: theme,
      separatorBuilder: (_) => const SizedBox(width: 6),
      preFilledWidget: Text(
        '0',
        style: _digitStyle.copyWith(color: _placeholder),
      ),
      showCursor: true,
      cursor: Container(width: 2, height: 36, color: _ink),
      onChanged: onChanged,
      onCompleted: onCompleted,
    );
  }
}
