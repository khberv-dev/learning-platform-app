import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/courses/domain/entity/my_course_entity.dart';
import 'package:student/core/courses/presentation/courses_controller.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_flat_pill_button.dart';
import 'package:student/shared/widget/course_tiles.dart';
import 'package:student/ui/ai_assessment/ai_speaking_partner_screen.dart';
import 'package:student/ui/p2p/p2p_matchmaking_screen.dart';

const _ink = Color(0xFF15141A);
const _muted = Color(0xFF6D737E);
const _green = Color(0xFF78C93C);

/// One card per course the student owns, each with its progress and a way
/// back in. Nothing at all for a student who owns none — or while the list
/// loads or fails.
class HomeCourseCards extends ConsumerWidget {
  const HomeCourseCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(myCoursesControllerProvider).value ?? const [];
    if (courses.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (final course in courses) ...[
          HomeCourseCard(
            key: ValueKey('home-course-${course.courseId}'),
            course: course,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

/// A white card: book badge, title and lesson count, a progress ring, and a
/// green "Continue" button into the course.
class HomeCourseCard extends StatelessWidget {
  final MyCourseEntity course;

  const HomeCourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    void open() => context.push('/course/${course.courseId}?owned=true');

    return GestureDetector(
      onTap: open,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 10),
              spreadRadius: -6,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F7DC),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset('assets/icons/book.svg', width: 26),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        course.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.courseLessonCount(course.lessonsCount),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF8A8C9C),
                          fontSize: 13,
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
            const SizedBox(height: AppSpacing.lg),
            AppFlatPillButton(
              label: l10n.homeResume,
              background: _green,
              foreground: Colors.white,
              onTap: open,
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
      dimension: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 5,
              color: _green,
              backgroundColor: const Color(0xFFE5E7EA),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            '${(value * 100).round()}%',
            style: const TextStyle(
              color: _ink,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// The two speaking-practice tiles side by side: the AI partner, and finding
/// a real partner.
class HomePracticeTiles extends StatelessWidget {
  const HomePracticeTiles({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _PracticeTile(
              key: const ValueKey('home-ai-partner'),
              iconAsset: 'assets/icons/ai.svg',
              iconFill: const Color(0xFFE3F1FC),
              accent: const Color(0xFF4AA2EC),
              title: l10n.homeAiPartnerTitle,
              body: l10n.homeAiPartnerBody,
              action: l10n.homeAiPartnerAction,
              onTap: () => context.push(AiSpeakingPartnerScreen.path),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _PracticeTile(
              key: const ValueKey('home-find-partner'),
              iconAsset: 'assets/icons/binoculars.svg',
              iconFill: const Color(0xFFF1E6FC),
              accent: const Color(0xFF9B5DE5),
              title: l10n.homePartnerTitle,
              body: l10n.homePartnerBody,
              action: l10n.homePartnerAction,
              onTap: () => context.push(P2pMatchmakingScreen.path),
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeTile extends StatelessWidget {
  final String iconAsset;
  final Color iconFill;
  final Color accent;
  final String title;
  final String body;
  final String action;
  final VoidCallback onTap;

  const _PracticeTile({
    super.key,
    required this.iconAsset,
    required this.iconFill,
    required this.accent,
    required this.title,
    required this.body,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconFill,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(iconAsset, width: 28),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // The link sits at the foot, level across both tiles.
              const Spacer(),
              const SizedBox(height: AppSpacing.md),
              // The arrow rides at the end of the text, wrapping with it.
              Text.rich(
                TextSpan(
                  text: action,
                  children: [
                    const WidgetSpan(child: SizedBox(width: 4)),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 17,
                        color: accent,
                      ),
                    ),
                  ],
                ),
                style: TextStyle(
                  color: accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Courses on sale as a sideways carousel under a "Courses / See all"
/// heading. Hidden when there's nothing to show.
class HomeCoursesCarousel extends ConsumerWidget {
  /// Opens the full list — the Courses tab.
  final VoidCallback onSeeAll;

  const HomeCoursesCarousel({super.key, required this.onSeeAll});

  /// Each tile, so the next one peeks in from the right edge.
  static const tileWidth = 156.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final courses =
        ref.watch(availableCoursesControllerProvider).value ?? const [];
    if (courses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: CourseSectionHeader(
            title: l10n.coursesTitle,
            action: l10n.courseSeeAll,
            onAction: onSeeAll,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          key: const ValueKey('home-courses-carousel'),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < courses.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.md),
                SizedBox(
                  width: tileWidth,
                  child: AvailableCourseTile(
                    key: ValueKey('home-course-tile-${courses[i].id}'),
                    course: courses[i],
                    colorIndex: i,
                    coverHeight: 112,
                    onTap: () =>
                        context.push('/course/${courses[i].id}?owned=false'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
