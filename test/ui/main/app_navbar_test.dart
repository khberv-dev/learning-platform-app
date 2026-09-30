import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/ui/main/widget/app_navbar.dart';

import '../../support/localized_app.dart';

Widget _host({int current = 0, void Function(int)? onItemClick}) =>
    localizedHome(
      home: Scaffold(
        bottomNavigationBar: AppNavbar(
          current: current,
          onItemClick: onItemClick ?? (_) {},
        ),
        body: const SizedBox.expand(),
      ),
    );

void main() {
  testWidgets('shows the five destinations', (tester) async {
    await tester.pumpWidget(_host());

    expect(tester.takeException(), isNull);
    for (final label in ['Home', 'Courses', 'Mission', 'Mentor', 'Profile']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('reports the tapped index', (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(_host(onItemClick: taps.add));

    await tester.tap(find.text('Profile'));
    await tester.tap(find.text('Courses'));
    await tester.pumpAndSettle();

    expect(taps, [4, 1]);
  });

  testWidgets('the green pill sits under the current destination', (
    tester,
  ) async {
    await tester.pumpWidget(_host(current: 1));
    await tester.pumpAndSettle();

    final pill = tester.getRect(find.byKey(const ValueKey('navbar-selection')));
    final course = tester.getCenter(find.text('Courses'));
    expect(pill.contains(course), isTrue);
    expect(pill.contains(tester.getCenter(find.text('Home'))), isFalse);
  });

  testWidgets('the pill slides to a newly selected destination', (
    tester,
  ) async {
    await tester.pumpWidget(_host(current: 0));
    await tester.pumpAndSettle();
    await tester.pumpWidget(_host(current: 4));
    await tester.pump(const Duration(milliseconds: 100));

    // Mid-slide: somewhere between the two.
    final mid = tester.getRect(find.byKey(const ValueKey('navbar-selection')));
    expect(mid.contains(tester.getCenter(find.text('Home'))), isFalse);
    expect(mid.contains(tester.getCenter(find.text('Profile'))), isFalse);

    await tester.pumpAndSettle();
    final end = tester.getRect(find.byKey(const ValueKey('navbar-selection')));
    expect(end.contains(tester.getCenter(find.text('Profile'))), isTrue);
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
      localizedHome(
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
      find
          .descendant(
            of: find.byType(AppNavbar),
            matching: find.byType(Container),
          )
          .first,
    );

    expect(pill.left, greaterThan(bar.left));
    expect(pill.right, lessThan(bar.right));
    expect(pill.bottom, lessThan(bar.bottom));
    expect(pill.height, AppNavbar.height);
  });
}
