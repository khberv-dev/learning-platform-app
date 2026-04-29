import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/data/network/config.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/tutors/domain/entity/tutor_entity.dart';
import 'package:student/core/tutors/presentation/tutors_controller.dart';
import 'package:student/utils/lib.dart';

class TutorsPage extends ConsumerStatefulWidget {
  const TutorsPage({super.key});

  @override
  ConsumerState<TutorsPage> createState() => _TutorsPageState();
}

class _TutorsPageState extends ConsumerState<TutorsPage> {
  String _search = '';
  String? _selectedSubject; // null = All

  List<TutorEntity> _filter(List<TutorEntity> tutors) {
    return tutors.where((t) {
      final matchSubject = _selectedSubject == null ||
          t.subject.toLowerCase().contains(_selectedSubject!.toLowerCase());
      final matchSearch = _search.isEmpty ||
          t.name.toLowerCase().contains(_search.toLowerCase()) ||
          t.subject.toLowerCase().contains(_search.toLowerCase());
      return matchSubject && matchSearch;
    }).toList();
  }

  List<String> _subjects(List<TutorEntity> tutors) {
    final seen = <String>{};
    return tutors.map((t) => t.subject).where(seen.add).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tutorsControllerProvider);

    return Column(
      children: [
        _Header(
          search: _search,
          onSearch: (v) => setState(() => _search = v),
        ),
        state.when(
          loading: () => const Expanded(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Expanded(
            child: Center(
              child: Text(e.toString(),
                  style: const TextStyle(color: Color(0xFF6B7280))),
            ),
          ),
          data: (tutors) {
            final subjects = _subjects(tutors);
            final filtered = _filter(tutors);
            final featured = filtered.firstWhere(
              (t) => t.isFeatured,
              orElse: () => filtered.isNotEmpty ? filtered.first : tutors.first,
            );
            final rest = filtered.where((t) => t.id != featured.id).toList();

            return Expanded(
              child: Column(
                children: [
                  _ChipsRow(
                    subjects: subjects,
                    selected: _selectedSubject,
                    onSelect: (s) =>
                        setState(() => _selectedSubject = s),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Text('No tutors found.',
                                style:
                                    TextStyle(color: Color(0xFF6B7280))),
                          )
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(
                                AppSpacing.xl, 16, AppSpacing.xl, 96),
                            children: [
                              _FeaturedCard(tutor: featured),
                              const SizedBox(height: 16),
                              if (rest.isNotEmpty) ...[
                                const Text(
                                  'Available Tutors',
                                  style: TextStyle(
                                    color: Color(0xFF111827),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...rest.map((t) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16),
                                      child: _TutorCard(tutor: t),
                                    )),
                              ],
                            ],
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String search;
  final ValueChanged<String> onSearch;

  const _Header({required this.search, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find a Tutor',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF111827),
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: onSearch,
              style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
              decoration: const InputDecoration(
                hintText: 'Search by name or subject...',
                hintStyle:
                    TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                prefixIcon:
                    Icon(Icons.search, color: Color(0xFF9CA3AF), size: 18),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chips row ─────────────────────────────────────────────────────────────────

class _ChipsRow extends StatelessWidget {
  final List<String> subjects;
  final String? selected;
  final ValueChanged<String?> onSelect;

  const _ChipsRow({
    required this.subjects,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, 14),
        child: Row(
          children: [
            _Chip(
              label: 'All',
              isSelected: selected == null,
              onTap: () => onSelect(null),
            ),
            ...subjects.map((s) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _Chip(
                    label: s,
                    isSelected: selected == s,
                    onTap: () => onSelect(selected == s ? null : s),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Chip(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color:
              isSelected ? const Color(0xFF18C96A) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF374151),
            fontSize: 13,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ── Featured card ─────────────────────────────────────────────────────────────

class _FeaturedCard extends StatelessWidget {
  final TutorEntity tutor;

  const _FeaturedCard({required this.tutor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF18C96A), Color(0xFF059669)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, color: Colors.white, size: 13),
                      SizedBox(width: 5),
                      Text(
                        'Top Rated Tutor',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tutor.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tutor.subject,
                  style: const TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('★★★★★',
                        style:
                            TextStyle(color: Colors.white, fontSize: 13)),
                    const SizedBox(width: 6),
                    Text(
                      '${tutor.rating}  ·  ${formatNumber(tutor.studentCount)} students',
                      style: const TextStyle(
                        color: Color(0xCCFFFFFF),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _Avatar(url: tutor.avatarUrl, size: 84, radius: 42),
        ],
      ),
    );
  }
}

// ── Tutor card ────────────────────────────────────────────────────────────────

class _TutorCard extends StatelessWidget {
  final TutorEntity tutor;

  const _TutorCard({required this.tutor});

  @override
  Widget build(BuildContext context) {
    final chipColors = _subjectColors(tutor.subject);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Avatar(url: tutor.avatarUrl, size: 60, radius: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tutor.name,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "${formatNumber(tutor.pricePerHour)} so'm/h",
                          style: const TextStyle(
                            color: Color(0xFF18C96A),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: chipColors.bg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tutor.subject,
                        style: TextStyle(
                          color: chipColors.text,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '★★★★★  ${tutor.rating}  ·  ${formatNumber(tutor.studentCount)} students',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_outlined,
                    color: Color(0xFF18C96A), size: 16),
                SizedBox(width: 6),
                Text(
                  'Book a Session',
                  style: TextStyle(
                    color: Color(0xFF18C96A),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

// ── Avatar ────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String? url;
  final double size;
  final double radius;

  const _Avatar({this.url, required this.size, required this.radius});

  @override
  Widget build(BuildContext context) {
    final imageUrl = url == null
        ? null
        : url!.startsWith('http')
            ? url!
            : '$baseCdnUrl/$url';

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: imageUrl != null
          ? Image.network(
              imageUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  _placeholder(size),
            )
          : _placeholder(size),
    );
  }

  Widget _placeholder(double size) => Container(
        width: size,
        height: size,
        color: const Color(0xFFE5E7EB),
        child: const Icon(Icons.person_outline,
            color: Color(0xFF9CA3AF), size: 28),
      );
}

// ── Helpers ───────────────────────────────────────────────────────────────────

({Color bg, Color text}) _subjectColors(String subject) {
  final s = subject.toLowerCase();
  if (s.contains('ielts') || s.contains('toefl') || s.contains('exam')) {
    return (bg: const Color(0xFFFFF7ED), text: const Color(0xFFEA580C));
  }
  if (s.contains('english') || s.contains('literature') ||
      s.contains('writing') || s.contains('grammar')) {
    return (bg: const Color(0xFFEFF6FF), text: const Color(0xFF3B82F6));
  }
  if (s.contains('speak') || s.contains('communication') ||
      s.contains('math') || s.contains('science') || s.contains('physics')) {
    return (bg: const Color(0xFFF0FDF4), text: const Color(0xFF15803D));
  }
  return (bg: const Color(0xFFF3F4F6), text: const Color(0xFF374151));
}
