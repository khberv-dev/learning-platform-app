import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/chat/presentation/chat_rooms_controller.dart';
import 'package:student/core/groups/domain/entity/group_entity.dart';
import 'package:student/core/groups/presentation/my_group_controller.dart';
import 'package:student/core/mentors/domain/entity/mentor_entity.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_button.dart';
import 'package:student/shared/widget/app_empty_state.dart';
import 'package:student/shared/widget/section_title.dart';
import 'package:student/ui/chat/chat_room_screen.dart';

/// A single, static "Study" tab — replaces the old Mentor/Chat pair that
/// swapped in the navbar depending on whether the student had a chat room.
/// Group membership is fully admin-managed now, so there's nothing left to
/// browse or book: this just reports the student's current group (if any)
/// and gets them into its chat.
class StudyPage extends ConsumerWidget {
  const StudyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myGroupControllerProvider);
    final l10n = AppLocalizations.of(context);

    Future<void> refresh() async {
      ref.invalidate(myGroupControllerProvider);
      await ref.read(myGroupControllerProvider.future);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg + MediaQuery.paddingOf(context).top,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: SectionTitle(title: l10n.studyTitle, fontSize: 30),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: refresh,
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _Scrollable(
                child: AppEmptyState(
                  imagePath: 'assets/images/no_recorded_sessions_puppet.png',
                  title: l10n.studyLoadFailed,
                  subtitle: l10n.studyPullToRetry,
                ),
              ),
              data: (group) => _Scrollable(
                child: group == null
                    ? AppEmptyState(
                        imagePath:
                            'assets/images/no_recorded_sessions_puppet.png',
                        title: l10n.studyNoGroupTitle,
                        subtitle: l10n.studyNoGroupMessage,
                      )
                    : _GroupStatus(group: group),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Keeps an empty/error state pull-to-refreshable.
class _Scrollable extends StatelessWidget {
  final Widget child;

  const _Scrollable({required this.child});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
      ),
      children: [child],
    );
  }
}

class _GroupStatus extends ConsumerWidget {
  final GroupEntity group;

  const _GroupStatus({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final primary = group.primaryMentor;
    final roomsState = ref.watch(chatRoomsProvider);
    final roomId = roomsState.value?.firstOrNull?.id;

    return Padding(
      padding: EdgeInsets.only(
        bottom: AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
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
                  group.title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                if (primary != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.studyYourMentor,
                    style: const TextStyle(
                      color: Color(0xff8a949b),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _MentorTile(mentor: primary.mentor),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (roomId != null)
            AppButton.filled(
              label: l10n.studyOpenChat,
              onTap: () =>
                  context.push('${ChatRoomScreen.path}?roomId=$roomId'),
            ),
        ],
      ),
    );
  }
}

class _MentorTile extends StatelessWidget {
  final MentorEntity mentor;

  const _MentorTile({required this.mentor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/mentor/${mentor.id}'),
      child: Row(
        children: [
          _Avatar(url: mentor.avatarUrl, name: mentor.name, size: 52),
          const SizedBox(width: AppSpacing.md),
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
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (mentor.profession != null)
                  Text(
                    mentor.profession!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xff8a949b),
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 24,
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
