import 'package:flutter/material.dart';

class CallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color iconColor;
  final Color labelColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const CallActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.background,
    required this.iconColor,
    required this.labelColor,
    required this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
              border: borderColor == null
                  ? null
                  : Border.all(color: borderColor!, width: 1.5),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: TextStyle(color: labelColor, fontSize: 12)),
      ],
    );
  }
}
