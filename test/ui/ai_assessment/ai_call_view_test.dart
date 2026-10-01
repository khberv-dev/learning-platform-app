import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/core/assessments/data/assembly_ai_voice_agent.dart';
import 'package:student/ui/ai_assessment/widget/ai_call_view.dart';

import '../../support/localized_app.dart';

Future<void> _pump(
  WidgetTester tester, {
  AssemblyAiAgentState state = AssemblyAiAgentState.speaking,
  Duration elapsed = const Duration(minutes: 4, seconds: 21),
  bool micMuted = false,
  bool soundMuted = false,
  VoidCallback? onToggleMic,
  VoidCallback? onToggleSound,
  VoidCallback? onEnd,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    localizedHome(
      home: AiCallView(
        state: state,
        elapsed: elapsed,
        studentAvatar: null,
        micMuted: micMuted,
        soundMuted: soundMuted,
        limitMinutes: 10,
        onToggleMic: onToggleMic ?? () {},
        onToggleSound: onToggleSound ?? () {},
        onEnd: onEnd ?? () {},
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
}

/// The status line under a participant.
String _status(WidgetTester tester, String participantKey) {
  final texts = tester
      .widgetList<Text>(
        find.descendant(
          of: find.byKey(ValueKey(participantKey)),
          matching: find.byType(Text),
        ),
      )
      .toList();
  return texts.last.data!;
}

/// Whether the green blob is showing behind a participant.
bool _hasFloor(WidgetTester tester, String participantKey) =>
    tester
        .widget<AnimatedOpacity>(
          find.descendant(
            of: find.byKey(ValueKey(participantKey)),
            matching: find.byType(AnimatedOpacity),
          ),
        )
        .opacity ==
    1;

void main() {
  test('the clock reads minutes and seconds', () {
    expect(AiCallView.formatElapsed(Duration.zero), '00:00');
    expect(
      AiCallView.formatElapsed(const Duration(minutes: 4, seconds: 21)),
      '04:21',
    );
    expect(AiCallView.formatElapsed(const Duration(minutes: 10)), '10:00');
  });

  testWidgets('shows the clock, both sides and the auto-end note', (
    tester,
  ) async {
    await _pump(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('04:21'), findsOneWidget);
    expect(find.text('Conversation in progress'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    expect(find.text('AI partner'), findsNWidgets(2)); // title and name
    expect(
      find.text('The conversation ends automatically after 10 minutes'),
      findsOneWidget,
    );
  });

  testWidgets('while the AI speaks, it has the floor', (tester) async {
    await _pump(tester);

    expect(_hasFloor(tester, 'call-partner'), isTrue);
    expect(_hasFloor(tester, 'call-student'), isFalse);
    expect(_status(tester, 'call-partner'), 'Speaking');
    expect(_status(tester, 'call-student'), 'Listening');
  });

  testWidgets("while it listens, it's the student's turn", (tester) async {
    await _pump(tester, state: AssemblyAiAgentState.listening);

    expect(_hasFloor(tester, 'call-student'), isTrue);
    expect(_hasFloor(tester, 'call-partner'), isFalse);
    expect(_status(tester, 'call-student'), 'Your turn');
    expect(_status(tester, 'call-partner'), 'Listening');
  });

  testWidgets('thinking belongs to neither side', (tester) async {
    await _pump(tester, state: AssemblyAiAgentState.thinking);

    expect(_hasFloor(tester, 'call-student'), isFalse);
    expect(_hasFloor(tester, 'call-partner'), isFalse);
    expect(_status(tester, 'call-partner'), 'Thinking');
  });

  testWidgets('a muted mic says so and takes the floor away', (tester) async {
    await _pump(tester, state: AssemblyAiAgentState.listening, micMuted: true);

    expect(_status(tester, 'call-student'), 'Mic off');
    expect(_hasFloor(tester, 'call-student'), isFalse);
    expect(find.bySemanticsLabel('Unmute'), findsOneWidget);
  });

  testWidgets('connecting says so instead of "in progress"', (tester) async {
    await _pump(tester, state: AssemblyAiAgentState.connecting);

    expect(find.text('Connecting…'), findsNWidgets(2));
    expect(find.text('Conversation in progress'), findsNothing);
  });

  testWidgets('the three controls report their taps', (tester) async {
    final taps = <String>[];
    await _pump(
      tester,
      onToggleMic: () => taps.add('mic'),
      onToggleSound: () => taps.add('sound'),
      onEnd: () => taps.add('end'),
    );

    await tester.tap(find.byKey(const ValueKey('call-mic')));
    await tester.tap(find.byKey(const ValueKey('call-sound')));
    await tester.tap(find.byKey(const ValueKey('call-end')));
    // The back arrow ends the call too.
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));

    expect(taps, ['mic', 'sound', 'end', 'end']);
  });

  testWidgets('fits a small phone', (tester) async {
    await _pump(tester, size: const Size(320, 568));

    expect(tester.takeException(), isNull);
  });
}
