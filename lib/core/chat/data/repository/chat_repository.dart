import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/data/network/dio_client.dart';
import 'package:student/core/chat/data/model/chat_message_response.dart';
import 'package:student/core/chat/data/model/chat_room_response.dart';
import 'package:student/core/chat/domain/entity/chat_message_entity.dart';
import 'package:student/core/chat/domain/entity/chat_room_entity.dart';
import 'package:student/core/chat/domain/repository/i_chat_repository.dart';

final chatRepositoryProvider = Provider<IChatRepository>(
  (ref) => ChatRepository(dio: ref.read(dioClientProvider)),
);

class ChatRepository implements IChatRepository {
  final Dio _dio;

  const ChatRepository({required Dio dio}) : _dio = dio;

  @override
  Future<List<ChatRoomEntity>> listRooms() async {
    final response = await _dio.get(
      'chat/rooms',
      queryParameters: {'page': 1, 'limit': 50},
    );
    final data = response.data as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;
    return list
        .map(
          (e) =>
              ChatRoomResponse.fromJson(e as Map<String, dynamic>).toEntity(),
        )
        .toList();
  }

  @override
  Future<ChatRoomEntity> getRoom(String roomId) async {
    final response = await _dio.get('chat/rooms/$roomId');
    return ChatRoomResponse.fromJson(
      response.data as Map<String, dynamic>,
    ).toEntity();
  }

  @override
  Future<List<ChatMessageEntity>> getMessages(String roomId) async {
    final response = await _dio.get(
      'chat/rooms/$roomId/messages',
      queryParameters: {'page': 1, 'limit': 50},
    );
    final data = response.data as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;
    return list
        .map(
          (e) => ChatMessageResponse.fromJson(
            e as Map<String, dynamic>,
          ).toEntity(),
        )
        .toList();
  }

  @override
  Future<ChatMessageEntity> sendMessage(String roomId, String text) async {
    final response = await _dio.post(
      'chat/rooms/$roomId/messages',
      data: {'text': text},
    );
    return ChatMessageResponse.fromJson(
      response.data as Map<String, dynamic>,
    ).toEntity();
  }
}
