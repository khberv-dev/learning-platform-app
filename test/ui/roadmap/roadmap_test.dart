import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/ui/roadmap/roadmap_path.dart';
import 'package:student/ui/roadmap/roadmap_screen.dart';
import 'package:student/ui/roadmap/widget/road_step_node.dart';

void main() {
  group('RoadmapPath', () {
    test('holds enough slots for every step the screen builds', () {
      expect(
        RoadmapPath.capacity,
        greaterThanOrEqualTo(buildRoadmapSteps('A1').length),
      );
    });

    test('gives the opening stub a single step, then pairs the rest', () {
      // Step 0 has the stub to itself.
      expect(RoadmapPath.slot(0).dy, isNot(RoadmapPath.slot(1).dy));
      // Everything above it goes two to a run.
      expect(RoadmapPath.slot(1).dy, RoadmapPath.slot(2).dy);
      expect(RoadmapPath.slot(3).dy, RoadmapPath.slot(4).dy);
      expect(RoadmapPath.slot(2).dy, isNot(RoadmapPath.slot(3).dy));
    });

    test('starts where the road starts and climbs', () {
      expect(RoadmapPath.slot(0).dy, RoadmapPath.runCentresY.last);
      // Later steps sit higher up, i.e. at a smaller y.
      expect(RoadmapPath.slot(1).dy, lessThan(RoadmapPath.slot(0).dy));
      expect(RoadmapPath.slot(3).dy, lessThan(RoadmapPath.slot(1).dy));
      expect(
        RoadmapPath.slot(RoadmapPath.capacity - 1).dy,
        lessThan(RoadmapPath.slot(0).dy),
      );
    });

    test('zigzags, reversing direction each run', () {
      // The run above the stub is walked left to right, so its first step is
      // the nearer one.
      expect(RoadmapPath.slot(1).dx, lessThan(RoadmapPath.slot(2).dx));
      // The run above that comes back the other way.
      expect(RoadmapPath.slot(3).dx, greaterThan(RoadmapPath.slot(4).dx));
    });

    test('every slot stays inside the road, allowing for the left crop', () {
      // The traced runs span x 0.19..0.82 of the raw artwork.
      final left = RoadmapPath.toViewportX(0.19);
      final right = RoadmapPath.toViewportX(0.82);
      for (var i = 0; i < RoadmapPath.capacity; i++) {
        final x = RoadmapPath.toViewportX(RoadmapPath.slot(i).dx);
        expect(x, greaterThan(left), reason: 'slot $i ran off the left');
        expect(x, lessThan(right), reason: 'slot $i ran off the right');
      }
    });

    test('clamps rather than throwing past the last run', () {
      // Steps climb, so running off the end lands on the topmost run.
      expect(
        RoadmapPath.slot(RoadmapPath.capacity + 50).dy,
        RoadmapPath.runCentresY.first,
      );
    });
  });

  group('buildRoadmapSteps', () {
    test('marks exactly one step as current', () {
      for (final level in ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']) {
        final steps = buildRoadmapSteps(level);
        expect(
          steps.where((s) => s.status == RoadStepStatus.current).length,
          1,
          reason: 'level $level',
        );
      }
    });

    test('completes every topic below the learner\'s level', () {
      final steps = buildRoadmapSteps('B1');
      // A1 and A2 are six topics each.
      expect(
        steps.take(12).every((s) => s.status == RoadStepStatus.completed),
        isTrue,
      );
      expect(steps[12].status, RoadStepStatus.current);
      expect(steps[13].status, RoadStepStatus.locked);
    });

    test('an unknown level falls back to the start', () {
      final steps = buildRoadmapSteps('Z9');
      expect(steps.first.status, RoadStepStatus.current);
      expect(steps.any((s) => s.status == RoadStepStatus.completed), isFalse);
    });

    test('the top level leaves nothing locked before it', () {
      final steps = buildRoadmapSteps('C2');
      expect(steps.last.status, RoadStepStatus.locked);
      expect(
        steps.take(30).every((s) => s.status == RoadStepStatus.completed),
        isTrue,
      );
    });
  });

  group('RoadStepNode', () {
    Future<void> pump(WidgetTester tester, RoadStepStatus status) =>
        tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 116,
                  child: RoadStepNode(label: 'Greetings', status: status),
                ),
              ),
            ),
          ),
        );

    String assetOf(WidgetTester tester) =>
        ((tester.widget<Image>(find.byType(Image)).image) as AssetImage)
            .assetName;

    testWidgets('current uses the current artwork', (tester) async {
      await pump(tester, RoadStepStatus.current);
      expect(assetOf(tester), 'assets/images/road_item_current.png');
    });

    testWidgets('completed uses the completed artwork', (tester) async {
      await pump(tester, RoadStepStatus.completed);
      expect(assetOf(tester), 'assets/images/road_item_complete.png');
    });

    testWidgets('locked reuses the completed artwork, drained of colour', (
      tester,
    ) async {
      await pump(tester, RoadStepStatus.locked);

      // No locked artwork ships, so it is derived from the completed badge.
      expect(assetOf(tester), 'assets/images/road_item_complete.png');
      expect(find.byType(ColorFiltered), findsOneWidget);
      expect(find.byType(Opacity), findsOneWidget);
    });

    testWidgets('labels the step for screen readers', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, RoadStepStatus.current);

      expect(
        tester.getSemantics(find.byType(RoadStepNode)),
        matchesSemantics(label: 'Greetings, current'),
      );

      handle.dispose();
    });
  });
}
