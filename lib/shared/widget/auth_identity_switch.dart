import 'package:flutter/material.dart';

enum AuthIdentityType { phone, email }

class AuthIdentitySwitch extends StatelessWidget {
  final AuthIdentityType value;
  final ValueChanged<AuthIdentityType> onChanged;
  final String phoneLabel;
  final String emailLabel;

  const AuthIdentitySwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.phoneLabel,
    required this.emailLabel,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: SegmentedButton<AuthIdentityType>(
      segments: [
        ButtonSegment(
          value: AuthIdentityType.phone,
          label: Text(phoneLabel),
          icon: const Icon(Icons.phone_outlined),
        ),
        ButtonSegment(
          value: AuthIdentityType.email,
          label: Text(emailLabel),
          icon: const Icon(Icons.email_outlined),
        ),
      ],
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
      showSelectedIcon: false,
    ),
  );
}
