import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/shared/widget/app_text_field.dart';

import '../../support/localized_app.dart';

Widget _host(Widget child) => localizedHome(
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(16), child: child),
  ),
);

bool _isObscured(WidgetTester tester) =>
    tester.widget<EditableText>(find.byType(EditableText)).obscureText;

void main() {
  testWidgets('renders its label above the field', (tester) async {
    await tester.pumpWidget(_host(const AppTextField(label: 'Full name')));

    expect(find.text('Full name'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Full name')).dy,
      lessThan(tester.getTopLeft(find.byType(TextFormField)).dy),
    );
  });

  testWidgets('password starts obscured and the toggle reveals it', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const AppTextField(label: 'Password', obscureText: true)),
    );

    expect(_isObscured(tester), isTrue);
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pumpAndSettle();

    expect(_isObscured(tester), isFalse);
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pumpAndSettle();
    expect(_isObscured(tester), isTrue);
  });

  testWidgets('non-password fields have no visibility toggle', (tester) async {
    await tester.pumpWidget(_host(const AppTextField(label: 'Full name')));

    expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
    expect(_isObscured(tester), isFalse);
  });

  testWidgets('participates in Form validation', (tester) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _host(
        Form(
          key: formKey,
          child: AppTextField(
            label: 'Full name',
            controller: controller,
            validator: (v) => (v ?? '').isEmpty ? 'Required' : null,
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'mxxdzzs');
    expect(formKey.currentState!.validate(), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsNothing);
  });

  testWidgets('shows a prefix when given one', (tester) async {
    await tester.pumpWidget(
      _host(const AppTextField(label: 'Phone number', prefixText: '+998 ')),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('+998 '), findsOneWidget);
  });
}
