import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/data/network/config.dart';
import 'package:student/core/assignments/presentation/create_assignment_controller.dart';
import 'package:student/core/tutors/domain/entity/tutor_entity.dart';
import 'package:student/core/tutors/presentation/tutor_detail_controller.dart';
import 'package:student/utils/messenger.dart';
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
              const SnackBar(content: Text('Booking request sent')),
            );
        },
        error: (e, _) => showErrorMessage(
          context,
          CreateAssignmentController.errorMessage(e),
        ),
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            e.toString(),
            style: const TextStyle(color: Color(0xFF6B7280)),
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
              _AppBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _VideoSection(chewieController: _chewieController),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InfoCard(tutor: tutor),
                            const SizedBox(height: 16),
                            _ReviewsSection(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _BottomBar(tutorId: widget.tutorId),
            ],
          );
        },
      ),
    );
  }
}

// ── App Bar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 8,
        16,
        8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Color(0xFF111827),
              ),
            ),
          ),
          const Text(
            'Tutor',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 40, height: 40),
        ],
      ),
    );
  }
}

// ── Video Section ─────────────────────────────────────────────────────────────

class _VideoSection extends StatelessWidget {
  final ChewieController? chewieController;

  const _VideoSection({required this.chewieController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: chewieController != null
          ? Chewie(controller: chewieController!)
          : Stack(
              fit: StackFit.expand,
              children: [
                Container(color: const Color(0xFF111827)),
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Color(0xFF111827),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Info Card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final TutorEntity tutor;

  const _InfoCard({required this.tutor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _Avatar(url: tutor.avatarUrl, size: 64, radius: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutor.name,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (tutor.profession != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        tutor.profession!,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Stat(
                  value: tutor.rating.toStringAsFixed(1),
                  label: '★ Rating',
                ),
                Container(width: 1, height: 32, color: const Color(0xFFE5E7EB)),
                _Stat(value: tutor.feedbackCount.toString(), label: 'Reviews'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
        ),
      ],
    );
  }
}

// ── Reviews Section ───────────────────────────────────────────────────────────

class _ReviewsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Student Reviews',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text(
              'No reviews yet',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Bottom Bar ────────────────────────────────────────────────────────────────

class _BottomBar extends ConsumerWidget {
  final String tutorId;

  const _BottomBar({required this.tutorId});

  Future<void> _onBook(BuildContext context, WidgetRef ref) async {
    final months = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _DurationSheet(),
    );
    if (months == null) return;
    if (!context.mounted) return;

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month + months, now.day);

    await ref
        .read(createAssignmentControllerProvider.notifier)
        .book(teacherId: tutorId, startDate: start, endDate: end);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(createAssignmentControllerProvider).isLoading;
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottom),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: Material(
          color: const Color(0xFF18C96A),
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            onTap: isLoading ? null : () => _onBook(context, ref),
            borderRadius: BorderRadius.circular(28),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
                      'Book Tutor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Duration Sheet ────────────────────────────────────────────────────────────

class _DurationSheet extends StatelessWidget {
  const _DurationSheet();

  static const _options = [
    (months: 1, label: '1 Month'),
    (months: 3, label: '3 Months'),
    (months: 6, label: '6 Months'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select duration',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          for (final option in _options) ...[
            _DurationOption(
              label: option.label,
              onTap: () => Navigator.of(context).pop(option.months),
            ),
            if (option != _options.last) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _DurationOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DurationOption({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String? url;
  final double size;
  final double radius;

  const _Avatar({this.url, required this.size, required this.radius});

  @override
  Widget build(BuildContext context) {
    final imageUrl = url == null
        ? null
        : url!.startsWith('http')
        ? url!
        : '$baseCdnUrl/$url';

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: imageUrl != null
          ? Image.network(
              imageUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => _placeholder(size),
            )
          : _placeholder(size),
    );
  }

  Widget _placeholder(double size) => Container(
    width: size,
    height: size,
    color: const Color(0xFFE5E7EB),
    child: const Icon(Icons.person_outline, color: Color(0xFF9CA3AF), size: 32),
  );
}
