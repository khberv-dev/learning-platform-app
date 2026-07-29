import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/shared/widget/app_button.dart';
import 'package:student/shared/widget/app_empty_state.dart';
import 'package:student/ui/courses/widget/courses_tab_bar.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

/// The variant an [AppButton] with this label was built with, inferred from
/// the gloss the filled style paints and the outlined style doesn't.
bool _isFilled(WidgetTester tester, String label) {
  final decoration =
      tester
              .widget<DecoratedBox>(
                find
                    .descendant(
                      of: find.ancestor(
                        of: find.text(label),
                        matching: find.byType(AppButton),
                      ),
                      matching: find.byType(DecoratedBox),
                    )
                    .last,
              )
              .decoration
          as BoxDecoration;
  return decoration.border == null;
}

void main() {
  group('CoursesTabBar', () {
    testWidgets('the active tab is outlined and the others filled', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          CoursesTabBar(
            labels: const ['Courses', 'Live sessions'],
            current: 0,
            onSelected: (_) {},
            actionLabel: 'Roadmap',
            onAction: () {},
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(_isFilled(tester, 'Courses'), isFalse);
      expect(_isFilled(tester, 'Live sessions'), isTrue);
      // The action pill navigates away, so it never reads as active.
      expect(_isFilled(tester, 'Roadmap'), isTrue);
    });

    testWidgets('reports the selected tab and the action separately', (
      tester,
    ) async {
      final selected = <int>[];
      var actioned = 0;

      await tester.pumpWidget(
        _host(
          CoursesTabBar(
            labels: const ['Courses', 'Live sessions'],
            current: 0,
            onSelected: selected.add,
            actionLabel: 'Roadmap',
            onAction: () => actioned++,
          ),
        ),
      );

      await tester.tap(find.text('Live sessions'));
      await tester.pumpAndSettle();
      expect(selected, [1]);
      expect(actioned, 0);

      await tester.tap(find.text('Roadmap'));
      await tester.pumpAndSettle();
      expect(selected, [1]);
      expect(actioned, 1);
    });

    testWidgets('scrolls rather than overflowing a narrow screen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(280, 400) * 2;
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _host(
          CoursesTabBar(
            labels: const ['Courses', 'Live sessions'],
            current: 0,
            onSelected: (_) {},
            actionLabel: 'Roadmap',
            onAction: () {},
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('AppEmptyState', () {
    testWidgets('shows artwork, title and subtitle', (tester) async {
      await tester.pumpWidget(
        _host(
          const AppEmptyState(
            imagePath: 'assets/images/no_recorded_sessions_puppet.png',
            title: 'No recorded sessions',
            subtitle: 'Recorded live sessions will appear here once available',
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('No recorded sessions'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('subtitle is optional', (tester) async {
      await tester.pumpWidget(
        _host(
          const AppEmptyState(
            imagePath: 'assets/images/no_recorded_sessions_puppet.png',
            title: 'Nothing here',
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(Text), findsOneWidget);
    });
  });
}
