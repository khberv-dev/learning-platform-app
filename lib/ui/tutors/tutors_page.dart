import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/tutors/presentation/tutors_controller.dart';
import 'package:student/ui/tutors/widget/tutor_card.dart';

class TutorsPage extends ConsumerWidget {
  const TutorsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tutorsControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
            16,
          ),
          child: Text(
            'Find a Tutor',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF111827),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        state.when(
          loading: () =>
              const Expanded(child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Expanded(
            child: Center(
              child: Text(
                e.toString(),
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
          ),
          data: (tutors) {
            if (tutors.isEmpty) {
              return Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(tutorsControllerProvider);
                    await ref.read(tutorsControllerProvider.future);
                  },
                  child: const SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: 400,
                      child: Center(
                        child: Text(
                          'No tutors found.',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
            return Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(tutorsControllerProvider);
                  await ref.read(tutorsControllerProvider.future);
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    16,
                    AppSpacing.xl,
                    96,
                  ),
                  children: [
                    const Text(
                      'Available Tutors',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...tutors.map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TutorCard(tutor: t),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
