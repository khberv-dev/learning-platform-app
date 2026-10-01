import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:student/core/courses/domain/entity/lesson_detail_entity.dart';
import 'package:student/core/courses/domain/entity/lesson_entity.dart';
import 'package:student/core/courses/presentation/course_detail_controller.dart'
    show lessonDetailProvider, unitLessonsProvider;
import 'package:student/core/user/presentation/activity_recorder.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/shared/widget/app_flat_pill_button.dart';
import 'package:student/ui/courses/tasks_screen.dart';
import 'package:student/ui/courses/widget/lesson_materials_section.dart';
import 'package:student/ui/courses/widget/lesson_load_error.dart';
import 'package:student/ui/courses/widget/lesson_video_controls.dart';
import 'package:video_player/video_player.dart';

class LessonScreen extends ConsumerStatefulWidget {
  static const path = '/lesson';

  final String courseId;
  final String unitId;
  final int unitIndex;
  final int initialLessonIndex;

  const LessonScreen({
    super.key,
    required this.courseId,
    required this.unitId,
    required this.unitIndex,
    required this.initialLessonIndex,
  });

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  late int _lessonIndex;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  int _playerGeneration = 0;
  VideoPlayerController? _activityRecordedFor;

  /// The last lesson detail shown, kept on screen while the next one loads.
  LessonDetailEntity? _shownDetail;

  /// The lesson the player was last started for, so a rebuild doesn't
  /// schedule a second start before the first lands.
  String? _playerStartedFor;

  @override
  void initState() {
    super.initState();
    _lessonIndex = widget.initialLessonIndex;
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initPlayer(String url) async {
    final generation = ++_playerGeneration;
    _chewieController?.dispose();
    _videoController?.dispose();

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _videoController = controller;
    controller.addListener(() => _onVideoChanged(controller));

    await controller.initialize();

    if (!mounted || generation != _playerGeneration) {
      controller.dispose();
      return;
    }

    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: false,
        allowFullScreen: true,
        customControls: const LessonVideoControls(),
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        placeholder: const ColoredBox(color: Color(0xFF0F172A)),
        errorBuilder: (context, msg) => Center(
          child: Text(
            msg,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      );
    });
  }

  /// The first time a lesson's video starts playing counts as study activity.
  void _onVideoChanged(VideoPlayerController controller) {
    if (!mounted || !controller.value.isPlaying) return;
    if (_activityRecordedFor == controller) return;
    _activityRecordedFor = controller;
    unawaited(ref.read(activityRecorderProvider).record());
  }

  /// Opening the tasks counts as study activity, same as the first play.
  void _goToTasks(LessonDetailEntity lesson) {
    unawaited(ref.read(activityRecorderProvider).record());
    context.push(
      '${TasksScreen.path}'
      '?courseId=${widget.courseId}'
      '&unitId=${widget.unitId}'
      '&lessonId=${lesson.id}'
      '&lessonTitle=${Uri.encodeComponent(lesson.title)}',
    );
  }

  /// Switches to another lesson of the unit in place: the old player is
  /// dropped, and the new lesson's player starts once its detail loads.
  void _selectLesson(List<LessonEntity> lessons, int index) {
    if (_lessonIndex == index || lessons[index].isLocked) return;
    final oldChewieController = _chewieController;
    final oldVideoController = _videoController;
    _playerGeneration++;
    setState(() {
      _lessonIndex = index;
      _chewieController = null;
      _videoController = null;
      _playerStartedFor = null;
    });
    oldChewieController?.dispose();
    oldVideoController?.dispose();
  }

