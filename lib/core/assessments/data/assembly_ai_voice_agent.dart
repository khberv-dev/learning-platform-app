import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_pcm_sound/flutter_pcm_sound.dart' as pcm;
import 'package:record/record.dart';

typedef AgentTextCallback = void Function(String text);
typedef AgentStateCallback = void Function(AssemblyAiAgentState state);
typedef AgentErrorCallback = void Function(Object error);

enum AssemblyAiAgentState { connecting, listening, thinking, speaking, idle }

/// A mobile client for AssemblyAI's managed Voice Agent API.
///
/// The socket provides STT, turn detection, LLM responses, and TTS. Audio is
/// streamed as mono PCM16 at 24 kHz, as required by the Voice Agent API.
class AssemblyAiVoiceAgent {
  static const _socketUrl = 'wss://agents.assemblyai.com/v1/ws';
  static const _sampleRate = 24000;

  final AudioRecorder _recorder;
  final AgentTextCallback onAgentText;
  final AgentStateCallback onStateChanged;
  final AgentErrorCallback onError;

  WebSocket? _socket;
  StreamSubscription<List<int>>? _microphoneSubscription;
  StreamSubscription<dynamic>? _socketSubscription;
  Completer<void>? _ready;
  Future<void> _playbackQueue = Future<void>.value();
  bool _agentSpeaking = false;
  bool _disposed = false;

  AssemblyAiVoiceAgent({
    required AudioRecorder recorder,
    required this.onAgentText,
    required this.onStateChanged,
    required this.onError,
  }) : _recorder = recorder;

  Future<void> connect(String apiKey) async {
    if (_socket != null) return;

    onStateChanged(AssemblyAiAgentState.connecting);
    _ready = Completer<void>();
    final socket = await WebSocket.connect(
      _socketUrl,
      headers: {HttpHeaders.authorizationHeader: 'Bearer $apiKey'},
    );
    _socket = socket;
    _socketSubscription = socket.listen(
      _handleMessage,
      onError: _handleError,
      onDone: () {
        _socket = null;
        if (!_disposed) onStateChanged(AssemblyAiAgentState.idle);
      },
      cancelOnError: false,
    );

    socket.add(
      jsonEncode({
        'type': 'session.update',
        'session': {
          'system_prompt':
              'You are a friendly English speaking assessor. Conduct a short '
              'CEFR-style spoken assessment, one concise question at a time. '
              'Adapt questions to the learner\'s level. Briefly acknowledge '
              'their answer, then ask the next question. Focus on grammar, '
              'vocabulary, fluency, and pronunciation. Keep every response '
              'under three sentences and never use markdown.',
          'input': {
            'format': {'encoding': 'audio/pcm'},
            'turn_detection': {
              'vad_threshold': 0.5,
              'min_silence': 700,
              'max_silence': 1800,
              'interrupt_response': true,
            },
          },
          'output': {
            'voice': 'ivy',
            'format': {'encoding': 'audio/pcm'},
          },
        },
      }),
    );

    try {
      await _ready!.future.timeout(const Duration(seconds: 15));
    } catch (_) {
      await _socketSubscription?.cancel();
      await socket.close();
      _socket = null;
      rethrow;
    }
  }

  Future<void> startListening() async {
    final socket = _socket;
    if (socket == null) throw StateError('Voice agent is not connected');

    await pcm.FlutterPcmSound.setup(
      sampleRate: _sampleRate,
      channelCount: 1,
      iosAudioCategory: pcm.IosAudioCategory.playAndRecord,
    );
    await pcm.FlutterPcmSound.setLogLevel(pcm.LogLevel.error);
    await pcm.FlutterPcmSound.setFeedThreshold(2400);

    final audio = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: _sampleRate,
        numChannels: 1,
        echoCancel: true,
        noiseSuppress: true,
        autoGain: true,
      ),
    );
    _microphoneSubscription = audio.listen((bytes) {
      if (socket.readyState == WebSocket.open) {
        socket.add(
          jsonEncode({'type': 'input.audio', 'audio': base64Encode(bytes)}),
        );
      }
    }, onError: _handleError);
    onStateChanged(AssemblyAiAgentState.listening);
  }

  void _handleMessage(dynamic rawMessage) {
    try {
      final message = jsonDecode(rawMessage as String) as Map<String, dynamic>;
      switch (message['type']) {
        case 'session.ready':
          if (!(_ready?.isCompleted ?? true)) _ready!.complete();
          onStateChanged(AssemblyAiAgentState.idle);
          return;
        case 'input.speech.started':
          if (_agentSpeaking) unawaited(_resetPlayback());
          onStateChanged(AssemblyAiAgentState.listening);
          return;
        case 'input.speech.stopped':
        case 'reply.started':
          onStateChanged(AssemblyAiAgentState.thinking);
          return;
        case 'transcript.agent':
          final text = message['transcript'] ?? message['text'];
          if (text is String && text.isNotEmpty) onAgentText(text);
          return;
        case 'reply.audio':
          final audio = message['data'];
          if (audio is String && audio.isNotEmpty) {
            _agentSpeaking = true;
            _queueAudio(base64Decode(audio));
            onStateChanged(AssemblyAiAgentState.speaking);
          }
          return;
        case 'reply.done':
          _agentSpeaking = false;
          onStateChanged(AssemblyAiAgentState.listening);
          return;
        case 'session.error':
          _handleError(
            StateError(message['message']?.toString() ?? 'Voice agent error'),
          );
          return;
      }
    } catch (error) {
      _handleError(error);
    }
  }

  void _queueAudio(Uint8List audioBytes) {
    _playbackQueue = _playbackQueue
        .then((_) async {
          if (_disposed) return;
          await pcm.FlutterPcmSound.feed(
            pcm.PcmArrayInt16(bytes: ByteData.sublistView(audioBytes)),
          );
        })
        .catchError((Object error) => onError(error));
  }

  Future<void> _resetPlayback() async {
    _agentSpeaking = false;
    await pcm.FlutterPcmSound.release();
    if (_disposed) return;
    await pcm.FlutterPcmSound.setup(
      sampleRate: _sampleRate,
      channelCount: 1,
      iosAudioCategory: pcm.IosAudioCategory.playAndRecord,
    );
    await pcm.FlutterPcmSound.setFeedThreshold(2400);
  }

  void _handleError(Object error) {
    if (!(_ready?.isCompleted ?? true)) _ready!.completeError(error);
    if (!_disposed) {
      onError(error);
      onStateChanged(AssemblyAiAgentState.idle);
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    await _recorder.stop();
    await _microphoneSubscription?.cancel();
    await _socketSubscription?.cancel();
    await _socket?.close();
    await pcm.FlutterPcmSound.release();
    await _recorder.dispose();
  }
}
