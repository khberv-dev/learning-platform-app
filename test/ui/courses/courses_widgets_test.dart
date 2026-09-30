import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/shared/widget/app_empty_state.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
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
