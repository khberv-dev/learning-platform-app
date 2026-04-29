import 'package:flutter/material.dart';
import 'package:student/app/data/network/config.dart';
import 'package:student/core/tutors/domain/entity/tutor_entity.dart';

class TutorCard extends StatelessWidget {
  final TutorEntity tutor;

  const TutorCard({super.key, required this.tutor});

  @override
  Widget build(BuildContext context) {
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
                        Expanded(
                          child: Text(
                            tutor.name,
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!tutor.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Inactive',
                              style: TextStyle(
                                color: Color(0xFFDC2626),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '★★★★★  ${tutor.rating.toStringAsFixed(1)}  ·  ${tutor.feedbackCount} reviews',
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
              errorBuilder: (context, error, stack) => _placeholder(size),
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
