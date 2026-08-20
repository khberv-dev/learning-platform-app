import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/data/network/config.dart';
import 'package:student/core/p2p/domain/entity/p2p_state.dart';
import 'package:student/core/p2p/presentation/p2p_controller.dart';
import 'package:student/l10n/app_localizations.dart';
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

  String _statusLabel(AppLocalizations l10n, P2pState s) {
    if (s is P2pConnected) return _timeLabel;
    if (s is P2pConnecting) return l10n.p2pConnecting;
    if (s is P2pMatched) return l10n.p2pMatched;
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    final p2pState = ref.watch(p2pControllerProvider);
    final peer = _peerFrom(p2pState);

    final l10n = AppLocalizations.of(context);

    ref.listen<P2pState>(p2pControllerProvider, (prev, next) {
      if (next is P2pConnected) {
        _ensureTicker();
      } else if (next is P2pEnded) {
        _ticker?.cancel();
        _showEnded(_endedMessage(l10n, next.reason));
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
                peer?.displayName ?? l10n.p2pTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                p2pState is P2pConnected
                    ? l10n.p2pConnected
                    : l10n.p2pConnecting,
                style: const TextStyle(color: Color(0xFF18C96A), fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                _statusLabel(l10n, p2pState),
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
                      label: _muted ? l10n.p2pUnmute : l10n.p2pMute,
                      background: const Color(0xFF1E293B),
                      iconColor: const Color(0xFF94A3B8),
                      labelColor: const Color(0xFF94A3B8),
                      borderColor: const Color(0xFF334155),
                      onTap: _toggleMute,
                    ),
                    CallActionButton(
                      icon: Icons.call_end_rounded,
                      label: l10n.p2pEnd,
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

  String _endedMessage(AppLocalizations l10n, P2pEndReason reason) {
    switch (reason) {
      case P2pEndReason.leave:
        return l10n.p2pEndedCall;
      case P2pEndReason.partnerLeft:
        return l10n.p2pPeerLeft;
      case P2pEndReason.partnerDisconnected:
        return l10n.p2pPeerDisconnected;
      case P2pEndReason.cancelled:
        return l10n.p2pCancelled;
      case P2pEndReason.replaced:
        return l10n.p2pReplaced;
      case P2pEndReason.error:
        return l10n.p2pError;
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
