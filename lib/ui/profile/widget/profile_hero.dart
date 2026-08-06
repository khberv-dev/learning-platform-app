import 'package:flutter/material.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/user/domain/entity/user_entity.dart';
import 'package:student/utils/lib.dart';

/// Full-bleed portrait at the top of the profile, with the user's name laid
/// over its lower-left corner.
class ProfileHero extends StatelessWidget {
  /// Share of the width the hero is tall, taken from the design.
  static const _aspect = 0.96;

  final UserEntity? user;

  /// Absolute URL of the user's photo. [UserEntity] has no avatar field yet,
  /// so this is normally null and the gradient fallback shows instead.
  final String? photoUrl;

  const ProfileHero({super.key, required this.user, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final url = resolveMediaUrl(photoUrl);

    return SizedBox(
      width: double.infinity,
      height: MediaQuery.sizeOf(context).width * _aspect,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (url == null)
            _Fallback(initials: user?.initials ?? '?')
          else
            Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  _Fallback(initials: user?.initials ?? '?'),
            ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
              child: Text(
                user?.firstName ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stands in for the portrait: the design's green-to-sky backdrop with the
/// user's initials.
class _Fallback extends StatelessWidget {
  final String initials;

  const _Fallback({required this.initials});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff6fd48a), Color(0xffc3d3e8)],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white.withAlpha(210),
            fontSize: 88,
            fontWeight: FontWeight.w800,
            letterSpacing: -2,
          ),
        ),
      ),
    );
  }
}
