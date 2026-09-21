import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/groups/domain/entity/group_entity.dart';
import 'package:student/core/groups/presentation/my_group_controller.dart';
import 'package:student/l10n/app_localizations.dart';

const _dayOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String _dayName(AppLocalizations l10n, String code) => switch (code) {
  'Mon' => l10n.weekdayMonday,
  'Tue' => l10n.weekdayTuesday,
  'Wed' => l10n.weekdayWednesday,
  'Thu' => l10n.weekdayThursday,
  'Fri' => l10n.weekdayFriday,
  'Sat' => l10n.weekdaySaturday,
  'Sun' => l10n.weekdaySunday,
  _ => code,
};

/// The student's current group — the only way they're paired with a mentor
/// now that 1:1 booking is gone. Silent on loading/error; only worth
/// showing once there's something (or definitely nothing) to report.
class MyGroupCard extends ConsumerWidget {
  const MyGroupCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myGroupControllerProvider);
    final l10n = AppLocalizations.of(context);

    return state.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (group) {
        if (group == null) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            child: Text(
              l10n.groupNoGroup,
              style: const TextStyle(color: Color(0xff8a949b), fontSize: 14),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: _GroupCard(group: group),
        );
      },
    );
  }
}

class _GroupCard extends StatelessWidget {
  final GroupEntity group;

  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final days = _dayOrder
        .where((d) => group.schedule[d]?.isNotEmpty ?? false)
        .toList();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardEdge,
            offset: Offset(0, 5),
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.groupSectionTitle,
            style: const TextStyle(
              color: Color(0xff8a949b),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            group.title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final mentor in group.mentors) ...[
            _MentorRow(entry: mentor),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (group.students.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.groupStudentsCount(group.students.length),
              style: const TextStyle(color: Color(0xff8a949b), fontSize: 13),
            ),
          ],
          if (days.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.groupScheduleTitle,
              style: const TextStyle(
                color: Color(0xff8a949b),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            for (final day in days)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '${_dayName(l10n, day)}: ${group.schedule[day]!.join(', ')}',
                  style: const TextStyle(
                    color: Color(0xff374151),
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _MentorRow extends StatelessWidget {
  final GroupMentorEntity entry;

  const _MentorRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mentor = entry.mentor;
    final roleLabel = entry.role == GroupMentorRole.primary
        ? l10n.groupPrimaryMentor
        : l10n.groupSupportMentor;

    return GestureDetector(
      onTap: () => context.push('/mentor/${mentor.id}'),
      child: Row(
        children: [
          _Avatar(url: mentor.avatarUrl, name: mentor.name, size: 44),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mentor.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  roleLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff8a949b),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 22,
            color: Color(0xff8a949b),
          ),
        ],
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
    return ClipOval(
      child: SizedBox.square(
        dimension: size,
        child: url == null
            ? _fallback(context)
            : Image.network(
                url!,
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
