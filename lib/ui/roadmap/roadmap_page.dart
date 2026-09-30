import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/main/presentation/navbar_controller.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_balance_chip.dart';
import 'package:student/shared/widget/app_flat_pill_button.dart';
import 'package:student/ui/roadmap/roadmap_layout.dart';
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

/// The learner's level on the ladder: its number from 1 and its name. An
/// unknown code counts as the first level, as [buildRoadmapSteps] does.
({int number, String name}) roadmapLevel(
  AppLocalizations l10n,
  String currentLevel,
) {
  final levels = _levels(l10n);
  final found = levels.indexWhere((l) => l.code == currentLevel);
  final index = found < 0 ? 0 : found;
  return (number: index + 1, name: levels[index].name);
}

const _ink = Color(0xFF15141A);
const _brandGreen = Color(0xFF78C93C);
const _chipFill = Color(0xFFF1F1F5);
const _divider = Color(0xFFE5E7EA);

/// Tab index of Courses in the navbar, where Start sends the student.
const _coursesTabIndex = 1;

/// Room above the top pillar, so a tooltip there isn't cut off.
const _pathTopRoom = 56.0;

/// The navbar's Mission tab: the CEFR ladder as a zigzag of pillars climbing
/// from the bottom, the learner's level underneath, and a Start button.
class RoadmapPage extends ConsumerStatefulWidget {
  const RoadmapPage({super.key});

  @override
  ConsumerState<RoadmapPage> createState() => _RoadmapPageState();
}

class _RoadmapPageState extends ConsumerState<RoadmapPage> {
  final _scrollController = ScrollController();
  bool _hasRevealedCurrent = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Opens with the learner's pillar in the middle of the view rather than at
  /// the foot of a path several screens tall.
  void _revealCurrent(double distanceFromBottom, double viewportHeight) {
    if (_hasRevealedCurrent || !_scrollController.hasClients) return;
    _hasRevealedCurrent = true;
    final target = distanceFromBottom - viewportHeight / 2;
    _scrollController.jumpTo(
      target.clamp(0.0, _scrollController.position.maxScrollExtent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final levelCode = user?.level ?? 'A1';
    final steps = buildRoadmapSteps(l10n, levelCode);
    final level = roadmapLevel(l10n, levelCode);
    final currentIndex = steps.indexWhere(
      (s) => s.status == RoadStepStatus.current,
    );
    final insets = MediaQuery.paddingOf(context);

    return ColoredBox(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              insets.top + AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.navMission,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                AppBalanceChip(
                  imagePath: 'assets/images/ic_point.png',
                  value: user?.points ?? 0,
                  semanticsLabel: l10n.homeStatsScores,
                  background: _chipFill,
                ),
                const SizedBox(width: AppSpacing.sm),
                AppBalanceChip(
                  imagePath: 'assets/images/ic_coin.png',
                  value: user?.coins ?? 0,
                  semanticsLabel: l10n.homeStatsCoins,
                  background: _chipFill,
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final height =
                        RoadmapLayout.pathHeight(steps.length, width) +
                        _pathTopRoom;
                    if (currentIndex >= 0) {
                      final size = RoadmapLayout.pillarSize(width);
                      final origin = RoadmapLayout.pillarOrigin(
                        currentIndex,
                        steps.length,
                        width,
                      );
                      final fromBottom =
                          height - _pathTopRoom - origin.dy - size.height / 2;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          _revealCurrent(fromBottom, constraints.maxHeight);
                        }
                      });
                    }
                    return SingleChildScrollView(
                      key: const ValueKey('roadmap-path'),
                      controller: _scrollController,
                      // The path climbs from the bottom, so it opens there.
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.lg,
                      ),
                      child: SizedBox(
                        width: width,
                        height: height,
                        child: _Path(
                          steps: steps,
                          width: width,
                          startLabel: l10n.roadmapStart,
                        ),
                      ),
                    );
                  },
                ),
                // Pillars fade out under the header and above the level row
                // rather than being cut off by them.
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _Fade(fromTop: true),
                ),
                const Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _Fade(fromTop: false),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              insets.bottom + AppSpacing.md,
            ),
            child: Column(
              children: [
                _LevelRow(
                  badge: l10n.roadmapLevelNumber(level.number),
                  name: level.name,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppFlatPillButton(
                  label: l10n.roadmapStart,
                  background: _brandGreen,
                  foreground: Colors.white,
                  onTap: () =>
                      ref.read(navbarControllerProvider.notifier).state =
                          _coursesTabIndex,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Path extends StatelessWidget {
  final List<RoadmapStep> steps;
  final double width;
  final String startLabel;

  const _Path({
    required this.steps,
    required this.width,
    required this.startLabel,
  });

  @override
  Widget build(BuildContext context) {
    final size = RoadmapLayout.pillarSize(width);
    final count = steps.length;
    Offset originOf(int i) =>
        RoadmapLayout.pillarOrigin(i, count, width) +
        const Offset(0, _pathTopRoom);
    final currentIndex = steps.indexWhere(
      (s) => s.status == RoadStepStatus.current,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Top of the path first: each lower pillar stands in front of the
        // ones above it.
        for (var i = count - 1; i >= 0; i--)
          Positioned(
            left: originOf(i).dx,
            top: originOf(i).dy,
            child: RoadStepNode(
              key: ValueKey('roadmap-step-$i'),
              label: steps[i].topic,
              status: steps[i].status,
              size: size,
            ),
          ),
        if (currentIndex >= 0)
          Positioned(
            left: originOf(currentIndex).dx - size.width,
            width: size.width * 3,
            // The arrow's tip rests on the pillar's top face.
            top:
                originOf(currentIndex).dy +
                size.height * RoadmapLayout.capTop -
                _tooltipHeight,
            height: _tooltipHeight,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: RoadStepTooltip(text: startLabel),
            ),
          ),
      ],
    );
  }

  static const _tooltipHeight = 48.0;
}

class _Fade extends StatelessWidget {
  final bool fromTop;

  const _Fade({required this.fromTop});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: fromTop ? Alignment.topCenter : Alignment.bottomCenter,
            end: fromTop ? Alignment.bottomCenter : Alignment.topCenter,
            colors: const [Colors.white, Color(0x00FFFFFF)],
          ),
        ),
      ),
    );
  }
}

/// "Lv.1  Beginner" between two thin rules.
class _LevelRow extends StatelessWidget {
  final String badge;
  final String name;

  const _LevelRow({required this.badge, required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: _divider, thickness: 1)),
        const SizedBox(width: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _chipFill,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            badge,
            style: const TextStyle(
              color: _ink,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Flexible(
          flex: 3,
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _ink,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        const Expanded(child: Divider(color: _divider, thickness: 1)),
      ],
    );
  }
}
