import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/chat/data/repository/chat_repository.dart';
import 'package:student/core/chat/domain/entity/chat_room_entity.dart';

final chatRoomsProvider = FutureProvider<List<ChatRoomEntity>>(
  (ref) => ref.read(chatRepositoryProvider).listRooms(),
);

final hasChatRoomsProvider = FutureProvider<bool>(
  (ref) async {
    final rooms = await ref.watch(chatRoomsProvider.future);
    return rooms.isNotEmpty;
  },
);

final chatRoomProvider = FutureProvider.family<ChatRoomEntity, String>(
  (ref, roomId) => ref.read(chatRepositoryProvider).getRoom(roomId),
);
