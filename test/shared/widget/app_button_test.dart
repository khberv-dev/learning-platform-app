import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/shared/widget/app_button.dart';

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(
    body: Center(child: SizedBox(width: 340, child: child)),
  ),
);

void main() {
  testWidgets('filled renders and reports total height', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(
        AppButton.filled(
          label: 'Let\'s Get a Fresh Start',
          onTap: () => taps++,
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final size = tester.getSize(find.byType(AppButton));
    expect(size.height, AppButton.defaultHeight + AppButton.defaultDepth);
    expect(size.width, 340);

    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('press sinks the face by exactly depth', (tester) async {
    await tester.pumpWidget(
      _host(AppButton.filled(label: 'Press', onTap: () {})),
    );

    final faceFinder = find.byType(ClipRRect);
    final restingTop = tester.getTopLeft(faceFinder).dy;

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(AppButton)),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(faceFinder).dy - restingTop,
      AppButton.defaultDepth,
    );

    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(faceFinder).dy, restingTop);
  });

  testWidgets('outlined renders with border and no gloss', (tester) async {
    await tester.pumpWidget(
      _host(AppButton.outlined(label: 'Resume Journey', onTap: () {})),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Resume Journey'), findsOneWidget);
  });

  testWidgets('white renders and taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(AppButton.white(label: 'Skip', onTap: () => taps++)),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Skip'), findsOneWidget);

    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('white derives its edge from a custom face colour', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        AppButton.white(
          label: 'Tinted',
          color: const Color(0xffe0f2fe),
          onTap: () {},
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('loading shows spinner and blocks taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(
        AppButton.filled(label: 'Go', onTap: () => taps++, isLoading: true),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Go'), findsNothing);
    await tester.tap(find.byType(AppButton));
    expect(taps, 0);
  });

  testWidgets('null onTap disables', (tester) async {
    await tester.pumpWidget(
      _host(const AppButton.filled(label: 'Off', onTap: null)),
    );

    expect(tester.takeException(), isNull);
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();
  });

  testWidgets('icon variant lays out', (tester) async {
    await tester.pumpWidget(
      _host(
        AppButton.filled(
          label: 'Continue',
          icon: const Icon(Icons.play_arrow),
          onTap: () {},
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });

  testWidgets('shrinkWrap sizes to the label, default fills the parent', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppButton.filled(label: 'Go', onTap: () {}),
            AppButton.filled(label: 'Go', onTap: () {}, shrinkWrap: true),
          ],
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    final sizes = tester
        .widgetList<AppButton>(find.byType(AppButton))
        .toList()
        .asMap()
        .keys
        .map((i) => tester.getSize(find.byType(AppButton).at(i)))
        .toList();

    // A Column hands down loose width, so the default must still stretch.
    expect(sizes[0].width, 340);
    expect(sizes[1].width, lessThan(340));
    expect(sizes[0].height, sizes[1].height);
  });

  testWidgets('shrinkWrap still sinks on press', (tester) async {
    await tester.pumpWidget(
      _host(
        Align(
          alignment: Alignment.centerLeft,
          child: AppButton.filled(label: 'Go', onTap: () {}, shrinkWrap: true),
        ),
      ),
    );

    final face = find.byType(ClipRRect);
    final resting = tester.getTopLeft(face).dy;

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(AppButton)),
    );
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(face).dy - resting, AppButton.defaultDepth);

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('long label ellipsizes instead of overflowing', (tester) async {
    await tester.pumpWidget(
      _host(
        SizedBox(
          width: 120,
          child: AppButton.filled(
            label: 'An extremely long call to action',
            onTap: () {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
