import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student/ui/courses/widget/lesson_video_controls.dart';
import 'package:video_player/video_player.dart';

import '../../support/localized_app.dart';

/// Drives [VideoPlayerValue] directly so no platform player is needed.
class _FakeVideoController extends VideoPlayerController {
  _FakeVideoController() : super.networkUrl(Uri.parse('https://example.com'));

  @override
  Future<void> initialize() async {
    value = value.copyWith(
      isInitialized: true,
      duration: const Duration(minutes: 2),
      position: const Duration(seconds: 30),
    );
  }

  @override
  Future<void> play() async => value = value.copyWith(isPlaying: true);

  @override
  Future<void> pause() async => value = value.copyWith(isPlaying: false);

  @override
  Future<void> seekTo(Duration position) async =>
      value = value.copyWith(position: position);

  @override
  Future<void> setLooping(bool looping) async {}

  @override
  Future<void> setVolume(double volume) async =>
      value = value.copyWith(volume: volume);

  @override
  Future<Duration?> get position async => value.position;
}

void main() {
  late _FakeVideoController video;
  late ChewieController chewie;

  setUp(() async {
    video = _FakeVideoController();
    await video.initialize();
    chewie = ChewieController(videoPlayerController: video);
  });

  Future<void> pumpControls(WidgetTester tester) => tester.pumpWidget(
    localizedHome(
      home: Scaffold(
        body: SizedBox(
          height: 200,
          child: ChewieControllerProvider(
            controller: chewie,
            child: const LessonVideoControls(),
          ),
        ),
      ),
    ),
  );

  double opacity(WidgetTester tester) => tester
      .widget<AnimatedOpacity>(
        find.byKey(const ValueKey('lesson-video-controls')),
      )
      .opacity;

  testWidgets('seeks 15 seconds back and forward, clamped to the video', (
    tester,
  ) async {
    await pumpControls(tester);

    await tester.tap(find.bySemanticsLabel('Forward 15 seconds'));
    await tester.pump();
    expect(video.value.position, const Duration(seconds: 45));

    await tester.tap(find.bySemanticsLabel('Back 15 seconds'));
    await tester.tap(find.bySemanticsLabel('Back 15 seconds'));
    await tester.tap(find.bySemanticsLabel('Back 15 seconds'));
    await tester.pump();
    expect(video.value.position, Duration.zero);
  });

  testWidgets('toggles play/pause and full screen', (tester) async {
    await pumpControls(tester);

    await tester.tap(find.bySemanticsLabel('Play'));
    await tester.pump();
    expect(video.value.isPlaying, isTrue);
    expect(find.bySemanticsLabel('Pause'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Pause'));
    await tester.pump();
    expect(video.value.isPlaying, isFalse);

    await tester.tap(find.bySemanticsLabel('Full screen'));
    await tester.pump();
    expect(chewie.isFullScreen, isTrue);
    expect(find.bySemanticsLabel('Exit full screen'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Exit full screen'));
    await tester.pump();
    expect(chewie.isFullScreen, isFalse);
  });

  testWidgets('hides after 5 seconds of idle playback, tap shows again', (
    tester,
  ) async {
    await pumpControls(tester);

    await tester.tap(find.bySemanticsLabel('Play'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    expect(opacity(tester), 1);

    // Interaction restarts the countdown.
    await tester.tap(find.bySemanticsLabel('Forward 15 seconds'));
    await tester.pump(const Duration(seconds: 4));
    expect(opacity(tester), 1);

    await tester.pump(const Duration(seconds: 1));
    expect(opacity(tester), 0);

    await tester.tapAt(tester.getCenter(find.byType(LessonVideoControls)));
    await tester.pump();
    expect(opacity(tester), 1);

    await tester.pump(const Duration(seconds: 5));
    expect(opacity(tester), 0);
  });

  testWidgets('stays visible while paused', (tester) async {
    await pumpControls(tester);

    await tester.pump(const Duration(seconds: 10));
    expect(opacity(tester), 1);

    await video.play();
    await tester.pump(const Duration(seconds: 3));
    await video.pause();
    await tester.pump(const Duration(seconds: 10));
    expect(opacity(tester), 1);
  });
}
