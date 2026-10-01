import 'package:flutter/material.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/user/domain/entity/user_entity.dart';
import 'package:student/utils/lib.dart';

const _ink = Color(0xFF15141A);
const _muted = Color(0xFF8A8C9C);
const _tile = Color(0xFFF2F4F9);

/// The student's photo, name and phone (or email, for an email sign-up) in a
/// white stadium. Tapping it opens the account details.
class ProfileHeaderCard extends StatelessWidget {
  final UserEntity? user;
  final VoidCallback onTap;

  const ProfileHeaderCard({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final user = this.user;
    final phone = user?.phoneNumber ?? '';
    final contact = phone.isNotEmpty ? formatPhone(phone) : (user?.email ?? '');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(3, 3, 16, 3),
          child: Row(
            children: [
              ProfileAvatar(url: user?.avatar, size: 56),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user?.fullName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (contact.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        contact,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.chevron_right_rounded, size: 24, color: _ink),
            ],
          ),
        ),
      ),
    );
  }
}

/// A round photo, or a grey person outline without one.
class ProfileAvatar extends StatelessWidget {
  final String? url;
  final double size;

  const ProfileAvatar({super.key, required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    final url = resolveMediaUrl(this.url);
    final placeholder = ColoredBox(
      color: _tile,
      child: Icon(
        Icons.person_outline_rounded,
        size: size * 0.45,
        color: const Color(0xFFA5A6B9),
      ),
    );
    return ClipOval(
      child: SizedBox.square(
        dimension: size,
        child: url == null
            ? placeholder
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
              ),
      ),
    );
  }
}
