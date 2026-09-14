import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:record/record.dart';
import 'package:student/core/assessments/data/assembly_ai_voice_agent.dart';
import 'package:student/core/assessments/data/repository/assessment_repository.dart';
import 'package:student/core/user/presentation/activity_recorder.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/ui/ai_assessment/widget/ai_avatar.dart';
import 'package:student/ui/ai_assessment/widget/listening_indicator.dart';
import 'package:student/ui/ai_assessment/widget/mic_button.dart';

enum _RecordState { idle, connecting, recording, processing, playingFeedback }

class AiAssessmentScreen extends ConsumerStatefulWidget {
  static const path = '/ai-assessment';

  const AiAssessmentScreen({super.key});

  @override
  ConsumerState<AiAssessmentScreen> createState() => _AiAssessmentScreenState();
}

class _AiAssessmentScreenState extends ConsumerState<AiAssessmentScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  late final AssemblyAiVoiceAgent _voiceAgent;
  _RecordState _state = _RecordState.idle;
  String? _apiKey;
  String? _feedbackText;
  bool _sessionStarted = false;

  @override
  void initState() {
    super.initState();
    _voiceAgent = AssemblyAiVoiceAgent(
      recorder: _recorder,
      onAgentText: (text) {
        if (mounted) setState(() => _feedbackText = text);
      },
      onStateChanged: (state) {
        if (!mounted) return;
        if (state == AssemblyAiAgentState.listening) {
          unawaited(ref.read(activityRecorderProvider).record());
        }
        setState(() {
          if (state == AssemblyAiAgentState.idle) _sessionStarted = false;
          if (state == AssemblyAiAgentState.listening) _sessionStarted = true;
          _state = switch (state) {
            AssemblyAiAgentState.connecting => _RecordState.connecting,
            AssemblyAiAgentState.listening => _RecordState.recording,
            AssemblyAiAgentState.thinking => _RecordState.processing,
            AssemblyAiAgentState.speaking => _RecordState.playingFeedback,
            AssemblyAiAgentState.idle => _RecordState.idle,
          };
        });
      },
      onError: (_) {
        if (mounted) {
          setState(() => _sessionStarted = false);
          _showError(AppLocalizations.of(context).aiUploadFailed);
        }
      },
    );
  }

  @override
  void dispose() {
    unawaited(_voiceAgent.dispose());
    super.dispose();
  }

  Future<void> _onMicTap() async {
    if (!_sessionStarted && _state == _RecordState.idle) {
      await _startRealtimeSession();
    }
  }

  Future<void> _startRealtimeSession() async {
    setState(() => _feedbackText = null);

    if (!await _recorder.hasPermission()) {
      if (mounted) _showError(AppLocalizations.of(context).aiMicDenied);
      return;
    }

    try {
      if (_apiKey == null) {
        setState(() => _state = _RecordState.connecting);
        _apiKey = await ref
            .read(assessmentRepositoryProvider)
            .getAssemblyAiKey();
      }
      await _voiceAgent.connect(_apiKey!);
      await _voiceAgent.startListening();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _apiKey = null;
        _state = _RecordState.idle;
      });
      _showError(AppLocalizations.of(context).aiUploadFailed);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = _state == _RecordState.recording;
    final isBusy = _state == _RecordState.connecting;

    final l10n = AppLocalizations.of(context);
    final cardText = _feedbackText ?? l10n.aiInitialPrompt;
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
                    active: _sessionStarted,
                    busy: isBusy,
                    onTap: _onMicTap,
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
          Expanded(
            child: Text(
              AppLocalizations.of(context).aiTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
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
