import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/data/network/config.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/assignments/presentation/create_assignment_controller.dart';
import 'package:student/core/tutors/domain/entity/tutor_entity.dart';
import 'package:student/core/tutors/presentation/tutor_detail_controller.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_bottom_action_bar.dart';
import 'package:student/shared/widget/app_button.dart';
import 'package:student/shared/widget/app_empty_state.dart';
import 'package:student/shared/widget/back_icon_button.dart';
import 'package:student/shared/widget/section_title.dart';
import 'package:student/ui/tutors/book_tutor_sheet.dart';
import 'package:video_player/video_player.dart';

class TutorProfileScreen extends ConsumerStatefulWidget {
  static const path = '/tutor/:id';

  final String tutorId;

  const TutorProfileScreen({super.key, required this.tutorId});

  @override
  ConsumerState<TutorProfileScreen> createState() => _TutorProfileScreenState();
}

class _TutorProfileScreenState extends ConsumerState<TutorProfileScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  String? _loadedVideoUrl;

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initVideo(String rawUrl) async {
    if (_loadedVideoUrl == rawUrl) return;
    _loadedVideoUrl = rawUrl;

    final url = rawUrl.startsWith('http') ? rawUrl : '$baseCdnUrl$rawUrl';
    _chewieController?.dispose();
    _videoController?.dispose();

    final vc = VideoPlayerController.networkUrl(Uri.parse(url));
    await vc.initialize();
    if (!mounted) {
      vc.dispose();
      return;
    }
    setState(() {
      _videoController = vc;
      _chewieController = ChewieController(
        videoPlayerController: vc,
        autoPlay: false,
        looping: false,
        aspectRatio: 16 / 9,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tutorDetailControllerProvider(widget.tutorId));

    ref.listen<AsyncValue<Object?>>(createAssignmentControllerProvider, (
      prev,
      next,
    ) {
      if (prev?.isLoading != true) return;
      next.whenOrNull(
        data: (assignment) {
          if (assignment == null) return;
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).tutorBookingSent),
              ),
            );
        },
      );
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => SafeArea(
          child: Column(
            children: [
              _Header(title: AppLocalizations.of(context).tutorHeader),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Text(
                      e.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xff8a949b)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        data: (tutor) {
          if (tutor.introVideo != null) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _initVideo(tutor.introVideo!),
            );
          }

          return Column(
            children: [
              SafeArea(bottom: false, child: _Header(title: tutor.name)),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: _IntroVideo(controller: _chewieController),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: _Headline(tutor: tutor),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: SectionTitle(
                          title: AppLocalizations.of(context).tutorReviewsTitle,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Reviews aren't exposed by the API yet, so this is the
                      // only state the section can be in.
                      AppEmptyState(
                        imagePath: 'assets/images/no_comments_puppet.png',
                        title: AppLocalizations.of(context).tutorNoReviews,
                        backgroundColor: Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ),
              AppBottomActionBar(
                children: [
                  AppButton.filled(
                    label: AppLocalizations.of(context).tutorBook,
                    onTap: () => showBookTutorSheet(
                      context,
                      ref,
                      tutorId: widget.tutorId,
                      tutorName: tutor.name,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;

  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          const BackIconButton(),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroVideo extends StatelessWidget {
  final ChewieController? controller;

  const _IntroVideo({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: AspectRatio(
        aspectRatio: 2,
        child: controller != null
            ? Chewie(controller: controller!)
            : const _VideoPlaceholder(),
      ),
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.ink,
      child: Center(
        child: Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: AppColors.ink,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  final TutorEntity tutor;

  const _Headline({required this.tutor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          // The subject leads; the tutor's name sits under it with their photo.
          tutor.profession ?? tutor.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            _Avatar(url: tutor.avatarUrl, name: tutor.name, size: 38),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                tutor.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xff8a949b),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String name;
  final double size;

  const _Avatar({this.url, required this.name, required this.size});

  String get _initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  @override
  Widget build(BuildContext context) {
    final imageUrl = url == null
        ? null
        : url!.startsWith('http')
        ? url!
        : '$baseCdnUrl/$url';

    return ClipOval(
      child: SizedBox.square(
        dimension: size,
        child: imageUrl == null
            ? _fallback(context)
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallback(context),
              ),
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.primary,
      child: Center(
        child: Text(
          _initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.42,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
