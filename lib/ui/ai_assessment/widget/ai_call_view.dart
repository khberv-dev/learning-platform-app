import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/assessments/data/assembly_ai_voice_agent.dart';
import 'package:student/l10n/app_localizations.dart';
import 'package:student/utils/lib.dart';

const callBackground = Color(0xFF11151B);
const _control = Color(0xFF2A2E35);
const _muted = Color(0xFF8A8F98);
const _speakingGreen = Color(0xFF78C93C);
const _danger = Color(0xFFEF5B5B);

/// Who is doing what, as the two status lines under the avatars show it.
enum CallSpeaker { student, partner, none }

/// The dark in-call screen: the elapsed time, the student and the AI side by
/// side with a green blob behind whoever has the floor, and the call
/// controls — mute, hang up, and silence the AI's voice.
class AiCallView extends StatelessWidget {
  final AssemblyAiAgentState state;
  final Duration elapsed;
  final String? studentAvatar;
  final bool micMuted;
  final bool soundMuted;
  final int limitMinutes;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleSound;
  final VoidCallback onEnd;

  const AiCallView({
    super.key,
    required this.state,
    required this.elapsed,
    required this.studentAvatar,
    required this.micMuted,
    required this.soundMuted,
    required this.limitMinutes,
    required this.onToggleMic,
    required this.onToggleSound,
    required this.onEnd,
  });

  /// The AI holds the floor while it speaks; the student while the AI is
  /// listening to them. Thinking and connecting belong to neither.
  CallSpeaker get speaker => switch (state) {
    AssemblyAiAgentState.speaking => CallSpeaker.partner,
    AssemblyAiAgentState.listening =>
      micMuted ? CallSpeaker.none : CallSpeaker.student,
    _ => CallSpeaker.none,
  };

