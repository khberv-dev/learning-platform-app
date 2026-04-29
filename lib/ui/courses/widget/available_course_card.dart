import 'package:flutter/material.dart';
import 'package:student/app/data/network/config.dart';
import 'package:student/core/courses/domain/entity/course_entity.dart';
import 'package:student/utils/lib.dart';

class AvailableCourseCard extends StatelessWidget {
  final CourseEntity course;

  const AvailableCourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CourseImage(imageUrl: course.imageUrl),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${course.lessonsCount} lessons · ${course.level}',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "${formatNumber(course.price)} so'm",
                        style: const TextStyle(
                          color: Color(0xFF18C96A),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFF18C96A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                    size: 18,
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

class _CourseImage extends StatelessWidget {
  final String? imageUrl;

  const _CourseImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) return _placeholder();

    final url =
        imageUrl!.startsWith('http') ? imageUrl! : '$baseCdnUrl/$imageUrl';

    return Image.network(
      url,
      height: 120,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => _placeholder(),
    );
  }

  Widget _placeholder() => Container(
    height: 120,
    color: const Color(0xFFE5E7EB),
  );
}
