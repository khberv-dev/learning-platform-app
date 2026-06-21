import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/chat/domain/entity/chat_message_entity.dart';
import 'package:student/core/chat/presentation/chat_messages_controller.dart';
import 'package:student/core/chat/presentation/chat_rooms_controller.dart';
import 'package:student/core/user/presentation/current_user_provider.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  static const path = '/chat/room';

  final String roomId;

  const ChatRoomScreen({
    super.key,
    required this.roomId,
  });

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    ref
        .read(chatMessagesProvider(widget.roomId).notifier)
        .sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatMessagesProvider(widget.roomId));
    final currentUserId = ref.watch(currentUserProvider)?.id ?? '';
    final roomDetail = ref.watch(chatRoomProvider(widget.roomId)).value;
    final mentor = roomDetail?.mentor;
    final mentorId = mentor?.id;
    final mentorName = mentor?.fullName ?? 'Mentor';
    final mentorInitial = mentorName.isNotEmpty ? mentorName[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _Header(mentorName: mentorName, mentorInitial: mentorInitial),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                  ? Center(
                      child: Text(
                        state.error!,
                        style: const TextStyle(color: Color(0xFF6B7280)),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : state.messages.isEmpty
                  ? const _EmptyMessages()
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      itemCount: state.messages.length,
                      itemBuilder: (_, i) {
                        final msg = state.messages[i];
                        // Prefer mentor-id check: more reliable than
                        // currentUserProvider which may not be set yet.
                        final isMe = mentorId != null
                            ? msg.senderId != mentorId
                            : msg.senderId == currentUserId;
                        return _MessageBubble(message: msg, isMe: isMe);
                      },
                    ),
            ),
            _InputBar(
              controller: _textController,
              isSending: state.isSending,
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String mentorName;
  final String mentorInitial;

  const _Header({required this.mentorName, required this.mentorInitial});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF0FDF4),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                mentorInitial,
                style: const TextStyle(
                  color: Color(0xFF18C96A),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mentorName,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Mentor',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: Navigator.of(context).pop,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessageEntity message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  String _formatTime(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72,
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFF18C96A) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: message.isText
                    ? Text(
                        message.text ?? '',
                        style: TextStyle(
                          color: isMe ? Colors.white : const Color(0xFF111827),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.attach_file_rounded,
                            color: isMe
                                ? Colors.white70
                                : const Color(0xFF6B7280),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              message.fileName ?? 'File',
                              style: TextStyle(
                                color: isMe
                                    ? Colors.white
                                    : const Color(0xFF111827),
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
                child: Text(
                  _formatTime(message.createdAt),
                  style: const TextStyle(
                    color: Color(0xFFD1D5DB),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatefulWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final has = widget.controller.text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Type a message…',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 4,
              minLines: 1,
              onSubmitted: (_) => _hasText ? widget.onSend() : null,
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color:
                  _hasText ? const Color(0xFF18C96A) : const Color(0xFFE5E7EB),
              shape: BoxShape.circle,
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: (_hasText && !widget.isSending) ? widget.onSend : null,
                child: Center(
                  child: widget.isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          color: _hasText
                              ? Colors.white
                              : const Color(0xFF9CA3AF),
                          size: 20,
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

// ── Empty messages ────────────────────────────────────────────────────────────

class _EmptyMessages extends StatelessWidget {
  const _EmptyMessages();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            color: Color(0xFFD1D5DB),
            size: 48,
          ),
          SizedBox(height: 12),
          Text(
            'No messages yet',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            'Send a message to start the conversation.',
            style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
