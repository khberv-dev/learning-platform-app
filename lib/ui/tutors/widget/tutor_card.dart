import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/data/network/config.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/tutors/domain/entity/tutor_entity.dart';
import 'package:student/shared/widget/rating_stars.dart';

class TutorCard extends StatelessWidget {
  final TutorEntity tutor;

  const TutorCard({super.key, required this.tutor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/tutor/${tutor.id}'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          // A solid offset edge rather than a diffuse drop shadow, so the card
          // sits in the same raised language as the buttons.
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardEdge,
              offset: Offset(0, 5),
              blurRadius: 3,
            ),
          ],
        ),
        child: Row(
          children: [
            _Avatar(url: tutor.avatarUrl, name: tutor.name, size: 62),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tutor.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (tutor.profession != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _ProfessionChip(profession: tutor.profession!),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  _Rating(
                    rating: tutor.rating,
                    feedbackCount: tutor.feedbackCount,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              Icons.chevron_right_rounded,
              size: 30,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

class _Rating extends StatelessWidget {
  final double rating;
  final int feedbackCount;

  const _Rating({required this.rating, required this.feedbackCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RatingStars(rating: rating),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            '${rating.toStringAsFixed(1)}  ·  $feedbackCount reviews',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xff8a949b),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfessionChip extends StatelessWidget {
  final String profession;

  const _ProfessionChip({required this.profession});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.round),
        border: Border.all(color: AppColors.ink, width: 1.5),
      ),
      child: Text(
        profession,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String name;
  final double size;

  const _Avatar({this.url, required this.name, required this.size});

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = url == null
        ? null
        : url!.startsWith('http')
        ? url!
        : '$baseCdnUrl/$url';

    return ClipOval(
      child: SizedBox.square(
        dimension: size,
        child: imageUrl == null
            ? _fallback(context)
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallback(context),
              ),
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.primary,
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.34,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
