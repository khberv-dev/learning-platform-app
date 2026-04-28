import 'package:flutter/material.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/ui/shared/widget/section_title.dart';

class _Session {
  final String time;
  final String period;
  final String title;
  final String subtitle;

  const _Session({
    required this.time,
    required this.period,
    required this.title,
    required this.subtitle,
  });
}

class UpcomingSection extends StatelessWidget {
  const UpcomingSection({super.key});

  static const _sessions = [
    _Session(
      time: '3:00',
      period: 'PM',
      title: 'IELTS Speaking Practice',
      subtitle: 'David Chen · Advanced',
    ),
    _Session(
      time: '5:30',
      period: 'PM',
      title: 'Grammar for Beginners',
      subtitle: 'Emma Clark · Beginner',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Upcoming'),
          const SizedBox(height: 12),
          for (int i = 0; i < _sessions.length; i++) ...[
            _SessionItem(session: _sessions[i]),
            if (i < _sessions.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _SessionItem extends StatelessWidget {
  final _Session session;

  const _SessionItem({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.time,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  session.period,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  session.subtitle,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