  static String formatElapsed(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final insets = MediaQuery.paddingOf(context);
    final connecting = state == AssemblyAiAgentState.connecting;

    final studentStatus = micMuted
        ? l10n.aiMicOff
        : state == AssemblyAiAgentState.listening
        ? l10n.aiYourTurn
        : l10n.aiStatusListening;
    final partnerStatus = switch (state) {
      AssemblyAiAgentState.connecting => l10n.aiConnecting,
      AssemblyAiAgentState.thinking => l10n.aiStatusThinking,
      AssemblyAiAgentState.speaking => l10n.aiStatusSpeaking,
      _ => l10n.aiStatusListening,
    };

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: callBackground,
        body: Padding(
          padding: EdgeInsets.only(top: insets.top, bottom: insets.bottom),
          child: Column(
            children: [
              _Header(title: l10n.aiTitle, onBack: onEnd),
              // Centred in the space left between header and controls, and
              // scaled down rather than overflowing on a short screen.
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formatElapsed(elapsed),
                            key: const ValueKey('call-timer'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            connecting ? l10n.aiConnecting : l10n.aiInCall,
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Row(
                            children: [
                              Expanded(
                                child: _Participant(
                                  key: const ValueKey('call-student'),
                                  name: l10n.aiYou,
                                  status: studentStatus,
                                  active: speaker == CallSpeaker.student,
                                  avatar: _StudentAvatar(url: studentAvatar),
                                ),
                              ),
                              Expanded(
                                child: _Participant(
                                  key: const ValueKey('call-partner'),
                                  name: l10n.aiTitle,
                                  status: partnerStatus,
                                  active: speaker == CallSpeaker.partner,
                                  avatar: Image.asset(
                                    'assets/images/ai_speaking_partner.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RoundButton(
                    key: const ValueKey('call-mic'),
                    size: 68,
                    color: micMuted ? Colors.white : _control,
                    semanticsLabel: micMuted ? l10n.aiUnmute : l10n.aiMute,
                    onTap: onToggleMic,
                    child: _Glyph(
                      asset: 'assets/icons/mic_raw.svg',
                      color: micMuted ? callBackground : Colors.white,
                      crossed: micMuted,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  _RoundButton(
                    key: const ValueKey('call-end'),
                    size: 88,
                    color: _danger,
                    semanticsLabel: l10n.aiEnd,
                    onTap: onEnd,
                    child: SvgPicture.asset(
                      'assets/icons/call_ring.svg',
                      width: 34,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  _RoundButton(
                    key: const ValueKey('call-sound'),
                    size: 68,
                    color: soundMuted ? Colors.white : _control,
                    semanticsLabel: soundMuted
                        ? l10n.aiSoundOn
                        : l10n.aiSoundOff,
                    onTap: onToggleSound,
                    child: _Glyph(
                      asset: 'assets/icons/speaker.svg',
                      color: soundMuted ? callBackground : Colors.white,
                      crossed: soundMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  l10n.aiAutoEndNote(limitMinutes),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _Header({required this.title, required this.onBack});

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
                color: _control,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onBack,
                  child: const SizedBox.square(
                    dimension: 40,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
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

/// One side of the call: a round avatar — haloed by the green blob while
/// they have the floor — their name, and what they're doing.
class _Participant extends StatelessWidget {
  final String name;
  final String status;
  final bool active;
  final Widget avatar;

  const _Participant({
    super.key,
    required this.name,
    required this.status,
    required this.active,
    required this.avatar,
  });

  static const _avatarSize = 108.0;
  static const _haloSize = 152.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox.square(
          dimension: _haloSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: active ? 1 : 0,
                child: _SpeakingBlob(
                  key: const ValueKey('speaking-blob'),
                  size: _haloSize,
                  animate: active,
                ),
              ),
              ClipOval(
                child: SizedBox.square(dimension: _avatarSize, child: avatar),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          status,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: active ? _speakingGreen : _muted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StudentAvatar extends StatelessWidget {
  final String? url;

  const _StudentAvatar({required this.url});

  @override
  Widget build(BuildContext context) {
    final url = resolveMediaUrl(this.url);
    const placeholder = ColoredBox(
      color: _control,
      child: Icon(Icons.person_rounded, size: 52, color: _muted),
    );
    if (url == null) return placeholder;
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}

/// A soft, wobbling green blob — two layers, a dark outer one and a bright
/// inner one — that breathes while its participant speaks.
class _SpeakingBlob extends StatefulWidget {
  final double size;
  final bool animate;

  const _SpeakingBlob({super.key, required this.size, required this.animate});

  @override
  State<_SpeakingBlob> createState() => _SpeakingBlobState();
}

class _SpeakingBlobState extends State<_SpeakingBlob>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(_SpeakingBlob oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.animate) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) => CustomPaint(
        size: Size.square(widget.size),
        painter: _BlobPainter(phase: _controller.value * 2 * math.pi),
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  final double phase;

  const _BlobPainter({required this.phase});

  Path _blob(Offset centre, double radius, double wobble, double shift) {
    const points = 72;
    final path = Path();
    for (var i = 0; i <= points; i++) {
      final angle = i / points * 2 * math.pi;
      final r =
          radius *
          (1 +
              wobble * math.sin(3 * angle + phase + shift) +
              wobble * 0.6 * math.sin(5 * angle - phase * 2 + shift));
      final p = centre + Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final radius = size.width / 2;
    canvas.drawPath(
      _blob(centre, radius * 0.92, 0.05, 0),
      Paint()..color = const Color(0xFF3B5E25),
    );
    canvas.drawPath(
      _blob(centre, radius * 0.82, 0.04, 1.3),
      Paint()..color = const Color(0xFF5E9C33),
    );
  }

  @override
  bool shouldRepaint(_BlobPainter oldDelegate) => oldDelegate.phase != phase;
}

class _RoundButton extends StatelessWidget {
  final double size;
  final Color color;
  final String semanticsLabel;
  final VoidCallback onTap;
  final Widget child;

  const _RoundButton({
    super.key,
    required this.size,
    required this.color,
    required this.semanticsLabel,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: Material(
        color: color,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(
            dimension: size,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

/// A control's icon, struck through when its thing is switched off.
class _Glyph extends StatelessWidget {
  final String asset;
  final Color color;
  final bool crossed;

  const _Glyph({
    required this.asset,
    required this.color,
    required this.crossed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            asset,
            width: 26,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          if (crossed)
            Transform.rotate(
              angle: -math.pi / 4,
              child: Container(
                width: 30,
                height: 2.5,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
