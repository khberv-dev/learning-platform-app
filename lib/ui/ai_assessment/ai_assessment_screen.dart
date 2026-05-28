import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:student/app/data/network/config.dart';
import 'package:student/core/assessments/domain/usecase/use_create_conversation.dart';
import 'package:student/core/assessments/domain/usecase/use_send_assessment_turn.dart';
import 'package:student/ui/ai_assessment/widget/ai_avatar.dart';
import 'package:student/ui/ai_assessment/widget/listening_indicator.dart';
import 'package:student/ui/ai_assessment/widget/mic_button.dart';

const _initialPrompt = 'Try to speak anything you want!';

enum _RecordState { idle, recording, uploading, playingFeedback }

class AiAssessmentScreen extends ConsumerStatefulWidget {
  static const path = '/ai-assessment';

  const AiAssessmentScreen({super.key});

  @override
  ConsumerState<AiAssessmentScreen> createState() => _AiAssessmentScreenState();
}

class _AiAssessmentScreenState extends ConsumerState<AiAssessmentScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  _RecordState _state = _RecordState.idle;
  String? _conversationId;
  String? _feedbackText;
  String? _error;

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _onMicTap() async {
    if (_state == _RecordState.idle) {
      await _startRecording();
    } else if (_state == _RecordState.recording) {
      await _stopAndSubmit();
    }
  }

  Future<void> _startRecording() async {
    setState(() {
      _error = null;
      _feedbackText = null;
    });

    if (!await _recorder.hasPermission()) {
      setState(() => _error = 'Microphone permission denied');
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/assessment_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );

    if (!mounted) return;
    setState(() => _state = _RecordState.recording);
  }

  Future<void> _stopAndSubmit() async {
    setState(() => _state = _RecordState.uploading);

    final path = await _recorder.stop();
    if (path == null) {
      if (!mounted) return;
      setState(() {
        _state = _RecordState.idle;
        _error = 'Recording failed';
      });
      return;
    }

    try {
      final conversationId = _conversationId ??=
          (await ref.read(useCreateConversationProvider).call()).id;

      final turn = await ref
          .read(useSendAssessmentTurnProvider)
          .call(conversationId: conversationId, audioFilePath: path);

      if (!mounted) return;
      setState(() => _feedbackText = turn.assistantMessage.text);

      final audio = turn.assistantMessage.audioPath;
      if (audio != null && audio.isNotEmpty) {
        await _playFeedback(audio);
        if (!mounted) return;
      }
      setState(() => _state = _RecordState.idle);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _state = _RecordState.idle;
        _error = 'Upload failed. Tap to try again.';
      });
    }
  }

  Future<void> _playFeedback(String relativeUrl) async {
    setState(() => _state = _RecordState.playingFeedback);
    final fullUrl = relativeUrl.startsWith('http')
        ? relativeUrl
        : '$baseCdnUrl$relativeUrl';
    try {
      await _player.play(UrlSource(fullUrl));
      await _player.onPlayerComplete.first;
    } catch (_) {
      // Ignore playback errors and return to idle.
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = _state == _RecordState.recording;
    final isUploading = _state == _RecordState.uploading;
    final isPlayingFeedback = _state == _RecordState.playingFeedback;
    final isBusy = isUploading || isPlayingFeedback;

    final cardText = _feedbackText ?? _initialPrompt;
    final hint =
        _error ??
        (isUploading
            ? 'Uploading…'
            : isPlayingFeedback
            ? 'Playing feedback…'
            : isRecording
            ? 'Tap to stop'
            : 'Tap to speak');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 390,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(left: 0, top: 0, right: 0, child: _Header()),
                Positioned(left: 155, top: 106, child: const AiAvatar()),
                Positioned(
                  left: 32,
                  top: 222,
                  child: _QuestionCard(text: cardText),
                ),
                if (isRecording)
                  const Positioned(
                    left: 0,
                    right: 0,
                    top: 406,
                    child: ListeningIndicator(),
                  ),
                Positioned(
                  left: 143,
                  top: 576,
                  child: MicButton(
                    active: isRecording,
                    busy: isBusy,
                    onTap: _onMicTap,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 696,
                  child: Text(
                    hint,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _error != null
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF9CA3AF),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 18,
                color: Color(0xFF374151),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'AI Assessment',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 36, height: 36),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String text;

  const _QuestionCard({required this.text});

  // Card sits at top: 222; mic wrap at top: 576. Cap at 320 to leave a comfy
  // gap above the record button.
  static const _width = 326.0;
  static const _minHeight = 140.0;
  static const _maxHeight = 320.0;
  static const _hPad = 16.0;
  static const _vPad = 18.0;

  static const _textStyle = TextStyle(
    color: Color(0xFF111827),
    fontSize: 17,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = DefaultTextStyle.of(context).style.merge(_textStyle);

    final painter = TextPainter(
      text: TextSpan(text: text, style: effectiveStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: _width - _hPad * 2);

    final desiredHeight = painter.size.height + _vPad * 2;
    final height = desiredHeight.clamp(_minHeight, _maxHeight);
    final overflows = desiredHeight > _maxHeight;

    Widget content = SingleChildScrollView(
      physics: overflows
          ? const ClampingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: _vPad),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: height - _vPad * 2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: _hPad),
          child: Center(
            child: Text(text, textAlign: TextAlign.center, style: _textStyle),
          ),
        ),
      ),
    );

    if (overflows) {
      content = ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black,
            Colors.black,
            Colors.transparent,
          ],
          stops: [0.0, 0.12, 0.88, 1.0],
        ).createShader(bounds),
        blendMode: BlendMode.dstIn,
        child: content,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: _width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: content,
    );
  }
}
