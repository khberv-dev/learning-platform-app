import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/data/network/config.dart';
import 'package:student/core/p2p/domain/entity/p2p_state.dart';
import 'package:student/core/p2p/presentation/p2p_controller.dart';
import 'package:student/ui/main/app_screen.dart';
import 'package:student/ui/p2p/widget/call_action_button.dart';

class P2pCallScreen extends ConsumerStatefulWidget {
  static const path = '/p2p-call';

  const P2pCallScreen({super.key});

  @override
  ConsumerState<P2pCallScreen> createState() => _P2pCallScreenState();
}

class _P2pCallScreenState extends ConsumerState<P2pCallScreen> {
  Timer? _ticker;
  Duration _elapsed = Duration.zero;
  bool _muted = false;

  void _ensureTicker() {
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String get _timeLabel {
    final m = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _hangUp() {
    ref.read(p2pControllerProvider.notifier).leave();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  void _toggleMute() {
    final next = !_muted;
    ref.read(p2pControllerProvider.notifier).setMuted(next);
    setState(() => _muted = next);
  }

  P2pPeer? _peerFrom(P2pState s) {
    if (s is P2pMatched) return s.peer;
    if (s is P2pConnecting) return s.peer;
    if (s is P2pConnected) return s.peer;
    return null;
  }

  String _statusLabel(P2pState s) {
    if (s is P2pConnected) return _timeLabel;
    if (s is P2pConnecting) return 'Connecting…';
    if (s is P2pMatched) return 'Matched';
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    final p2pState = ref.watch(p2pControllerProvider);
    final peer = _peerFrom(p2pState);

    ref.listen<P2pState>(p2pControllerProvider, (prev, next) {
      if (next is P2pConnected) {
        _ensureTicker();
      } else if (next is P2pEnded) {
        _ticker?.cancel();
        _showEnded(_endedMessage(next.reason));
      } else if (next is P2pError) {
        _ticker?.cancel();
        _showEnded(next.message);
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF1E3A5F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 110),
              _PeerAvatar(peer: peer),
              const SizedBox(height: 20),
              Text(
                peer?.displayName ?? 'Speaking Partner',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                p2pState is P2pConnected ? 'Connected' : 'Connecting…',
                style: const TextStyle(color: Color(0xFF18C96A), fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                _statusLabel(p2pState),
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CallActionButton(
                      icon: _muted
                          ? Icons.mic_off_rounded
                          : Icons.mic_none_rounded,
                      label: _muted ? 'Unmute' : 'Mute',
                      background: const Color(0xFF1E293B),
                      iconColor: const Color(0xFF94A3B8),
                      labelColor: const Color(0xFF94A3B8),
                      borderColor: const Color(0xFF334155),
                      onTap: _toggleMute,
                    ),
                    CallActionButton(
                      icon: Icons.call_end_rounded,
                      label: 'End',
                      background: const Color(0xFFEF4444),
                      iconColor: Colors.white,
                      labelColor: const Color(0xFFEF4444),
                      onTap: _hangUp,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEnded(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppScreen.path);
    }
  }

  String _endedMessage(P2pEndReason reason) {
    switch (reason) {
      case P2pEndReason.leave:
        return 'Call ended';
      case P2pEndReason.partnerLeft:
        return 'Your partner left the call';
      case P2pEndReason.partnerDisconnected:
        return 'Your partner disconnected';
      case P2pEndReason.cancelled:
        return 'Call cancelled';
      case P2pEndReason.replaced:
        return 'Session replaced by another connection';
      case P2pEndReason.error:
        return 'Call error';
    }
  }
}

class _PeerAvatar extends StatelessWidget {
  final P2pPeer? peer;

  const _PeerAvatar({this.peer});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = peer?.avatarUrl;
    final imageUrl = avatarUrl == null
        ? null
        : avatarUrl.startsWith('http')
        ? avatarUrl
        : '$baseCdnUrl/$avatarUrl';

    if (imageUrl != null) {
      return ClipOval(
        child: Image.network(
          imageUrl,
          width: 110,
          height: 110,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _initialsCircle(peer),
        ),
      );
    }
    return _initialsCircle(peer);
  }

  Widget _initialsCircle(P2pPeer? peer) {
    return Container(
      width: 110,
      height: 110,
      decoration: const BoxDecoration(
        color: Color(0xFF18C96A),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        peer?.initials ?? '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 38,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
