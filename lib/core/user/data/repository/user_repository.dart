import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/data/network/dio_client.dart';
import 'package:student/core/user/data/model/user_response.dart';
import 'package:student/core/user/domain/entity/user_entity.dart';
import 'package:student/core/user/domain/repository/i_user_repository.dart';

final userRepositoryProvider = Provider<IUserRepository>(
  (ref) => UserRepository(dio: ref.read(dioClientProvider)),
);

class UserRepository implements IUserRepository {
  final Dio _dio;

  const UserRepository({required Dio dio}) : _dio = dio;

  @override
  Future<UserEntity> getMe() async {
    final response = await _dio.get('user/me');
    return UserResponse.fromJson(response.data as Map<String, dynamic>)
        .toEntity();
  }
}
