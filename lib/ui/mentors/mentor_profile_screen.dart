import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/data/network/config.dart';
import 'package:student/app/theme/app_colors.dart';
import 'package:student/app/theme/app_radius.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/assignments/presentation/create_assignment_controller.dart';
import 'package:student/core/mentors/domain/entity/mentor_entity.dart';
import 'package:student/core/mentors/domain/usecase/use_leave_feedback.dart';
import 'package:student/core/mentors/presentation/mentor_detail_controller.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_bottom_action_bar.dart';
import 'package:student/shared/widget/app_button.dart';
import 'package:student/shared/widget/app_empty_state.dart';
import 'package:student/shared/widget/back_icon_button.dart';
import 'package:student/shared/widget/section_title.dart';
import 'package:student/ui/mentors/book_mentor_sheet.dart';
import 'package:student/utils/messenger.dart';
import 'package:video_player/video_player.dart';

class MentorProfileScreen extends ConsumerStatefulWidget {
  static const path = '/mentor/:id';

  final String mentorId;

  const MentorProfileScreen({super.key, required this.mentorId});

  @override
  ConsumerState<MentorProfileScreen> createState() =>
      _MentorProfileScreenState();
}

class _MentorProfileScreenState extends ConsumerState<MentorProfileScreen> {
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
    final state = ref.watch(mentorDetailControllerProvider(widget.mentorId));

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
                content: Text(AppLocalizations.of(context).mentorBookingSent),
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
              _Header(title: AppLocalizations.of(context).mentorHeader),
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
        data: (mentor) {
          if (mentor.introVideo != null) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _initVideo(mentor.introVideo!),
            );
          }

          return Column(
            children: [
              SafeArea(bottom: false, child: _Header(title: mentor.name)),
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
                        child: _Headline(mentor: mentor),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: SectionTitle(
                          title: AppLocalizations.of(
                            context,
                          ).mentorReviewsTitle,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // The API only accepts new feedback — it doesn't expose
                      // a way to list existing reviews, so this empty state
                      // is the only state the section can be in.
                      AppEmptyState(
                        imagePath: 'assets/images/no_comments_puppet.png',
                        title: AppLocalizations.of(context).mentorNoReviews,
                        backgroundColor: Colors.transparent,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: AppButton.outlined(
                          label: AppLocalizations.of(context).mentorLeaveReview,
                          onTap: () => _showFeedbackSheet(context, mentor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppBottomActionBar(
                children: [
                  AppButton.filled(
                    label: AppLocalizations.of(context).mentorBook,
                    onTap: () => showBookMentorSheet(
                      context,
                      ref,
                      mentorId: widget.mentorId,
                      mentorName: mentor.name,
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

  Future<void> _showFeedbackSheet(BuildContext context, MentorEntity mentor) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetContext) => _FeedbackSheet(
        mentorId: mentor.id,
        onSubmit: (rate, text) async {
          await ref
              .read(useLeaveFeedbackProvider)
              .call(mentorId: mentor.id, text: text, rate: rate);
        },
      ),
    );
  }
}

class _FeedbackSheet extends StatefulWidget {
  final String mentorId;
  final Future<void> Function(int rate, String text) onSubmit;

  const _FeedbackSheet({required this.mentorId, required this.onSubmit});

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  final _textController = TextEditingController();
  int _rate = 0;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_rate == 0) {
      setState(() => _error = l10n.mentorReviewRatingRequired);
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.onSubmit(_rate, _textController.text.trim());
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l10n.mentorReviewSent)));
    } catch (e) {
      if (mounted) setState(() => _error = apiErrorMessage(context, e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.mentorLeaveReview,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  onPressed: () => setState(() {
                    _rate = i;
                    _error = null;
                  }),
                  icon: Icon(
                    i <= _rate
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: i <= _rate
                        ? AppColors.ratingFill
                        : AppColors.ratingEmpty,
                    size: 32,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _textController,
            maxLines: 4,
            minLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: l10n.mentorReviewHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _error!,
              style: const TextStyle(color: Color(0xffef4444), fontSize: 13),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton.filled(
            label: l10n.mentorReviewSubmit,
            isLoading: _submitting,
            onTap: _submitting ? null : _submit,
          ),
        ],
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
  final MentorEntity mentor;

  const _Headline({required this.mentor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          // The subject leads; the mentor's name sits under it with their photo.
          mentor.profession ?? mentor.name,
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
            _Avatar(url: mentor.avatarUrl, name: mentor.name, size: 38),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                mentor.name,
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
