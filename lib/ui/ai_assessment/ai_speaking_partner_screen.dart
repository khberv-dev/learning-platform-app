import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:record/record.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/assessments/data/assembly_ai_voice_agent.dart';
import 'package:student/core/assessments/data/repository/assessment_repository.dart';
import 'package:student/core/user/presentation/activity_recorder.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/shared/widget/app_flat_pill_button.dart';
import 'package:student/ui/ai_assessment/widget/ai_call_view.dart';
import 'package:student/utils/messenger.dart';

const _ink = Color(0xFF15141A);
const _muted = Color(0xFF6D737E);
const _caption = Color(0xFF8A8C9C);
const _tile = Color(0xFFF5F5F7);
const _green = Color(0xFF78C93C);

/// Talking to the AI speaking partner — a real-time voice conversation in
/// English, with no scoring.
///
/// Opens on an intro: what it is and a Start button. Start asks for the
/// microphone and connects; from then on the screen shows the conversation
/// live — the partner's state and its latest words — until the student ends
/// it.
class AiSpeakingPartnerScreen extends ConsumerStatefulWidget {
  static const path = '/ai-speaking-partner';

  const AiSpeakingPartnerScreen({super.key});

  @override
  ConsumerState<AiSpeakingPartnerScreen> createState() =>
      _AiSpeakingPartnerScreenState();
}

class _AiSpeakingPartnerScreenState
    extends ConsumerState<AiSpeakingPartnerScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  late final AssemblyAiVoiceAgent _voiceAgent;

  /// A conversation ends itself after this long.
  static const callLimit = Duration(minutes: 10);

  /// Null until the student taps Start, and again after a failed start.
  AssemblyAiAgentState? _agentState;
  String? _apiKey;
  bool _starting = false;
  bool _micMuted = false;
  bool _soundMuted = false;

  /// When the call connected. The clock starts then, not on tapping Start.
  DateTime? _connectedAt;
  Duration _elapsed = Duration.zero;
  Timer? _clock;

  bool get _inConversation => _agentState != null;

  @override
  void initState() {
    super.initState();
    _voiceAgent = AssemblyAiVoiceAgent(
      recorder: _recorder,
      onAgentText: (_) {},
      onStateChanged: (state) {
        if (!mounted) return;
        if (state == AssemblyAiAgentState.listening) {
          unawaited(ref.read(activityRecorderProvider).record());
        }
        // Idle after a session ran means it dropped — back to the intro.
        setState(() {
          _agentState = state == AssemblyAiAgentState.idle ? null : state;
          if (_agentState == null) {
            _stopClock();
          } else if (state != AssemblyAiAgentState.connecting) {
            _startClock();
          }
        });
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _agentState = null);
        showErrorMessage(context, AppLocalizations.of(context).aiUploadFailed);
      },
    );
  }

  @override
  void dispose() {
    _clock?.cancel();
    unawaited(_voiceAgent.dispose());
    super.dispose();
  }

  void _startClock() {
    if (_connectedAt != null) return;
    _connectedAt = DateTime.now();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _stopClock() {
    _clock?.cancel();
    _clock = null;
    _connectedAt = null;
    _elapsed = Duration.zero;
  }

  void _tick() {
    final start = _connectedAt;
    if (!mounted || start == null) return;
    final elapsed = DateTime.now().difference(start);
    if (elapsed >= callLimit) {
      _stopClock();
      showSuccessMessage(context, AppLocalizations.of(context).aiTimeUp);
      _end();
      return;
    }
    setState(() => _elapsed = elapsed);
  }

  void _toggleMic() {
    setState(() => _micMuted = !_micMuted);
    _voiceAgent.micMuted = _micMuted;
  }

  void _toggleSound() {
    setState(() => _soundMuted = !_soundMuted);
    _voiceAgent.outputMuted = _soundMuted;
  }

  Future<void> _start() async {
    if (_starting || _inConversation) return;
    final l10n = AppLocalizations.of(context);

    // A permission check that fails outright counts as a no.
    final allowed = await _recorder.hasPermission().catchError((_) => false);
    if (!allowed) {
      if (mounted) showErrorMessage(context, l10n.aiMicDenied);
      return;
    }

    setState(() {
      _starting = true;
      _agentState = AssemblyAiAgentState.connecting;
    });
    try {
      _apiKey ??= await ref
          .read(assessmentRepositoryProvider)
          .getAssemblyAiKey();
      await _voiceAgent.connect(_apiKey!);
      await _voiceAgent.startListening();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _apiKey = null;
        _agentState = null;
      });
      showErrorMessage(context, l10n.aiUploadFailed);
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  /// Ending is leaving: the session closes when the screen is disposed.
  void _end() => context.pop();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final insets = MediaQuery.paddingOf(context);

    if (_inConversation) {
      return AiCallView(
        state: _agentState!,
        elapsed: _elapsed,
        studentAvatar: ref.watch(currentUserProvider)?.avatar,
        micMuted: _micMuted,
        soundMuted: _soundMuted,
        limitMinutes: callLimit.inMinutes,
        onToggleMic: _toggleMic,
        onToggleSound: _toggleSound,
        onEnd: _end,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: insets.top),
          _Header(title: l10n.aiTitle),
          const Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _Intro(),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              insets.bottom + AppSpacing.md,
            ),
            child: Column(
              children: [
                AppFlatPillButton(
                  label: l10n.homeAiPartnerAction,
                  background: _green,
                  foreground: Colors.white,
                  onTap: _starting ? null : _start,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.aiMicNote,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _caption,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
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
        AppSpacing.sm,
      ),
      child: SizedBox(
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Material(
                color: const Color(0xFFF2F4F9),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.pop(),
                  child: const SizedBox.square(
                    dimension: 40,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 20,
                      color: _ink,
                    ),
                  ),
                ),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: _ink,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The orb, the pitch, and three tiles on what to expect.
class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: Image.asset(
            'assets/images/ai_speaking_partner.png',
            width: 112,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.aiIntroTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _ink,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.aiIntroBody,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _muted,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _FeatureTile(
                  icon: 'assets/icons/hourglass.svg',
                  text: l10n.aiFeatureEndAnytime,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _FeatureTile(
                  icon: 'assets/icons/mic.svg',
                  text: l10n.aiFeatureLiveVoice,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _FeatureTile(
          icon: 'assets/icons/chat_smile.svg',
          text: l10n.aiFeatureNoScore,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final String icon;
  final String text;

  const _FeatureTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: _tile,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(icon, width: 26),
          const SizedBox(height: AppSpacing.lg),
          Text(
            text,
            style: const TextStyle(
              color: _ink,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
