class ChatMessageEntity {
  final String id;
  final String type;
  final String? text;
  final String? filePath;
  final String? fileName;
  final String senderId;
  final String senderName;
  final String createdAt;

  const ChatMessageEntity({
    required this.id,
    required this.type,
    required this.senderId,
    required this.senderName,
    required this.createdAt,
    this.text,
    this.filePath,
    this.fileName,
  });

  bool get isText => type == 'text';

  bool get isFile => type == 'file';
}
