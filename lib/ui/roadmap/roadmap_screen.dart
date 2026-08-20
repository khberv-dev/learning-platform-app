import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/close_icon_button.dart';
import 'package:student/ui/roadmap/roadmap_path.dart';
import 'package:student/ui/roadmap/widget/road_step_node.dart';

/// The CEFR ladder, in order. Each level's topics become steps on the path.
///
/// Built per call rather than held as a `const`: the level names and topics
/// are shown to the student, so they follow the app's language. The codes do
/// not — they are the API's.
List<({String code, String name, List<String> topics})> _levels(
  AppLocalizations l10n,
) => [
  (
    code: 'A1',
    name: l10n.roadmapLevelA1,
    topics: [
      l10n.roadmapTopicGreetings,
      l10n.roadmapTopicNumbersDates,
      l10n.roadmapTopicColorsObjects,
      l10n.roadmapTopicFamily,
      l10n.roadmapTopicFoodDrinks,
      l10n.roadmapTopicDailyRoutines,
    ],
  ),
  (
    code: 'A2',
    name: l10n.roadmapLevelA2,
    topics: [
      l10n.roadmapTopicShopping,
      l10n.roadmapTopicTravelTransport,
      l10n.roadmapTopicWeatherSeasons,
      l10n.roadmapTopicHomeFurniture,
      l10n.roadmapTopicHobbies,
      l10n.roadmapTopicHealthBody,
    ],
  ),
  (
    code: 'B1',
    name: l10n.roadmapLevelB1,
    topics: [
      l10n.roadmapTopicWorkCareers,
      l10n.roadmapTopicCurrentEvents,
      l10n.roadmapTopicFuturePlans,
      l10n.roadmapTopicPastExperiences,
      l10n.roadmapTopicOpinionsFeelings,
      l10n.roadmapTopicTourismCulture,
    ],
  ),
  (
    code: 'B2',
    name: l10n.roadmapLevelB2,
    topics: [
      l10n.roadmapTopicDebates,
      l10n.roadmapTopicSocialIssues,
      l10n.roadmapTopicBusinessEnglish,
      l10n.roadmapTopicMedia,
      l10n.roadmapTopicEnvironment,
      l10n.roadmapTopicAcademicWriting,
    ],
  ),
  (
    code: 'C1',
    name: l10n.roadmapLevelC1,
    topics: [
      l10n.roadmapTopicAcademicDiscourse,
      l10n.roadmapTopicProfessionalComms,
      l10n.roadmapTopicIdioms,
      l10n.roadmapTopicLiterature,
      l10n.roadmapTopicCriticalAnalysis,
      l10n.roadmapTopicNegotiations,
    ],
  ),
  (
    code: 'C2',
    name: l10n.roadmapLevelC2,
    topics: [
      l10n.roadmapTopicNativeFluency,
      l10n.roadmapTopicSpecializedVocab,
      l10n.roadmapTopicCulturalReferences,
      l10n.roadmapTopicRhetoric,
      l10n.roadmapTopicCreativeWriting,
      l10n.roadmapTopicPresentations,
    ],
  ),
];

/// One marker on the path.
class RoadmapStep {
  final String topic;
  final RoadStepStatus status;

  const RoadmapStep({required this.topic, required this.status});
}

/// Flattens the ladder into path steps: everything below the learner's level
/// is done, the first topic of their own level is where they are, and the rest
/// is still ahead.
List<RoadmapStep> buildRoadmapSteps(
  AppLocalizations l10n,
  String currentLevel,
) {
  final levels = _levels(l10n);
  final found = levels.indexWhere((l) => l.code == currentLevel);
  final current = found < 0 ? 0 : found;

  final steps = <RoadmapStep>[];
  for (var i = 0; i < levels.length; i++) {
    for (var t = 0; t < levels[i].topics.length; t++) {
      steps.add(
        RoadmapStep(
          topic: levels[i].topics[t],
          status: i < current
              ? RoadStepStatus.completed
              : (i == current && t == 0)
              ? RoadStepStatus.current
              : RoadStepStatus.locked,
        ),
      );
    }
  }
  return steps;
}

class RoadmapScreen extends ConsumerStatefulWidget {
  static const path = '/roadmap';

  const RoadmapScreen({super.key});

  @override
  ConsumerState<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends ConsumerState<RoadmapScreen> {
  final _scrollController = ScrollController();
  bool _hasRevealedCurrent = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Opens at the learner's position rather than at one end of a path that runs
  /// to roughly ten screens.
  void _revealCurrent(int index, double artworkHeight, double viewportHeight) {
    if (_hasRevealedCurrent || !_scrollController.hasClients) return;
    _hasRevealedCurrent = true;

    final maxExtent = _scrollController.position.maxScrollExtent;
    // The ladder begins at the foot of the artwork, so with nothing to reveal
    // the opening view is the bottom rather than the top.
    final target = index < 0
        ? maxExtent
        : RoadmapPath.slot(index).dy * artworkHeight - viewportHeight / 2;

    _scrollController.jumpTo(target.clamp(0.0, maxExtent));
  }

  @override
  Widget build(BuildContext context) {
    final level = ref.watch(currentUserProvider)?.level ?? 'A1';
    final steps = buildRoadmapSteps(AppLocalizations.of(context), level);
    final currentIndex = steps.indexWhere(
      (s) => s.status == RoadStepStatus.current,
    );

    return Scaffold(
      backgroundColor: AppColors.librarySurface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final artworkHeight = width * RoadmapPath.aspectRatio;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _revealCurrent(currentIndex, artworkHeight, constraints.maxHeight);
          });

          return Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                // The artwork has to meet the screen edge at both ends; iOS's
                // default bounce would drag the page background into view past
                // the shore and the sky.
                physics: const ClampingScrollPhysics(),
                child: SizedBox(
                  width: width,
                  height: artworkHeight,
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      // Shifted left to crop the artwork's transparent margin;
                      // node positions go through the same mapping.
                      Positioned(
                        left: -width * RoadmapPath.leftCrop,
                        top: 0,
                        width: width * RoadmapPath.drawWidthFactor,
                        height: artworkHeight,
                        child: Image.asset(
                          'assets/images/roadmap_background.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                      for (var i = 0; i < steps.length; i++)
                        _PositionedStep(
                          step: steps[i],
                          slot: RoadmapPath.slot(i),
                          canvasWidth: width,
                          canvasHeight: artworkHeight,
                        ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: CloseIconButton(
                      // White to carry over the artwork, which is green all the
                      // way up.
                      color: Colors.white,
                      onTap: () => context.pop(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PositionedStep extends StatelessWidget {
  static const _slotWidth = 116.0;

  final RoadmapStep step;
  final Offset slot;
  final double canvasWidth;
  final double canvasHeight;

  const _PositionedStep({
    required this.step,
    required this.slot,
    required this.canvasWidth,
    required this.canvasHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: RoadmapPath.toViewportX(slot.dx) * canvasWidth - _slotWidth / 2,
      // The marker's centre lands on the path; its label hangs below.
      top: slot.dy * canvasHeight - RoadStepNode.diameter / 2,
      width: _slotWidth,
      child: RoadStepNode(label: step.topic, status: step.status),
    );
  }
}
