import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/data/network/config.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/courses/domain/entity/course_entity.dart';
import 'package:student/shared/widget/app_button.dart';

/// Grid tile for a purchasable course: cover art on a dark card, with the
/// title, lesson count and a call to action beneath it.
class AvailableCourseCard extends StatelessWidget {
  final CourseEntity course;

  const AvailableCourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    void open() => context.push('/course/${course.id}?owned=false');

    return GestureDetector(
      onTap: open,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.courseCard,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Takes whatever height the tile has left, so titles of differing
            // lengths don't push the button out of the card.
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: _CourseImage(imageUrl: course.imageUrl),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              course.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${course.lessonsCount} lessons',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xffa79a92),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton.filled(
              label: 'Learn more',
              onTap: open,
              height: 40,
              depth: 4,
              fontSize: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseImage extends StatelessWidget {
  final String? imageUrl;

  const _CourseImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) return const _Placeholder();

    final url = imageUrl!.startsWith('http')
        ? imageUrl!
        : '$baseCdnUrl/$imageUrl';

    return Image.network(
      url,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _Placeholder(),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white.withAlpha(20),
      child: const Center(
        child: Icon(
          Icons.menu_book_rounded,
          color: Color(0xffa79a92),
          size: 32,
        ),
      ),
    );
  }
}
