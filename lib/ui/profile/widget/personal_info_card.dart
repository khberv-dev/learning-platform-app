import 'package:flutter/material.dart';
import 'package:student/core/user/domain/entity/user_entity.dart';
import 'package:student/utils/lib.dart';

class PersonalInfoCard extends StatelessWidget {
  final UserEntity? user;

  const PersonalInfoCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Personal Info',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          _divider(),
          _InfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Full Name',
            value: user?.fullName ?? '—',
          ),
          _divider(),
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone Number',
            value: formatPhone(user?.phoneNumber),
          ),
          _divider(),
          const _InfoRow(
            icon: Icons.lock_outline_rounded,
            label: 'Password',
            value: 'Update Password',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _IconBox(icon: icon),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (onTap != null)
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Color(0xFFD1D5DB),
              ),
          ],
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;

  const _IconBox({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 16, color: const Color(0xFF333333)),
    );
  }
}

Widget _divider() =>
    const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6));
