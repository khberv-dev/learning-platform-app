import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/chat/domain/entity/chat_room_entity.dart';
import 'package:student/core/chat/presentation/chat_rooms_controller.dart';
import 'package:student/core/courses/presentation/courses_controller.dart';
import 'package:student/core/groups/domain/entity/group_entity.dart';
import 'package:student/core/groups/presentation/my_groups_controller.dart';
import 'package:student/core/main/presentation/navbar_controller.dart';
import 'package:student/core/mentors/domain/entity/mentor_entity.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_flat_pill_button.dart';
import 'package:student/ui/chat/chat_room_screen.dart';
import 'package:student/utils/lib.dart';

const _background = Color(0xFFEFEEF4);
const _ink = Color(0xFF15141A);
const _muted = Color(0xFF6D737E);
const _caption = Color(0xFF8A8C9C);
const _green = Color(0xFF78C93C);

/// Tab index of Courses in the navbar, where "Browse courses" leads.
const _coursesTabIndex = 1;

/// Roughly the title's height plus its gap, kept out of the space the
/// empty states centre themselves in.
const _titleBlockHeight = 56.0;

/// The navbar's Study tab: the student's groups — one per course — each
/// with a way into its chat and the mentors who lead it. Group membership is
/// fully admin-managed, so there's nothing to browse or book here.
class StudyPage extends ConsumerWidget {
  const StudyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(myGroupsControllerProvider);
    final insets = MediaQuery.paddingOf(context);

    Future<void> refresh() async {
      ref.invalidate(myGroupsControllerProvider);
      ref.invalidate(chatRoomsProvider);
      await ref.read(myGroupsControllerProvider.future);
    }

    final title = Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Text(
        l10n.navStudy,
        style: const TextStyle(
          color: _ink,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    Widget scrollable(Widget child, {bool centred = false}) => LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          insets.top + AppSpacing.lg,
          AppSpacing.lg,
          insets.bottom + AppSpacing.xl,
        ),
        children: [
          title,
          if (centred)
            // Vertically centred below the title, yet still
            // pull-to-refreshable.
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    constraints.maxHeight -
                    insets.top -
                    insets.bottom -
                    AppSpacing.lg -
                    AppSpacing.xl -
                    _titleBlockHeight,
              ),
              child: Center(child: child),
            )
          else
            child,
        ],
      ),
    );

    return ColoredBox(
      color: _background,
      child: RefreshIndicator(
        onRefresh: refresh,
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => scrollable(
            _Message(title: l10n.studyLoadFailed, body: l10n.studyPullToRetry),
            centred: true,
          ),
          data: (groups) {
            if (groups.isEmpty) {
              final ownsCourse =
                  ref.watch(myCoursesControllerProvider).value?.isNotEmpty ??
                  false;
              return scrollable(
                ownsCourse
                    ? _Message(
                        key: const ValueKey('study-waiting'),
                        title: l10n.studyWaitingTitle,
                        body: l10n.studyWaitingBody,
                      )
                    : _Message(
                        key: const ValueKey('study-no-course'),
                        title: l10n.studyEmptyTitle,
                        body: l10n.studyEmptyBody,
                        action: l10n.studyBrowseCourses,
                        onAction: () =>
                            ref.read(navbarControllerProvider.notifier).state =
                                _coursesTabIndex,
                      ),
                centred: true,
              );
            }
            final rooms = ref.watch(chatRoomsProvider).value ?? const [];
            return scrollable(
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < groups.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.xl),
                    _GroupSection(
                      key: ValueKey('group-${groups[i].id}'),
                      group: groups[i],
                      roomId: _roomFor(
                        groups[i],
                        rooms,
                        // One group can use a room the API hasn't tied to a
                        // group; with several, only an exact match.
                        fallbackToOnlyRoom: groups.length == 1,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static String? _roomFor(
    GroupEntity group,
    List<ChatRoomEntity> rooms, {
    required bool fallbackToOnlyRoom,
  }) =>
      rooms.where((r) => r.group?.id == group.id).firstOrNull?.id ??
      (fallbackToOnlyRoom && rooms.length == 1 ? rooms.single.id : null);
}

/// A centred icon, title, body and optional green button — for when there's
/// no group to show.
class _Message extends StatelessWidget {
  final String title;
  final String body;
  final String? action;
  final VoidCallback? onAction;

  const _Message({
    super.key,
    required this.title,
    required this.body,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final action = this.action;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/icons/nav_study.svg',
          width: 48,
          colorFilter: const ColorFilter.mode(
            Color(0xFFA5A6B9),
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _ink,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            height: 1.3,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          body,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _muted,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
        if (action != null) ...[
          const SizedBox(height: AppSpacing.lg),
          // Sized to its label, not the screen.
          IntrinsicWidth(
            child: AppFlatPillButton(
              label: action,
              background: _green,
              foreground: Colors.white,
              onTap: onAction,
              height: 48,
              fontSize: 15,
            ),
          ),
        ],
      ],
    );
  }
}

/// One group: its card, then its mentors.
class _GroupSection extends StatelessWidget {
  final GroupEntity group;
  final String? roomId;

  const _GroupSection({super.key, required this.group, required this.roomId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final primary = group.primaryMentor;
    final hasMentors = primary != null || group.supportMentors.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GroupCard(group: group, roomId: roomId),
        if (hasMentors) ...[
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.studyMentors,
            style: const TextStyle(
              color: _ink,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (primary != null)
            _MentorRow(
              mentor: primary,
              role: l10n.studyPrimaryMentor,
              badge: 'assets/images/ic_primary_mentor.png',
            ),
          for (final support in group.supportMentors) ...[
            const SizedBox(height: AppSpacing.md),
            _MentorRow(
              mentor: support,
              role: l10n.studySupportMentor,
              badge: 'assets/images/ic_support_mentor.png',
            ),
          ],
        ],
      ],
    );
  }
}

/// White card: the group's picture, name, member count, and the way into
/// its chat.
class _GroupCard extends StatelessWidget {
  final GroupEntity group;
  final String? roomId;

  const _GroupCard({required this.group, required this.roomId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final roomId = this.roomId;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8EAF0), width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/group_avatar.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            group.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _ink,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.studyMembers(group.students.length),
            style: const TextStyle(
              color: _caption,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (roomId != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Material(
              color: const Color(0xFFF2F4F9),
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () =>
                    context.push('${ChatRoomScreen.path}?roomId=$roomId'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.people_alt_rounded,
                        size: 20,
                        color: Color(0xFF66BB3C),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          l10n.studyJoinGroup,
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A white stadium: the mentor's photo with their role badge, the role, and
/// their name. Tapping opens their profile.
class _MentorRow extends StatelessWidget {
  final MentorEntity mentor;
  final String role;
  final String badge;

  const _MentorRow({
    required this.mentor,
    required this.role,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final url = resolveMediaUrl(mentor.avatarUrl);
    const placeholder = ColoredBox(
      color: Color(0xFFF2F4F9),
      child: Icon(Icons.person_rounded, size: 30, color: Color(0xFFA5A6B9)),
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => context.push('/mentor/${mentor.id}'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 60,
                child: Stack(
                  children: [
                    ClipOval(
                      child: SizedBox.square(
                        dimension: 58,
                        child: url == null
                            ? placeholder
                            : Image.network(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => placeholder,
                              ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Image.asset(badge, width: 22, height: 22),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      role,
                      style: const TextStyle(
                        color: _caption,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mentor.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
