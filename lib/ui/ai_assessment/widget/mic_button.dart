import 'package:flutter/material.dart';

class MicButton extends StatelessWidget {
  final bool active;
  final bool busy;
  final VoidCallback onTap;

  const MicButton({
    super.key,
    required this.active,
    required this.onTap,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Container(
        width: 104,
        height: 104,
        decoration: BoxDecoration(
          color: const Color(0xFF18C96A).withValues(alpha: 0.10),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: Color(0xFF18C96A),
            shape: BoxShape.circle,
          ),
          child: busy
              ? const Center(
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : Icon(
                  active ? Icons.stop_rounded : Icons.mic_none_rounded,
                  color: Colors.white,
                  size: 30,
                ),
        ),
      ),
    );
  }
}
