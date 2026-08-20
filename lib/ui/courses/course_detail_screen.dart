import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/data/network/config.dart';
import 'package:student/core/courses/domain/entity/course_detail_entity.dart';
import 'package:student/core/courses/domain/entity/unit_entity.dart';
import 'package:student/core/courses/presentation/course_detail_controller.dart'
    show courseDetailControllerProvider;
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_button.dart';
import 'package:student/ui/courses/unit_screen.dart';
import 'package:student/ui/plans/plans_screen.dart';

class CourseDetailScreen extends ConsumerWidget {
  static const path = '/course/:id';

  final String courseId;
  final bool isOwned;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
    required this.isOwned,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(courseDetailControllerProvider(courseId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            e.toString(),
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
        ),
        data: (course) => _CourseDetailBody(course: course, isOwned: isOwned),
      ),
    );
  }
}

class _CourseDetailBody extends StatelessWidget {
  final CourseDetailEntity course;
  final bool isOwned;

  const _CourseDetailBody({required this.course, required this.isOwned});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Banner(course: course)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Text(
                  AppLocalizations.of(context).courseUnits,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF111827),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, isOwned ? 24 : 100),
              sliver: SliverList.separated(
                itemCount: course.units.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _UnitCard(
                  unit: course.units[i],
                  index: i,
                  isOwned: isOwned,
                  courseId: course.id,
                ),
              ),
            ),
          ],
        ),
        // Back button over the banner
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 24,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 20,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ),
        // Purchase bar
        if (!isOwned)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _PurchaseBar(courseId: course.id),
          ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  final CourseDetailEntity course;

  const _Banner({required this.course});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final imageUrl = course.image == null
        ? null
        : course.image!.startsWith('http')
        ? course.image!
        : '$baseCdnUrl/${course.image}';

    return SizedBox(
      height: 180 + topPadding,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  const ColoredBox(color: Color(0xFF18C96A)),
            )
          else
            const ColoredBox(color: Color(0xFF18C96A)),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x66000000), Color(0xCC000000)],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24, topPadding + 56, 24, 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.menu_book_outlined,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  course.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(
                    context,
                  ).courseLessonCount(course.lessonsCount),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  final UnitEntity unit;
  final int index;
  final bool isOwned;
  final String courseId;

  const _UnitCard({
    required this.unit,
    required this.index,
    required this.isOwned,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    final numberStr = (index + 1).toString().padLeft(2, '0');

    return GestureDetector(
      // Units are the only thing this page opens — the lessons inside them, and
      // playback, live one level deeper on the unit page.
      onTap: isOwned
          ? () => context.push(
              '${UnitScreen.path}?courseId=$courseId&unitIndex=$index',
            )
          : null,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: isOwned ? 1.0 : 0.6,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isOwned
                      ? const Color(0xFFF0FDF4)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  numberStr,
                  style: TextStyle(
                    color: isOwned
                        ? const Color(0xFF18C96A)
                        : const Color(0xFF9CA3AF),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      AppLocalizations.of(
                        context,
                      ).courseLessonCount(unit.lessonsCount),
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isOwned ? Icons.chevron_right_rounded : Icons.lock_outline,
                color: const Color(0xFF9CA3AF),
                size: isOwned ? 22 : 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PurchaseBar extends StatelessWidget {
  final String courseId;

  const _PurchaseBar({required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: AppButton.filled(
        // A course carries no price of its own — each plan sets one, so this
        // leads to the plan picker rather than straight to checkout.
        label: AppLocalizations.of(context).courseChoosePlan,
        icon: const Icon(Icons.shopping_cart_outlined),
        fontSize: 16,
        onTap: () => context.push('${PlansScreen.path}?courseId=$courseId'),
      ),
    );
  }
}
