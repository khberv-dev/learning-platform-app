import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/tutors/presentation/tutors_controller.dart';
import 'package:student/shared/widget/app_empty_state.dart';
import 'package:student/shared/widget/section_title.dart';
import 'package:student/ui/tutors/widget/tutor_card.dart';

class TutorsPage extends ConsumerWidget {
  const TutorsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tutorsControllerProvider);

    Future<void> refresh() async {
      ref.invalidate(tutorsControllerProvider);
      await ref.read(tutorsControllerProvider.future);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: SectionTitle(title: 'Find a tutor', fontSize: 30),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: refresh,
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _Scrollable(
                child: AppEmptyState(
                  imagePath: 'assets/images/no_recorded_sessions_puppet.png',
                  title: "Couldn't load tutors",
                  subtitle: 'Pull down to try again',
                ),
              ),
              data: (tutors) {
                if (tutors.isEmpty) {
                  return const _Scrollable(
                    child: AppEmptyState(
                      imagePath:
                          'assets/images/no_recorded_sessions_puppet.png',
                      title: 'No tutors yet',
                      subtitle: 'Tutors will appear here once they join',
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
                  itemCount: tutors.length + 1,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.lg),
                  itemBuilder: (_, i) => i == 0
                      ? const SectionTitle(
                          title: 'Available tutors',
                          fontSize: 22,
                        )
                      : TutorCard(tutor: tutors[i - 1]),
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
