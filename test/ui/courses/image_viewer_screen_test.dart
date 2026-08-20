import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/ui/courses/image_viewer_screen.dart';

import '../../support/localized_app.dart';

Widget _host() => ProviderScope(
  child: localizedHome(
    home: const ImageViewerScreen(
      url: 'https://example.test/handout.png',
      title: 'Handout',
    ),
  ),
);

/// The viewer's live transform. Image.network fails under the test HTTP client,
/// so the error state renders — the zoom behaviour under test sits on the
/// InteractiveViewer above it either way.
Matrix4 _transform(WidgetTester tester) => tester
    .widget<InteractiveViewer>(find.byType(InteractiveViewer))
    .transformationController!
    .value;

/// Target opacity of the zoom readout. It is always built and faded in and out
/// rather than added to the tree, so presence proves nothing.
double _readoutOpacity(WidgetTester tester) =>
    tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;

void main() {
  testWidgets('starts fitted, with the zoom readout hidden', (tester) async {
    await tester.pumpWidget(_host());
    await tester.pump();

    expect(_transform(tester).getMaxScaleOnAxis(), 1.0);
    expect(_readoutOpacity(tester), 0);
  });

  testWidgets('double-tap zooms in and pins the tapped point', (tester) async {
    await tester.pumpWidget(_host());
    await tester.pump();

    final centre = tester.getCenter(find.byType(InteractiveViewer));
    final target = centre + const Offset(40, 60);

    // The viewer's own coordinate space, which is what the transform is
    // expressed in.
    final local = target - tester.getTopLeft(find.byType(InteractiveViewer));

    await tester.tapAt(target);
    await tester.pump(kDoubleTapMinTime);
    await tester.tapAt(target);
    await tester.pumpAndSettle();

    final transform = _transform(tester);
    expect(transform.getMaxScaleOnAxis(), closeTo(2.5, 0.001));

    // The point under the finger must land back where it started: the scene
    // point that maps to `local` should be `local` itself.
    final mapped = MatrixUtils.transformPoint(transform, local);
    expect(mapped.dx, closeTo(local.dx, 0.5));
    expect(mapped.dy, closeTo(local.dy, 0.5));
  });

  testWidgets('a second double-tap resets to fitted', (tester) async {
    await tester.pumpWidget(_host());
    await tester.pump();

    final centre = tester.getCenter(find.byType(InteractiveViewer));

    for (var i = 0; i < 2; i++) {
      await tester.tapAt(centre);
      await tester.pump(kDoubleTapMinTime);
      await tester.tapAt(centre);
      await tester.pumpAndSettle();
    }

    expect(_transform(tester).getMaxScaleOnAxis(), closeTo(1.0, 0.001));
  });

  testWidgets('zoom readout appears once zoomed', (tester) async {
    await tester.pumpWidget(_host());
    await tester.pump();

    final centre = tester.getCenter(find.byType(InteractiveViewer));
    await tester.tapAt(centre);
    await tester.pump(kDoubleTapMinTime);
    await tester.tapAt(centre);
    await tester.pumpAndSettle();

    expect(find.text('2.5×'), findsOneWidget);
    expect(_readoutOpacity(tester), 1);
  });
}
