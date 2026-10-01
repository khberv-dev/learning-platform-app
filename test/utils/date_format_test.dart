import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/utils/date_format.dart';

import '../support/localized_app.dart';

Future<String> _format(WidgetTester tester, Locale locale) async {
  late String out;
  await tester.pumpWidget(
    localizedHome(
      locale: locale,
      home: Builder(
        builder: (context) {
          out = formatMediumDate(context, DateTime(2026, 10, 22));
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  // Russian keeps its parts together with no-break spaces; compare them as
  // plain ones.
  return out.replaceAll(RegExp(r'\s'), ' ');
}

void main() {
  testWidgets('formatMediumDate gives day, month and year, no weekday', (
    tester,
  ) async {
    expect(await _format(tester, const Locale('uz')), '22-okt, 2026');
    expect(await _format(tester, const Locale('ru')), '22 окт. 2026 г.');
    expect(await _format(tester, const Locale('en')), 'Oct 22, 2026');
  });
}