  Widget _errorScaffold(Object error) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(backgroundColor: Colors.white),
    body: LessonLoadError(error: error, courseId: widget.courseId),
  );

  @override
  Widget build(BuildContext context) {
    final lessonsState = ref.watch(
      unitLessonsProvider((courseId: widget.courseId, unitId: widget.unitId)),
    );

    return lessonsState.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
      error: (e, _) => _errorScaffold(e),
      data: (lessons) {
        if (lessons.isEmpty) {
          return Scaffold(
            body: Center(
              child: Text(AppLocalizations.of(context).unitNoLessonsTitle),
            ),
          );
        }

        final lessonIndex = _lessonIndex.clamp(0, lessons.length - 1);
        final lessonId = lessons[lessonIndex].id;
        final detailState = ref.watch(
          lessonDetailProvider((
            courseId: widget.courseId,
            unitId: widget.unitId,
            lessonId: lessonId,
          )),
        );

        final fresh = detailState.value;
        if (fresh != null) _shownDetail = fresh;
        // While another lesson's details load, the current one stays on
        // screen — no full-screen loader, no flash — and is swapped in place
        // once the new data arrives.
        final shown = fresh ?? _shownDetail;
        if (detailState.hasError && fresh == null) {
          return _errorScaffold(detailState.error!);
        }
        if (shown == null) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F172A),
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }
        final switching = fresh == null;
        final lesson = shown;

        // Start the player once this lesson's own data is in — never
        // for the previous lesson still on screen while switching.
        final mediaUrl = lesson.mediaUrl?.trim();
        if (!switching &&
            mediaUrl != null &&
            mediaUrl.isNotEmpty &&
            _videoController == null &&
            _chewieController == null &&
            _playerStartedFor != lesson.id) {
          _playerStartedFor = lesson.id;
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _initPlayer(mediaUrl),
          );
        }

        final l10n = AppLocalizations.of(context);
        final insets = MediaQuery.paddingOf(context);
        final description = lesson.description;

        // Light status-bar icons, over the dark video.
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: _background,
            body: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // Full width, running up under the status bar, with
                      // the back button floating over its corner.
                      Stack(
                        children: [
                          // From the very top: the status bar sits over the
                          // video rather than over a band of its own.
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: _VideoArea(
                              hasMedia: mediaUrl != null && mediaUrl.isNotEmpty,
                              loading: switching,
                              chewieController: _chewieController,
                            ),
                          ),
                          Positioned(
                            top: insets.top + AppSpacing.sm,
                            left: AppSpacing.md,
                            child: const _BackButton(),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.lg,
                          AppSpacing.md,
                          AppSpacing.lg,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              lesson.title,
                              style: const TextStyle(
                                color: _ink,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (description != null &&
                                description.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                description,
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                ),
                              ),
                            ],
                            if (lessons.length > 1) ...[
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                l10n.lessonUnitLessons,
                                style: const TextStyle(
                                  color: _ink,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _UnitLessons(
                                lessons: lessons,
                                currentIndex: lessonIndex,
                                // Fresher than the list's figure for the
                                // lesson on screen.
                                currentProgress:
                                    lesson.taskProgression.progressPercent,
                                onSelect: (i) => _selectLesson(lessons, i),
                              ),
                            ],
                            LessonMaterialsSection(materials: lesson.materials),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    insets.bottom + AppSpacing.md,
                  ),
                  child: AppFlatPillButton(
                    label: l10n.lessonGoToTest,
                    background: _green,
                    foreground: Colors.white,
                    trailingIcon: const Icon(Icons.arrow_forward_rounded),
                    onTap: () => _goToTasks(lesson),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

const _background = Color(0xFFEFEEF4);
const _ink = Color(0xFF15141A);
const _muted = Color(0xFF6D737E);
const _green = Color(0xFF78C93C);

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).maybePop(),
        child: const SizedBox.square(
          dimension: 40,
          child: Icon(Icons.arrow_back_rounded, size: 20, color: Colors.black),
        ),
      ),
    );
  }
}

/// The unit's lessons as white rows: the lesson's number, its title and
/// length, and on the right a green tick once passed (80%+) or a padlock
/// while locked. The lesson on screen has a glowing green border; tapping
/// another switches to it.
class _UnitLessons extends StatelessWidget {
  final List<LessonEntity> lessons;
  final int currentIndex;
  final int currentProgress;
  final ValueChanged<int> onSelect;

  const _UnitLessons({
    required this.lessons,
    required this.currentIndex,
    required this.currentProgress,
    required this.onSelect,
  });

  static String format(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < lessons.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          _LessonRow(
            key: ValueKey('unit-lesson-$i'),
            number: i + 1,
            lesson: lessons[i],
            current: i == currentIndex,
            passed: i == currentIndex
                ? currentProgress >= LessonEntity.passPercent
                : lessons[i].isPassed,
            onTap: lessons[i].isLocked ? null : () => onSelect(i),
          ),
        ],
      ],
    );
  }
}

class _LessonRow extends StatelessWidget {
  final int number;
  final LessonEntity lesson;
  final bool current;
  final bool passed;
  final VoidCallback? onTap;

  const _LessonRow({
    super.key,
    required this.number,
    required this.lesson,
    required this.current,
    required this.passed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final duration = lesson.duration;
    final radius = BorderRadius.circular(18);
    final Widget? status = lesson.isLocked
        ? SvgPicture.asset(
            'assets/icons/lock.svg',
            key: const ValueKey('lesson-locked'),
            width: 22,
          )
        : passed
        ? Container(
            key: const ValueKey('lesson-passed'),
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF4CC56A),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 16,
              color: Colors.white,
            ),
          )
        : null;

    return Semantics(
      selected: current,
      button: onTap != null,
      child: AnimatedContainer(
        key: current ? const ValueKey('lesson-current') : null,
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: current ? _green : Colors.transparent,
            width: 2,
          ),
          boxShadow: current
              ? [
                  BoxShadow(
                    color: _green.withValues(alpha: 0.35),
                    blurRadius: 14,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.white,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '$number',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: current ? _green : _muted,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      lesson.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: lesson.isLocked ? _muted : _ink,
                        fontSize: 16,
                        fontWeight: current ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (duration != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      _UnitLessons.format(duration),
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                  if (status != null) ...[
                    const SizedBox(width: AppSpacing.md),
                    status,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Video area ────────────────────────────────────────────────────────────────

class _VideoArea extends StatelessWidget {
  final bool hasMedia;

  /// Another lesson is loading: show a spinner instead of this one's video.
  final bool loading;
  final ChewieController? chewieController;

  const _VideoArea({
    required this.hasMedia,
    this.loading = false,
    this.chewieController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('lesson-media-area'),
      width: double.infinity,
      color: const Color(0xFF0F172A),
      child: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : !hasMedia
          ? Center(
              child: Text(
                AppLocalizations.of(context).lessonNoContent,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : chewieController != null
          ? Chewie(controller: chewieController!)
          : const Center(child: _PlayPlaceholder()),
    );
  }
}

class _PlayPlaceholder extends StatelessWidget {
  const _PlayPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.play_arrow_rounded,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}
