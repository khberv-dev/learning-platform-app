import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/courses/domain/entity/my_course_entity.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/course_cover_tile.dart';

const coursesPageBackground = Color(0xFFEFEEF4);
const _ink = Color(0xFF15141A);
const _caption = Color(0xFF8A8C9C);
const _hint = Color(0xFFA5A6B9);
const _green = Color(0xFF78C93C);

/// A white pill search box with a magnifier and a grey hint.
class CoursesSearchField extends StatelessWidget {
  final TextEditingController controller;

  const CoursesSearchField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const pill = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(999)),
      borderSide: BorderSide.none,
    );
    return TextField(
      key: const ValueKey('courses-search'),
      controller: controller,
      textInputAction: TextInputAction.search,
      style: const TextStyle(
        color: _ink,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      cursorColor: _ink,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).coursesSearchHint,
        hintStyle: const TextStyle(
          color: _hint,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 10),
          child: SvgPicture.asset('assets/icons/search.svg', width: 20),
        ),
        prefixIconConstraints: const BoxConstraints(),
        border: pill,
        enabledBorder: pill,
        focusedBorder: pill,
      ),
    );
  }
}

/// An enrolled course: its cover in a white card, then a book badge, the
/// title with its lesson count, and a progress ring.
class CurrentCourseCard extends StatelessWidget {
  final MyCourseEntity course;
  final int colorIndex;
  final VoidCallback onTap;

  const CurrentCourseCard({
    super.key,
    required this.course,
    required this.colorIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            CourseCoverTile(
              title: course.title,
              colorIndex: colorIndex,
              height: 140,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F7DC),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset('assets/icons/book.svg', width: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        course.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLocalizations.of(
                          context,
                        ).courseLessonCount(course.lessonsCount),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _caption,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _ProgressRing(progress: course.progress),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  /// 0–1.
  final double progress;

  const _ProgressRing({required this.progress});

  @override
  Widget build(BuildContext context) {
    final value = progress.clamp(0.0, 1.0);
    return SizedBox.square(
      key: const ValueKey('course-progress-ring'),
      dimension: 46,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 4,
              color: _green,
              backgroundColor: const Color(0xFFE5E7EA),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            '${(value * 100).round()}%',
            style: const TextStyle(
              color: _ink,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
