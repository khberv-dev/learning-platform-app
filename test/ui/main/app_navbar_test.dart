import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/ui/main/widget/app_navbar.dart';

Widget _host({
  int current = 0,
  bool showChat = false,
  void Function(int)? onItemClick,
}) => MaterialApp(
  home: Scaffold(
    bottomNavigationBar: AppNavbar(
      current: current,
      showChat: showChat,
      onItemClick: onItemClick ?? (_) {},
    ),
    body: const SizedBox.expand(),
  ),
);

void main() {
  testWidgets('shows the four default destinations', (tester) async {
    await tester.pumpWidget(_host());

    expect(tester.takeException(), isNull);
    for (final label in ['Home', 'Course', 'Mentor', 'Profile']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Chat'), findsNothing);
  });

  testWidgets('showChat replaces Mentor at index 2', (tester) async {
    await tester.pumpWidget(_host(showChat: true));

    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Mentor'), findsNothing);

    // Order matters — AppScreen special-cases index 2.
    final labels = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .toList();
    expect(labels, ['Home', 'Course', 'Chat', 'Profile']);
  });

  testWidgets('reports the tapped index', (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(_host(onItemClick: taps.add));

    await tester.tap(find.text('Profile'));
    await tester.tap(find.text('Course'));
    await tester.pumpAndSettle();

    expect(taps, [3, 1]);
  });

  testWidgets('only the current destination is tinted', (tester) async {
    await tester.pumpWidget(_host(current: 1));

    final scheme = ThemeData.light().colorScheme;
    Color? colorOf(String label) =>
        tester.widget<Text>(find.text(label)).style?.color;

    expect(colorOf('Course'), scheme.primary);
    expect(colorOf('Home'), isNot(scheme.primary));
    expect(colorOf('Profile'), isNot(scheme.primary));
  });

  testWidgets('under extendBody the body is told to clear the whole bar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844) * 2;
    tester.view.devicePixelRatio = 2;
    tester.view.padding = const FakeViewPadding(bottom: 34 * 2);
    addTearDown(tester.view.reset);

    late double reported;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          extendBody: true,
          bottomNavigationBar: AppNavbar(current: 0, onItemClick: (_) {}),
          body: SafeArea(
            bottom: false,
            child: Builder(
              builder: (context) {
                reported = MediaQuery.paddingOf(context).bottom;
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Every tab adds this to its scroll padding, so content can be scrolled
    // clear of the pill. If it ever stopped matching, content would hide.
    expect(reported, tester.getSize(find.byType(AppNavbar)).height);
    expect(reported, greaterThan(AppNavbar.height));
  });

  testWidgets('floats clear of the screen edges', (tester) async {
    await tester.pumpWidget(_host());

    final bar = tester.getRect(find.byType(AppNavbar));
    final pill = tester.getRect(
      find.descendant(
        of: find.byType(AppNavbar),
        matching: find.byType(Container),
      ),
    );

    expect(pill.left, greaterThan(bar.left));
    expect(pill.right, lessThan(bar.right));
    expect(pill.bottom, lessThan(bar.bottom));
    expect(pill.height, AppNavbar.height);
  });
}
