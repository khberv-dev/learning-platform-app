import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';

// ── Static CEFR data ──────────────────────────────────────────────────────────

class _CefrData {
  final String code;
  final String name;
  final String subtitle;
  final List<String> topics;
  final Color color;

  const _CefrData({
    required this.code,
    required this.name,
    required this.subtitle,
    required this.topics,
    required this.color,
  });
}

const _cefrLevels = [
  _CefrData(
    code: 'A1',
    name: 'Beginner',
    subtitle: 'Basic survival phrases & expressions',
    topics: [
      'Greetings',
      'Numbers & Dates',
      'Colors & Objects',
      'Family',
      'Food & Drinks',
      'Daily Routines',
    ],
    color: Color(0xFFF59E0B),
  ),
  _CefrData(
    code: 'A2',
    name: 'Elementary',
    subtitle: 'Simple everyday tasks & exchanges',
    topics: [
      'Shopping',
      'Travel & Transport',
      'Weather & Seasons',
      'Home & Furniture',
      'Hobbies & Interests',
      'Health & Body',
    ],
    color: Color(0xFFF97316),
  ),
  _CefrData(
    code: 'B1',
    name: 'Intermediate',
    subtitle: 'Handle most travel & social situations',
    topics: [
      'Work & Careers',
      'Current Events',
      'Future Plans',
      'Past Experiences',
      'Opinions & Feelings',
      'Tourism & Culture',
    ],
    color: Color(0xFF18C96A),
  ),
  _CefrData(
    code: 'B2',
    name: 'Upper-Intermediate',
    subtitle: 'Fluent interaction with native speakers',
    topics: [
      'Debates & Arguments',
      'Social Issues',
      'Business English',
      'Media & Entertainment',
      'Environment',
      'Academic Writing',
    ],
    color: Color(0xFF0EA5E9),
  ),
  _CefrData(
    code: 'C1',
    name: 'Advanced',
    subtitle: 'Flexible & effective professional use',
    topics: [
      'Academic Discourse',
      'Professional Comms',
      'Idioms & Phrases',
      'Literature & Arts',
      'Critical Analysis',
      'Complex Negotiations',
    ],
    color: Color(0xFF6366F1),
  ),
  _CefrData(
    code: 'C2',
    name: 'Proficiency',
    subtitle: 'Near-native mastery of the language',
    topics: [
      'Native-like Fluency',
      'Specialized Vocabulary',
      'Cultural References',
      'Advanced Rhetoric',
      'Creative Writing',
      'Expert Presentations',
    ],
    color: Color(0xFFA855F7),
  ),
];

// ── Status enum ───────────────────────────────────────────────────────────────

enum _Status { completed, current, locked }

// ── Screen ────────────────────────────────────────────────────────────────────

class RoadmapScreen extends ConsumerWidget {
  static const path = '/roadmap';

  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLevel = ref.watch(currentUserProvider)?.level ?? 'A1';
    final currentIdx = _cefrLevels.indexWhere((l) => l.code == currentLevel);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: const Color(0xFF111827),
        ),
        title: const Text(
          'Learning Roadmap',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        itemCount: _cefrLevels.length,
        itemBuilder: (context, i) {
          final level = _cefrLevels[i];
          final status = i < currentIdx
              ? _Status.completed
              : i == currentIdx
              ? _Status.current
              : _Status.locked;
          return _LevelTile(
            level: level,
            status: status,
            isLast: i == _cefrLevels.length - 1,
          );
        },
      ),
    );
  }
}

// ── Tile ─────────────────────────────────────────────────────────────────────

class _LevelTile extends StatelessWidget {
  final _CefrData level;
  final _Status status;
  final bool isLast;

  const _LevelTile({
    required this.level,
    required this.status,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Timeline column ──
          SizedBox(
            width: 52,
            child: Column(
              children: [
                _NodeCircle(level: level, status: status),
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 2,
                        color: status == _Status.completed
                            ? const Color(0xFF18C96A)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // ── Content card ──
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: _LevelCard(level: level, status: status),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Node circle ───────────────────────────────────────────────────────────────

class _NodeCircle extends StatelessWidget {
  final _CefrData level;
  final _Status status;

  const _NodeCircle({required this.level, required this.status});

  Color get _bg {
    return switch (status) {
      _Status.completed => const Color(0xFF18C96A),
      _Status.current => level.color,
      _Status.locked => const Color(0xFFF3F4F6),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = status == _Status.locked;
    final isCurrent = status == _Status.current;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _bg,
        border: Border.all(
          color: isLocked ? const Color(0xFFE5E7EB) : _bg,
          width: 2,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: level.color.withValues(alpha: 0.35),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: status == _Status.completed
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
            : Text(
                level.code,
                style: TextStyle(
                  color: isLocked ? const Color(0xFF9CA3AF) : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

// ── Content card ──────────────────────────────────────────────────────────────

class _LevelCard extends StatelessWidget {
  final _CefrData level;
  final _Status status;

  const _LevelCard({required this.level, required this.status});

  @override
  Widget build(BuildContext context) {
    final isCurrent = status == _Status.current;
    final isLocked = status == _Status.locked;

    final chipBg = isLocked
        ? const Color(0xFFF3F4F6)
        : isCurrent
        ? level.color.withValues(alpha: 0.1)
        : const Color(0xFFECFDF5);

    final chipText = isLocked
        ? const Color(0xFFD1D5DB)
        : isCurrent
        ? level.color
        : const Color(0xFF15803D);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrent ? level.color.withValues(alpha: 0.07) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCurrent
            ? Border.all(color: level.color.withValues(alpha: 0.35), width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  level.name,
                  style: TextStyle(
                    color: isLocked
                        ? const Color(0xFFD1D5DB)
                        : const Color(0xFF111827),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: level.color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Current',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else if (isLocked)
                const Icon(
                  Icons.lock_rounded,
                  size: 14,
                  color: Color(0xFFD1D5DB),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            level.subtitle,
            style: TextStyle(
              color: isLocked
                  ? const Color(0xFFE5E7EB)
                  : const Color(0xFF6B7280),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: level.topics
                .map(
                  (t) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                        color: chipText,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
