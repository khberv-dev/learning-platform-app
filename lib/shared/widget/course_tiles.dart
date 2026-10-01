import 'package:flutter/material.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/courses/domain/entity/course_entity.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/course_cover_tile.dart';

const _ink = Color(0xFF15141A);
const _body = Color(0xFF6D737E);
const _green = Color(0xFF78C93C);

/// A section heading with an optional green link on the right.
class CourseSectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const CourseSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final action = this.action;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action,
              style: const TextStyle(
                color: _green,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

/// A course on sale: cover, title, a two-line description, then lesson and
/// hour chips when the API provides those counts.
class AvailableCourseTile extends StatelessWidget {
  final CourseEntity course;
  final int colorIndex;
  final VoidCallback onTap;
  final double coverHeight;

  const AvailableCourseTile({
    super.key,
    required this.course,
    required this.colorIndex,
    required this.onTap,
    this.coverHeight = 138,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final description = course.description;
    final lessons = course.lessonsCount;
    final hours = course.durationHours;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CourseCoverTile(
            title: course.title,
            imageUrl: course.imageUrl,
            colorIndex: colorIndex,
            height: coverHeight,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            course.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _body,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ],
          if (lessons != null || hours != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (lessons != null)
                  _CountChip(
                    label: l10n.courseLessonCount(lessons),
                    background: const Color(0xFFDDEFFC),
                    foreground: const Color(0xFF4A9FE0),
                  ),
                if (hours != null)
                  _CountChip(
                    label: l10n.courseHourCount(hours),
                    background: const Color(0xFFFCE7DA),
                    foreground: const Color(0xFFF08A4B),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _CountChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
