import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/shared/widget/close_icon_button.dart';
import 'package:student/ui/roadmap/roadmap_path.dart';
import 'package:student/ui/roadmap/widget/road_step_node.dart';

/// The CEFR ladder, in order. Each level's topics become steps on the path.
const _levels = <({String code, String name, List<String> topics})>[
  (
    code: 'A1',
    name: 'Beginner',
    topics: [
      'Greetings',
      'Numbers & Dates',
      'Colors & Objects',
      'Family',
      'Food & Drinks',
      'Daily Routines',
    ],
  ),
  (
    code: 'A2',
    name: 'Elementary',
    topics: [
      'Shopping',
      'Travel & Transport',
      'Weather & Seasons',
      'Home & Furniture',
      'Hobbies & Interests',
      'Health & Body',
    ],
  ),
  (
    code: 'B1',
    name: 'Intermediate',
    topics: [
      'Work & Careers',
      'Current Events',
      'Future Plans',
      'Past Experiences',
      'Opinions & Feelings',
      'Tourism & Culture',
    ],
  ),
  (
    code: 'B2',
    name: 'Upper-Intermediate',
    topics: [
      'Debates & Arguments',
      'Social Issues',
      'Business English',
      'Media & Entertainment',
      'Environment',
      'Academic Writing',
    ],
  ),
  (
    code: 'C1',
    name: 'Advanced',
    topics: [
      'Academic Discourse',
      'Professional Comms',
      'Idioms & Phrases',
      'Literature & Arts',
      'Critical Analysis',
      'Complex Negotiations',
    ],
  ),
  (
    code: 'C2',
    name: 'Proficiency',
    topics: [
      'Native-like Fluency',
      'Specialized Vocabulary',
      'Cultural References',
      'Advanced Rhetoric',
      'Creative Writing',
      'Expert Presentations',
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
List<RoadmapStep> buildRoadmapSteps(String currentLevel) {
  final found = _levels.indexWhere((l) => l.code == currentLevel);
  final current = found < 0 ? 0 : found;

  final steps = <RoadmapStep>[];
  for (var i = 0; i < _levels.length; i++) {
    for (var t = 0; t < _levels[i].topics.length; t++) {
      steps.add(
        RoadmapStep(
          topic: _levels[i].topics[t],
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
    final steps = buildRoadmapSteps(level);
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
