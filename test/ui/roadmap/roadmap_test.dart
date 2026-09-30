import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/core/main/presentation/navbar_controller.dart';
import 'package:student/core/user/domain/entity/user_entity.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/l10n/app_localizations_en.dart';
import 'package:student/ui/roadmap/roadmap_layout.dart';
import 'package:student/ui/roadmap/roadmap_page.dart';
import 'package:student/ui/roadmap/widget/road_step_node.dart';

import '../../support/localized_app.dart';

/// The step builder takes its wording from the locale; the assertions here
/// are about structure, so any locale does — English keeps them readable.
final _l10n = AppLocalizationsEn();

UserEntity _user(String level) => UserEntity(
  id: 'u1',
  firstName: 'Azima',
  phoneNumber: '998901234567',
  points: 1240,
  coins: 320,
  level: level,
);

void main() {
  group('RoadmapLayout', () {
    test('zigzags across four columns and back', () {
      expect(
        [for (var i = 0; i < 13; i++) RoadmapLayout.column(i)],
        [0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1, 0],
      );
    });

    test('each step sits one row above the last', () {
      const width = 390.0;
      final a = RoadmapLayout.pillarOrigin(0, 10, width);
      final b = RoadmapLayout.pillarOrigin(1, 10, width);
      expect(a.dy - b.dy, closeTo(width * RoadmapLayout.rowHeight, 0.001));
    });

    test(
      'the first step ends at the foot of the path, the last at its top',
      () {
        const width = 390.0;
        const count = 36;
        final size = RoadmapLayout.pillarSize(width);
        final first = RoadmapLayout.pillarOrigin(0, count, width);
        final last = RoadmapLayout.pillarOrigin(count - 1, count, width);
        expect(
          first.dy + size.height,
          closeTo(RoadmapLayout.pathHeight(count, width), 0.001),
        );
        expect(last.dy, closeTo(0, 0.001));
      },
    );

    test('every pillar stays within the page width', () {
      const width = 320.0;
      final size = RoadmapLayout.pillarSize(width);
      for (var i = 0; i < 6; i++) {
        final x = RoadmapLayout.pillarOrigin(i, 6, width).dx;
        expect(x, greaterThanOrEqualTo(0), reason: 'step $i');
        expect(x + size.width, lessThanOrEqualTo(width), reason: 'step $i');
      }
    });
  });

  group('buildRoadmapSteps', () {
    test('marks exactly one step as current', () {
      for (final level in ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']) {
        final steps = buildRoadmapSteps(_l10n, level);
        expect(
          steps.where((s) => s.status == RoadStepStatus.current).length,
          1,
          reason: 'level $level',
        );
      }
    });

    test('completes every topic below the learner\'s level', () {
      final steps = buildRoadmapSteps(_l10n, 'B1');
      // A1 and A2 are six topics each.
      expect(
        steps.take(12).every((s) => s.status == RoadStepStatus.completed),
        isTrue,
      );
      expect(steps[12].status, RoadStepStatus.current);
      expect(steps[13].status, RoadStepStatus.locked);
    });

    test('an unknown level falls back to the start', () {
      final steps = buildRoadmapSteps(_l10n, 'Z9');
      expect(steps.first.status, RoadStepStatus.current);
      expect(steps.any((s) => s.status == RoadStepStatus.completed), isFalse);
    });

    test('the top level leaves nothing locked before it', () {
      final steps = buildRoadmapSteps(_l10n, 'C2');
      expect(steps.last.status, RoadStepStatus.locked);
      expect(
        steps.take(30).every((s) => s.status == RoadStepStatus.completed),
        isTrue,
      );
    });
  });

  group('roadmapLevel', () {
    test('numbers the levels from 1', () {
      expect(roadmapLevel(_l10n, 'A1'), (number: 1, name: 'Beginner'));
      expect(roadmapLevel(_l10n, 'B1'), (number: 3, name: 'Intermediate'));
      expect(roadmapLevel(_l10n, 'Z9'), (number: 1, name: 'Beginner'));
    });
  });

  test('reached pillars are green, the rest locked', () {
    expect(
      RoadStepNode.imageFor(RoadStepStatus.completed),
      'assets/images/roadmap_step_done.png',
    );
    expect(
      RoadStepNode.imageFor(RoadStepStatus.current),
      'assets/images/roadmap_step_done.png',
    );
    expect(
      RoadStepNode.imageFor(RoadStepStatus.locked),
      'assets/images/roadmap_step_locked.png',
    );
  });

  group('RoadmapPage', () {
    Future<ProviderContainer> pump(
      WidgetTester tester, {
      String level = 'A1',
    }) async {
      tester.view.physicalSize = const Size(390, 844) * 2;
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      final container = ProviderContainer(
        overrides: [currentUserProvider.overrideWith((ref) => _user(level))],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: localizedHome(home: const Scaffold(body: RoadmapPage())),
        ),
      );
      await tester.pumpAndSettle();
      return container;
    }

    testWidgets('shows the title, balances and the learner\'s level', (
      tester,
    ) async {
      await pump(tester, level: 'A2');

      expect(tester.takeException(), isNull);
      expect(find.text('Mission'), findsOneWidget);
      expect(find.text('1 240'), findsOneWidget);
      expect(find.text('320'), findsOneWidget);
      expect(find.text('Lv.2'), findsOneWidget);
      expect(find.text('Elementary'), findsOneWidget);
    });

    testWidgets('the tooltip points at the current pillar', (tester) async {
      await pump(tester);

      final pillar = tester.getRect(
        find.byKey(const ValueKey('roadmap-step-0')),
      );
      final tooltip = tester.getRect(find.byType(RoadStepTooltip));
      expect(tooltip.center.dx, closeTo(pillar.center.dx, 1));
      expect(tooltip.bottom, lessThan(pillar.center.dy));
    });

    testWidgets('opens scrolled to the current pillar', (tester) async {
      await pump(tester, level: 'C1');

      // C1's first topic is step 24, far above the foot of the path.
      final pillar = tester.getRect(
        find.byKey(const ValueKey('roadmap-step-24')),
      );
      final path = tester.getRect(find.byKey(const ValueKey('roadmap-path')));
      expect(path.contains(pillar.center), isTrue);
    });

    testWidgets('Start sends the student to Courses', (tester) async {
      final container = await pump(tester);

      await tester.tap(find.widgetWithText(GestureDetector, 'Start').last);
      await tester.pump();

      expect(container.read(navbarControllerProvider), 1);
    });
  });
}
