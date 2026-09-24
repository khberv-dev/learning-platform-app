class ChatMessageEntity {
  final String id;
  final String type;
  final String? text;
  final String? filePath;
  final String? fileName;
  final int? fileSize;
  final String? fileMimeType;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String createdAt;

  const ChatMessageEntity({
    required this.id,
    required this.type,
    required this.senderId,
    required this.senderName,
    required this.createdAt,
    this.senderAvatar,
    this.text,
    this.filePath,
    this.fileName,
    this.fileSize,
    this.fileMimeType,
  });

  bool get isText => type == 'text';

  bool get isFile => type == 'file';
}
