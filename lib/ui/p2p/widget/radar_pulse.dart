import 'package:flutter/material.dart';

/// Three concentric pulsing circles with an avatar in the center.
class RadarPulse extends StatefulWidget {
  final String initials;

  const RadarPulse({super.key, required this.initials});

  @override
  State<RadarPulse> createState() => _RadarPulseState();
}

class _RadarPulseState extends State<RadarPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      height: 320,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          _Ring(
            controller: _controller,
            phase: 0.0,
            baseSize: 120,
            growBy: 150,
            color: const Color(0x1A0EA5E9),
          ),
          _Ring(
            controller: _controller,
            phase: 0.33,
            baseSize: 120,
            growBy: 100,
            color: const Color(0x330EA5E9),
          ),
          _Ring(
            controller: _controller,
            phase: 0.66,
            baseSize: 120,
            growBy: 50,
            color: const Color(0x590EA5E9),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFF18C96A),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              widget.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  final AnimationController controller;
  final double phase;
  final double baseSize;
  final double growBy;
  final Color color;

  const _Ring({
    required this.controller,
    required this.phase,
    required this.baseSize,
    required this.growBy,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = (controller.value + phase) % 1.0;
        final size = baseSize + growBy * t;
        final opacity = (1.0 - t).clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        );
      },
    );
  }
}
