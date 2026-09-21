import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/mentors/presentation/mentors_controller.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_empty_state.dart';
import 'package:student/shared/widget/section_title.dart';
import 'package:student/ui/mentors/widget/mentor_card.dart';
import 'package:student/ui/mentors/widget/my_group_card.dart';

class MentorsPage extends ConsumerWidget {
  const MentorsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mentorsControllerProvider);
    final l10n = AppLocalizations.of(context);

    Future<void> refresh() async {
      ref.invalidate(mentorsControllerProvider);
      await ref.read(mentorsControllerProvider.future);
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
          child: SectionTitle(title: l10n.mentorsTitle, fontSize: 30),
        ),
        const MyGroupCard(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: refresh,
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _Scrollable(
                child: AppEmptyState(
                  imagePath: 'assets/images/no_recorded_sessions_puppet.png',
                  title: l10n.mentorsLoadFailed,
                  subtitle: l10n.mentorsPullToRetry,
                ),
              ),
              data: (mentors) {
                if (mentors.isEmpty) {
                  return _Scrollable(
                    child: AppEmptyState(
                      imagePath:
                          'assets/images/no_recorded_sessions_puppet.png',
                      title: l10n.mentorsEmptyTitle,
                      subtitle: l10n.mentorsEmptySubtitle,
                    ),
                  );
                }
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
                  ),
                  // One extra leading item for the section heading.
                  itemCount: mentors.length + 1,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.lg),
                  itemBuilder: (_, i) => i == 0
                      ? SectionTitle(title: l10n.mentorsAvailable, fontSize: 22)
                      : MentorCard(mentor: mentors[i - 1]),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Keeps an empty state pull-to-refreshable.
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
