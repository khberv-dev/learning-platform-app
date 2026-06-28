import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student/ui/roadmap/roadmap_screen.dart';

class SkillCard extends StatelessWidget {
  final String level;

  const SkillCard({super.key, required this.level});

  static const _levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  double get _progress {
    final idx = _levels.indexOf(level);
    if (idx <= 0) return 0;
    if (idx >= _levels.length - 1) return 1.0;
    return idx / (_levels.length - 1);
  }

  String get _nextLevel {
    final idx = _levels.indexOf(level);
    if (idx < 0 || idx >= _levels.length - 1) return level;
    return _levels[idx + 1];
  }

  @override
  Widget build(BuildContext context) {
    final isMaxLevel = level == 'C2';

    return GestureDetector(
      onTap: () => context.push(RoadmapScreen.path),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.school_rounded,
                  size: 16,
                  color: Color(0xFF18C96A),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Your Level',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Text(
                  'View Roadmap',
                  style: TextStyle(
                    color: Color(0xFF18C96A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: Color(0xFF18C96A),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _LevelBadge(label: level, bgColor: const Color(0xFF18C96A)),
                const SizedBox(width: 8),
                if (!isMaxLevel) ...[
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: const Color(0xFFE5E7EB),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF18C96A),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _LevelBadge(
                    label: _nextLevel,
                    bgColor: const Color(0xFFF3F4F6),
                    textColor: const Color(0xFF9CA3AF),
                  ),
                ] else
                  const Expanded(
                    child: Text(
                      'Maximum Level 🎉',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const _LevelBadge({
    required this.label,
    required this.bgColor,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
