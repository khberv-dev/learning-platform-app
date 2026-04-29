import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/data/network/config.dart';
import 'package:student/core/courses/domain/entity/my_course_entity.dart';

class MyCourseCard extends StatelessWidget {
  final MyCourseEntity course;

  const MyCourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final pct = (course.progress * 100).round();

    return GestureDetector(
      onTap: () => context.push('/course/${course.id}?owned=true'),
      child: Container(
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
                  const SizedBox(height: 6),
                  Text(
                    '${course.lessonsCount} lessons  ·  ${course.level}',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '$pct%',
                        style: const TextStyle(
                          color: Color(0xFF18C96A),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: course.progress,
                      color: const Color(0xFF18C96A),
                      backgroundColor: const Color(0xFFE5E7EB),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
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
    if (imageUrl == null) return _placeholder();

    final url = imageUrl!.startsWith('http')
        ? imageUrl!
        : '$baseCdnUrl/$imageUrl';

    return Image.network(
      url,
      height: 120,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => _placeholder(),
    );
  }

  Widget _placeholder() =>
      Container(height: 120, color: const Color(0xFFE5E7EB));
}
