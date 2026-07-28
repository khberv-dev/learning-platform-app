import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/shared/widget/app_option_chip.dart';
import 'package:student/shared/widget/app_progress_bar.dart';

Widget _host(Widget child, {double width = 360}) => MaterialApp(
  home: Scaffold(
    body: Center(
      child: SizedBox(width: width, child: child),
    ),
  ),
);

void main() {
  group('AppOptionChip', () {
    testWidgets('sizes to its content rather than filling the width', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          Align(
            alignment: Alignment.centerLeft,
            child: AppOptionChip(label: 'Hi', onTap: () {}),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(AppOptionChip)).width, lessThan(360));
    });

    testWidgets('a long label ellipsizes instead of overflowing', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          Align(
            alignment: Alignment.centerLeft,
            child: AppOptionChip(
              label: 'An extremely long survey option label that cannot fit',
              leading: const Text('💼'),
              onTap: () {},
            ),
          ),
          width: 200,
        ),
      );

      // Would throw a RenderFlex overflow if the label were unconstrained.
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(AppOptionChip)).width,
        lessThanOrEqualTo(200),
      );
    });

    testWidgets('selected fills with primary and turns the label white', (
      tester,
    ) async {
      Future<({Color? background, Color? label})> render({
        required bool isSelected,
      }) async {
        await tester.pumpWidget(
          _host(
            Align(
              alignment: Alignment.centerLeft,
              child: AppOptionChip(
                label: 'Career Growth',
                isSelected: isSelected,
                onTap: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Scoped to the chip — Material's own widgets also use these types.
        final decoration =
            tester
                    .widget<AnimatedContainer>(
                      find.descendant(
                        of: find.byType(AppOptionChip),
                        matching: find.byType(AnimatedContainer),
                      ),
                    )
                    .decoration
                as BoxDecoration;
        final style = tester
            .widget<AnimatedDefaultTextStyle>(
              find.descendant(
                of: find.byType(AppOptionChip),
                matching: find.byType(AnimatedDefaultTextStyle),
              ),
            )
            .style;
        return (background: decoration.color, label: style.color);
      }

      final scheme = ThemeData.light().colorScheme;

      final selected = await render(isSelected: true);
      expect(selected.background, scheme.primary);
      expect(selected.label, scheme.onPrimary);

      final unselected = await render(isSelected: false);
      expect(unselected.background, scheme.surface);
      expect(unselected.label, isNot(scheme.onPrimary));
    });

    testWidgets('reports taps and selected state', (tester) async {
      final semantics = tester.ensureSemantics();

      var taps = 0;
      await tester.pumpWidget(
        _host(
          Align(
            alignment: Alignment.centerLeft,
            child: AppOptionChip(
              label: 'Career Growth',
              isSelected: true,
              onTap: () => taps++,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AppOptionChip));
      expect(taps, 1);

      expect(
        tester.getSemantics(find.byType(AppOptionChip)),
        matchesSemantics(
          isSelected: true,
          hasSelectedState: true,
          isButton: true,
          hasTapAction: true,
          // Announced once — not duplicated by the inner Text or the emoji.
          label: 'Career Growth',
        ),
      );

      // Must be released inside the test body; addTearDown runs too late.
      semantics.dispose();
    });
  });

  group('AppProgressBar', () {
    testWidgets('clamps out-of-range values', (tester) async {
      await tester.pumpWidget(_host(const AppProgressBar(value: 1.8)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(_host(const AppProgressBar(value: -0.5)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('fill width tracks value', (tester) async {
      await tester.pumpWidget(_host(const AppProgressBar(value: 0.5)));
      await tester.pumpAndSettle();

      final half = tester
          .getSize(
            find.descendant(
              of: find.byType(AppProgressBar),
              matching: find.byType(DecoratedBox),
            ),
          )
          .width;

      await tester.pumpWidget(_host(const AppProgressBar(value: 1)));
      await tester.pumpAndSettle();

      final full = tester
          .getSize(
            find.descendant(
              of: find.byType(AppProgressBar),
              matching: find.byType(DecoratedBox),
            ),
          )
          .width;

      expect(full, greaterThan(half));
    });
  });
}
