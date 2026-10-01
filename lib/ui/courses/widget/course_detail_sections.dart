import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/courses/domain/entity/course_author_entity.dart';
import 'package:student/core/courses/domain/entity/course_entity.dart';
import 'package:student/core/courses/domain/entity/lesson_entity.dart';
import 'package:student/core/courses/domain/entity/unit_entity.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/course_cover_tile.dart';
import 'package:student/utils/lib.dart';

const courseDetailBackground = Color(0xFFEFEEF4);
const _ink = Color(0xFF15141A);
const _body = Color(0xFF6D737E);
const _caption = Color(0xFF717384);
const _label = Color(0xFFA5A6B9);
const _tile = Color(0xFFF2F4F9);
const _teacherBlue = Color(0xFF5BA0EE);
const _link = Color(0xFF458FEB);

/// A bold section heading on the course page.
class CourseSectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;

  const CourseSectionTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: _ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// The cover photo, full width with rounded bottom corners: title and stat
/// chips over its foot, and — for an owned course — a progress ring.
class CourseHero extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final int lessonCount;
  final int moduleCount;

  /// 0–100, or null to hide the ring (a course the student doesn't own).
  final int? progress;

  const CourseHero({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.lessonCount,
    required this.moduleCount,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final url = resolveMediaUrl(imageUrl);
    const fallback = ColoredBox(color: Color(0xFF78C93C));
    final progress = this.progress;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      child: AspectRatio(
        aspectRatio: 1 / 0.98,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url == null)
              fallback
            else
              Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              ),
            // Darkens the foot so the white title reads over any photo.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.5, 1],
                  colors: [Color(0x00000000), Color(0x8C000000)],
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: [
                            _GlassChip(
                              icon: Icons.menu_book_rounded,
                              label: l10n.courseLessonCount(lessonCount),
                            ),
                            _GlassChip(
                              icon: Icons.view_in_ar_rounded,
                              label: l10n.courseModuleCount(moduleCount),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (progress != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    _ProgressRing(percent: progress),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _GlassChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final int percent;

  const _ProgressRing({required this.percent});

  @override
  Widget build(BuildContext context) {
    final value = percent.clamp(0, 100);
    return Container(
      key: const ValueKey('course-progress'),
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: value / 100,
              strokeWidth: 4,
              color: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          Text(
            '$value%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// The white stadium used for the teacher and module rows: a pale round
/// badge, a title with a caption, and a chevron.
class _RowCard extends StatelessWidget {
  final Widget badge;
  final Widget text;
  final VoidCallback? onTap;

  const _RowCard({required this.badge, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: _tile,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: badge,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: text),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.chevron_right_rounded, size: 26, color: _ink),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Teacher / Name" — one of the course's authors. Tapping shows who they are.
class CourseTeacherCard extends StatelessWidget {
  final CourseAuthorEntity author;

  const CourseTeacherCard({super.key, required this.author});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _RowCard(
      onTap: () => showCourseAuthorSheet(context, author),
      badge: const Icon(Icons.badge_rounded, size: 22, color: _teacherBlue),
      text: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.courseTeacher,
            style: const TextStyle(
              color: _label,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            author.fullName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// A sheet with the author's photo, name and bio.
Future<void> showCourseAuthorSheet(
  BuildContext context,
  CourseAuthorEntity author,
) {
  final avatar = resolveMediaUrl(author.avatar);
  final bio = author.description;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    showDragHandle: true,
    // Material 3 caps a sheet at 640 wide; this one spans the screen.
    constraints: const BoxConstraints(maxWidth: double.infinity),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Centred, or the stretched column would pull it into an oval.
            Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: _tile,
                backgroundImage: avatar == null ? null : NetworkImage(avatar),
                child: avatar == null
                    ? const Icon(Icons.person_rounded, size: 36, color: _label)
                    : null,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              author.fullName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (bio != null && bio.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                bio,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _body,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

/// One module: its number when open, a padlock when not.
class CourseModuleRow extends StatelessWidget {
  final UnitEntity unit;
  final int index;
  final bool locked;
  final VoidCallback? onTap;

  const CourseModuleRow({
    super.key,
    required this.unit,
    required this.index,
    required this.locked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      child: _RowCard(
        onTap: onTap,
        badge: locked
            ? SvgPicture.asset(
                'assets/icons/lock.svg',
                key: const ValueKey('module-lock'),
                width: 20,
                height: 20,
              )
            : Text(
                (index + 1).toString().padLeft(2, '0'),
                style: const TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
        text: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              unit.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              AppLocalizations.of(context).courseLessonCount(unit.lessonsCount),
              style: const TextStyle(
                color: _caption,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One lesson inside an opened module: its number when open, a padlock when
/// not, with the lesson's short description beneath its title.
class CourseLessonRow extends StatelessWidget {
  final LessonEntity lesson;
  final int index;
  final VoidCallback? onTap;

  const CourseLessonRow({
    super.key,
    required this.lesson,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final description = lesson.description;
    return Semantics(
      button: onTap != null,
      child: _RowCard(
        onTap: onTap,
        badge: lesson.isLocked
            ? SvgPicture.asset(
                'assets/icons/lock.svg',
                key: const ValueKey('lesson-lock'),
                width: 20,
                height: 20,
              )
            : Text(
                (index + 1).toString().padLeft(2, '0'),
                style: const TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
        text: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              lesson.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: lesson.isLocked ? _label : _ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _caption,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A horizontal strip of other courses: a coloured tile with the title on
/// it, then the title and description beneath.
class OtherCoursesStrip extends StatelessWidget {
  final List<CourseEntity> courses;
  final ValueChanged<CourseEntity> onOpen;

  const OtherCoursesStrip({
    super.key,
    required this.courses,
    required this.onOpen,
  });

  static const _tileWidth = 170.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: courses.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final course = courses[i];
          final description = course.description;
          return GestureDetector(
            onTap: () => onOpen(course),
            child: SizedBox(
              width: _tileWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CourseCoverTile(
                    title: course.title,
                    colorIndex: i,
                    height: 128,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    course.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (description != null && description.isNotEmpty)
                    Text(
                      description,
                      maxLines: 2,
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
          );
        },
      ),
    );
  }
}

/// The "See all" link beside a section title.
class CourseSeeAllLink extends StatelessWidget {
  final VoidCallback onTap;

  const CourseSeeAllLink({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        AppLocalizations.of(context).courseSeeAll,
        style: const TextStyle(
          color: _link,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Grey body copy on the course page.
class CourseBodyText extends StatelessWidget {
  final String text;

  const CourseBodyText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _body,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
    );
  }
}
