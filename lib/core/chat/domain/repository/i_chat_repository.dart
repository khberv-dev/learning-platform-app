import 'package:student/core/chat/domain/entity/chat_message_entity.dart';
import 'package:student/core/chat/domain/entity/chat_room_entity.dart';

abstract class IChatRepository {
  Future<List<ChatRoomEntity>> listRooms();

  Future<ChatRoomEntity> getRoom(String roomId);

  Future<List<ChatMessageEntity>> getMessages(String roomId);

  Future<ChatMessageEntity> sendMessage(String roomId, String text);
}
