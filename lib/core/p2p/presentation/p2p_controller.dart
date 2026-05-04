import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:student/app/data/network/config.dart';
import 'package:student/app/data/network/token_storage.dart';
import 'package:student/core/p2p/domain/entity/p2p_state.dart';

final p2pControllerProvider = NotifierProvider<P2pController, P2pState>(
  P2pController.new,
);

class P2pController extends Notifier<P2pState> {
  io.Socket? _socket;
  RTCPeerConnection? _peer;
  MediaStream? _localStream;
  P2pRole? _role;
  bool _remoteDescriptionSet = false;
  final List<RTCIceCandidate> _pendingCandidates = [];

  static const _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };

  @override
  P2pState build() {
    ref.onDispose(_teardown);
    return const P2pIdle();
  }

  Future<void> findPartner() async {
    final token = await ref.read(tokenStorageProvider).getAccessToken();
    if (token == null) {
      state = const P2pError('Not authenticated');
      return;
    }

    await _teardown();
    state = const P2pSearching();

    final socket = io.io(
      '$hostUrl/match',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );
    _socket = socket;

    socket
      ..onConnect((_) => socket.emit('search'))
      ..on('searching', (_) => state = const P2pSearching())
      ..on('matched', (data) async {
        final m = (data as Map).cast<String, dynamic>();
        final sessionId = m['sessionId'] as String;
        final role = m['role'] == 'caller' ? P2pRole.caller : P2pRole.callee;
        _role = role;
        state = P2pMatched(sessionId: sessionId, role: role);
        await _setupPeer();
      })
      ..on('signal', (data) async {
        final inner = (data as Map).cast<String, dynamic>()['data'];
        await _handleSignal((inner as Map).cast<String, dynamic>());
      })
      ..on('partner-left', (data) async {
        final reason = (data as Map).cast<String, dynamic>()['reason'];
        await _teardown();
        state = P2pEnded(
          reason == 'disconnect'
              ? P2pEndReason.partnerDisconnected
              : P2pEndReason.partnerLeft,
        );
      })
      ..on('cancelled', (_) async {
        await _teardown();
        state = const P2pEnded(P2pEndReason.cancelled);
      })
      ..on('left', (_) async {
        await _teardown();
        state = const P2pEnded(P2pEndReason.leave);
      })
      ..on('replaced', (_) async {
        await _teardown();
        state = const P2pEnded(P2pEndReason.replaced);
      })
      ..on('error', (data) {
        state = P2pError(_extractMessage(data));
      })
      ..on('unauthorized', (data) {
        state = P2pError(_extractMessage(data, fallback: 'Unauthorized'));
      })
      ..onConnectError((err) {
        state = P2pError(err?.toString() ?? 'Connection error');
      });

    socket.connect();
  }

  Future<void> cancel() async {
    _socket?.emit('cancel');
    await _teardown();
    state = const P2pEnded(P2pEndReason.cancelled);
  }

  Future<void> leave() async {
    _socket?.emit('leave');
    await _teardown();
    state = const P2pEnded(P2pEndReason.leave);
  }

  Future<void> setMuted(bool muted) async {
    final tracks = _localStream?.getAudioTracks() ?? const [];
    for (final track in tracks) {
      track.enabled = !muted;
    }
  }

  Future<void> _setupPeer() async {
    state = P2pConnecting(role: _role!);

    final peer = await createPeerConnection(_iceServers);
    _peer = peer;

    final stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': false,
    });
    _localStream = stream;

    for (final track in stream.getTracks()) {
      await peer.addTrack(track, stream);
    }

    peer.onIceCandidate = (candidate) {
      if (candidate.candidate == null) return;
      _socket?.emit('signal', {
        'data': {
          'type': 'candidate',
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
        },
      });
    };

    peer.onConnectionState = (connState) {
      if (connState == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        state = const P2pConnected();
      } else if (connState ==
              RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          connState == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        if (state is! P2pEnded) {
          state = const P2pError('Call disconnected');
        }
      }
    };

    if (_role == P2pRole.caller) {
      final offer = await peer.createOffer();
      await peer.setLocalDescription(offer);
      _socket?.emit('signal', {
        'data': {'type': 'offer', 'sdp': offer.sdp},
      });
    }
  }

  Future<void> _handleSignal(Map<String, dynamic> data) async {
    final peer = _peer;
    if (peer == null) return;

    final type = data['type'] as String;
    if (type == 'offer') {
      await peer.setRemoteDescription(
        RTCSessionDescription(data['sdp'] as String, 'offer'),
      );
      _remoteDescriptionSet = true;
      await _flushCandidates();

      final answer = await peer.createAnswer();
      await peer.setLocalDescription(answer);
      _socket?.emit('signal', {
        'data': {'type': 'answer', 'sdp': answer.sdp},
      });
    } else if (type == 'answer') {
      await peer.setRemoteDescription(
        RTCSessionDescription(data['sdp'] as String, 'answer'),
      );
      _remoteDescriptionSet = true;
      await _flushCandidates();
    } else if (type == 'candidate') {
      final c = (data['candidate'] as Map).cast<String, dynamic>();
      final candidate = RTCIceCandidate(
        c['candidate'] as String?,
        c['sdpMid'] as String?,
        (c['sdpMLineIndex'] as num?)?.toInt(),
      );
      if (_remoteDescriptionSet) {
        await peer.addCandidate(candidate);
      } else {
        _pendingCandidates.add(candidate);
      }
    }
  }

  Future<void> _flushCandidates() async {
    final peer = _peer;
    if (peer == null) return;
    for (final c in _pendingCandidates) {
      await peer.addCandidate(c);
    }
    _pendingCandidates.clear();
  }

  Future<void> _teardown() async {
    _remoteDescriptionSet = false;
    _pendingCandidates.clear();
    _role = null;

    final peer = _peer;
    _peer = null;
    if (peer != null) {
      await peer.close();
    }

    final stream = _localStream;
    _localStream = null;
    if (stream != null) {
      for (final track in stream.getTracks()) {
        await track.stop();
      }
      await stream.dispose();
    }

    final socket = _socket;
    _socket = null;
    socket?.dispose();
  }

  static String _extractMessage(dynamic data, {String fallback = 'Error'}) {
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return fallback;
  }
}
