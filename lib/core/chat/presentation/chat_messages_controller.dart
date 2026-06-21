import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:student/app/data/network/config.dart';
import 'package:student/app/data/network/token_storage.dart';
import 'package:student/core/chat/data/model/chat_message_response.dart';
import 'package:student/core/chat/data/repository/chat_repository.dart';
import 'package:student/core/chat/domain/entity/chat_message_entity.dart';

class ChatMessagesState {
  final bool isLoading;
  final String? error;
  final List<ChatMessageEntity> messages;
  final bool isSending;

  const ChatMessagesState({
    this.isLoading = false,
    this.error,
    this.messages = const [],
    this.isSending = false,
  });

  ChatMessagesState copyWith({
    bool? isLoading,
    String? error,
    List<ChatMessageEntity>? messages,
    bool? isSending,
  }) => ChatMessagesState(
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
    messages: messages ?? this.messages,
    isSending: isSending ?? this.isSending,
  );

  // List is kept newest-first to pair with ListView(reverse: true)
  ChatMessagesState addMessage(ChatMessageEntity msg) {
    if (messages.any((m) => m.id == msg.id)) return this;
    return copyWith(messages: [msg, ...messages]);
  }
}

final chatMessagesProvider = StateNotifierProvider.family<
    ChatMessagesNotifier, ChatMessagesState, String>(
  (ref, roomId) => ChatMessagesNotifier(ref: ref, roomId: roomId),
);

class ChatMessagesNotifier extends StateNotifier<ChatMessagesState> {
  final String roomId;
  final Ref _ref;
  io.Socket? _socket;

  ChatMessagesNotifier({required this.roomId, required Ref ref})
      : _ref = ref,
        super(const ChatMessagesState(isLoading: true)) {
    _loadAndConnect();
  }

  Future<void> _loadAndConnect() async {
    try {
      final messages =
          await _ref.read(chatRepositoryProvider).getMessages(roomId);
      if (!mounted) return;
      // API returns DESC (newest first) — keep that order for ListView(reverse: true)
      state = ChatMessagesState(messages: messages);
    } catch (e) {
      if (!mounted) return;
      state = ChatMessagesState(error: e.toString());
      return;
    }
    _connectSocket();
  }

  Future<void> _connectSocket() async {
    final token = await _ref.read(tokenStorageProvider).getAccessToken();
    if (token == null || !mounted) return;

    final socket = io.io(
      '$hostUrl/chat',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );
    _socket = socket;

    socket.on('message', (data) {
      if (!mounted || data is! Map) return;
      final msg = ChatMessageResponse.fromJson(
        Map<String, dynamic>.from(data),
      ).toEntity();
      state = state.addMessage(msg);
    });

    socket.connect();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    state = state.copyWith(isSending: true);
    try {
      final msg =
          await _ref.read(chatRepositoryProvider).sendMessage(roomId, text);
      if (!mounted) return;
      state = state.addMessage(msg).copyWith(isSending: false);
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(isSending: false);
    }
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }
}
