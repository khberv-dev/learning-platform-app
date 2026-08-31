import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/data/network/config.dart';
import 'package:student/core/courses/domain/entity/lesson_entity.dart';
import 'package:student/core/courses/domain/entity/task_result_entity.dart';
import 'package:student/core/courses/domain/entity/unit_entity.dart';
import 'package:student/core/courses/presentation/course_detail_controller.dart'
    show courseDetailControllerProvider;
import 'package:student/core/courses/presentation/tasks_controller.dart'
    show lessonTaskResultsProvider;
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_button.dart';
import 'package:student/ui/courses/tasks_screen.dart';
import 'package:student/ui/courses/widget/lesson_materials_section.dart';
import 'package:video_player/video_player.dart';

class LessonScreen extends ConsumerStatefulWidget {
  static const path = '/lesson';

  final String courseId;
  final int unitIndex;
  final int initialLessonIndex;

  const LessonScreen({
    super.key,
    required this.courseId,
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

  Future<void> _initPlayer(String mediaUrl) async {
    final generation = ++_playerGeneration;
    _chewieController?.dispose();
    _videoController?.dispose();

    final url = mediaUrl.startsWith('http')
        ? mediaUrl
        : '$baseCdnUrl/$mediaUrl';

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _videoController = controller;

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
        customControls: const _LessonVideoControls(),
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

  void _selectLesson(UnitEntity unit, int index) {
    if (_lessonIndex == index) return;
    if (unit.lessons[index].isLocked) return;
    final oldChewieController = _chewieController;
    final oldVideoController = _videoController;
    _playerGeneration++;
    setState(() {
      _lessonIndex = index;
      _chewieController = null;
      _videoController = null;
    });
    oldChewieController?.dispose();
    oldVideoController?.dispose();

    final lesson = unit.lessons[index];
    final mediaUrl = lesson.mediaUrl?.trim();
    if (mediaUrl != null && mediaUrl.isNotEmpty) _initPlayer(mediaUrl);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(courseDetailControllerProvider(widget.courseId));

    return state.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (course) {
        final unit = course.units[widget.unitIndex];
        final lesson = unit.lessons.isNotEmpty
            ? unit.lessons[_lessonIndex.clamp(0, unit.lessons.length - 1)]
            : null;

        // Init player on first build if not yet initialised
        final mediaUrl = lesson?.mediaUrl?.trim();
        if (mediaUrl != null &&
            mediaUrl.isNotEmpty &&
            _videoController == null &&
            _chewieController == null) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _initPlayer(mediaUrl),
          );
        }

        final unitNumber = (widget.unitIndex + 1).toString().padLeft(2, '0');

        final taskResults = lesson != null
            ? ref.watch(lessonTaskResultsProvider(lesson.id)).value ?? []
            : <TaskResultEntity>[];

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: SafeArea(
            child: Column(
              children: [
                _TopBar(
                  unitNumber: unitNumber,
                  lessonNumber: (_lessonIndex + 1).toString().padLeft(2, '0'),
                ),
                _VideoArea(
                  hasMedia: mediaUrl != null && mediaUrl.isNotEmpty,
                  chewieController: _chewieController,
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _LessonInfo(
                        lesson: lesson,
                        unitNumber: unitNumber,
                        lessonIndex: _lessonIndex,
                        totalLessons: unit.lessons.length,
                        courseId: widget.courseId,
                        unitId: unit.id,
                        taskResults: taskResults,
                      ),
                      _UnitLessonList(
                        unit: unit,
                        currentIndex: _lessonIndex,
                        onTap: (i) => _selectLesson(unit, i),
                      ),
                      const SizedBox(height: 24),
                    ],
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

// ── Top bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String unitNumber;
  final String lessonNumber;

  const _TopBar({required this.unitNumber, required this.lessonNumber});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 18,
                color: Color(0xFF111827),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            AppLocalizations.of(
              context,
            ).lessonUnitLesson(unitNumber, lessonNumber),
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Video area ────────────────────────────────────────────────────────────────

class _VideoArea extends StatelessWidget {
  final bool hasMedia;
  final ChewieController? chewieController;

  const _VideoArea({required this.hasMedia, this.chewieController});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('lesson-media-area'),
      height: 200,
      width: double.infinity,
      color: const Color(0xFF0F172A),
      child: !hasMedia
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

class _LessonVideoControls extends StatefulWidget {
  const _LessonVideoControls();

  @override
  State<_LessonVideoControls> createState() => _LessonVideoControlsState();
}

class _LessonVideoControlsState extends State<_LessonVideoControls> {
  ChewieController? _chewieController;
  VideoPlayerController? _videoController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final chewieController = ChewieController.of(context);
    if (_chewieController == chewieController) return;

    _chewieController?.removeListener(_refresh);
    _videoController?.removeListener(_refresh);
    _chewieController = chewieController;
    _videoController = chewieController.videoPlayerController;
    _chewieController!.addListener(_refresh);
    _videoController!.addListener(_refresh);
  }

  @override
  void dispose() {
    _chewieController?.removeListener(_refresh);
    _videoController?.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _togglePlayback() async {
    final controller = _videoController!;
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      if (controller.value.position >= controller.value.duration) {
        await controller.seekTo(Duration.zero);
      }
      await controller.play();
    }
  }

  Future<void> _toggleMute() async {
    final controller = _videoController!;
    await controller.setVolume(controller.value.volume == 0 ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    final video = _videoController;
    final chewie = _chewieController;
    if (video == null || chewie == null) return const SizedBox.shrink();

    return Stack(
      children: [
        Center(
          child: _VideoControlButton(
            icon: video.value.isPlaying
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            onPressed: _togglePlayback,
            size: 56,
            iconSize: 32,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
            child: Row(
              children: [
                _VideoControlButton(
                  icon: video.value.volume == 0
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  onPressed: _toggleMute,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: VideoProgressIndicator(
                    video,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: Colors.white,
                      bufferedColor: Colors.white54,
                      backgroundColor: Colors.black38,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _VideoControlButton(
                  icon: chewie.isFullScreen
                      ? Icons.fullscreen_exit_rounded
                      : Icons.fullscreen_rounded,
                  onPressed: chewie.isFullScreen
                      ? chewie.exitFullScreen
                      : chewie.enterFullScreen,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VideoControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;

  const _VideoControlButton({
    required this.icon,
    required this.onPressed,
    this.size = 38,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        icon: Icon(icon, size: iconSize),
      ),
    );
  }
}

// ── Lesson info ───────────────────────────────────────────────────────────────

class _LessonInfo extends StatelessWidget {
  final LessonEntity? lesson;
  final String unitNumber;
  final int lessonIndex;
  final int totalLessons;
  final String courseId;
  final String unitId;
  final List<TaskResultEntity> taskResults;

  const _LessonInfo({
    this.lesson,
    required this.unitNumber,
    required this.lessonIndex,
    required this.totalLessons,
    required this.courseId,
    required this.unitId,
    required this.taskResults,
  });

  @override
  Widget build(BuildContext context) {
    final lessonNumber = (lessonIndex + 1).toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.menu_book_outlined,
                  color: Color(0xFF18C96A),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.of(
                    context,
                  ).lessonUnitLessonOf(unitNumber, lessonNumber, totalLessons),
                  style: const TextStyle(
                    color: Color(0xFF18C96A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            lesson?.title ?? '',
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (lesson?.description != null &&
              lesson!.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              lesson!.description!,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
          if (lesson != null) ...[
            const SizedBox(height: 16),
            _TasksSection(
              lesson: lesson!,
              courseId: courseId,
              unitId: unitId,
              taskResults: taskResults,
            ),
            LessonMaterialsSection(lessonId: lesson!.id),
          ],
        ],
      ),
    );
  }
}

// ── Tasks section ─────────────────────────────────────────────────────────────

class _TasksSection extends StatelessWidget {
  final LessonEntity lesson;
  final String courseId;
  final String unitId;
  final List<TaskResultEntity> taskResults;

  const _TasksSection({
    required this.lesson,
    required this.courseId,
    required this.unitId,
    required this.taskResults,
  });

  void _goToTasks(BuildContext context) {
    context.push(
      '${TasksScreen.path}'
      '?courseId=$courseId'
      '&unitId=$unitId'
      '&lessonId=${lesson.id}'
      '&lessonTitle=${Uri.encodeComponent(lesson.title)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final answered = taskResults.where((r) => r.isAnswered).length;

    if (answered == 0) {
      return SizedBox(
        width: double.infinity,
        child: AppButton.filled(
          label: AppLocalizations.of(context).lessonViewTasks,
          icon: const Icon(Icons.task_alt_rounded),
          fontSize: 15,
          height: 48,
          onTap: () => _goToTasks(context),
        ),
      );
    }

    final total = taskResults.length;
    final correct = taskResults
        .where((r) => r.submission?.isCorrect ?? false)
        .length;
    final pct = total > 0 ? (correct / total * 100).round() : 0;
    final allDone = answered == total;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: pct >= 70
                      ? const Color(0xFFF0FDF4)
                      : const Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  allDone ? Icons.task_alt_rounded : Icons.pending_outlined,
                  color: pct >= 70
                      ? const Color(0xFF18C96A)
                      : const Color(0xFFEF4444),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      allDone
                          ? AppLocalizations.of(context).lessonTasksCompleted
                          : AppLocalizations.of(context).lessonTasksInProgress,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(
                        context,
                      ).lessonScore(correct, total, pct),
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? correct / total : 0,
              minHeight: 5,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation(
                pct >= 70 ? const Color(0xFF18C96A) : const Color(0xFFEF4444),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: AppButton.outlined(
              label: AppLocalizations.of(context).lessonRetake,
              color: const Color(0xFF18C96A),
              fontSize: 13,
              height: 42,
              depth: 4,
              onTap: () => _goToTasks(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Unit lesson list ──────────────────────────────────────────────────────────

class _UnitLessonList extends StatelessWidget {
  final UnitEntity unit;
  final int currentIndex;
  final void Function(int) onTap;

  const _UnitLessonList({
    required this.unit,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).lessonInThisUnit,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                AppLocalizations.of(
                  context,
                ).courseLessonCount(unit.lessonsCount),
                style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...List.generate(unit.lessons.length, (i) {
            final isActive = i == currentIndex;
            final number = (i + 1).toString().padLeft(2, '0');
            final lesson = unit.lessons[i];
            return GestureDetector(
              onTap: lesson.isLocked ? null : () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: _LessonListItem(
                number: number,
                title: lesson.title,
                isActive: isActive,
                isLocked: lesson.isLocked,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LessonListItem extends StatelessWidget {
  final String number;
  final String title;
  final bool isActive;
  final bool isLocked;

  const _LessonListItem({
    required this.number,
    required this.title,
    required this.isActive,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: isActive
          ? const BoxDecoration(
              border: Border(
                left: BorderSide(color: Color(0xFF18C96A), width: 3),
              ),
            )
          : null,
      child: Padding(
        padding: EdgeInsets.only(left: isActive ? 10 : 0),
        child: Row(
          children: [
            Text(
              number,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF18C96A)
                    : isLocked
                    ? const Color(0xFFD1D5DB)
                    : const Color(0xFF9CA3AF),
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isActive
                      ? const Color(0xFF111827)
                      : isLocked
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              isLocked ? Icons.lock_rounded : Icons.play_circle_outline,
              color: isLocked
                  ? const Color(0xFF9CA3AF)
                  : isActive
                  ? const Color(0xFF18C96A)
                  : const Color(0xFFD1D5DB),
              size: isLocked ? 18 : (isActive ? 20 : 16),
            ),
          ],
        ),
      ),
    );
  }
}
