import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/data/network/dio_client.dart';
import 'package:student/core/user/data/model/user_response.dart';
import 'package:student/core/user/data/model/streak_response.dart';
import 'package:student/core/user/domain/entity/streak_entity.dart';
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
    final response = await _dio.get('student/me');
    return UserResponse.fromJson(
      response.data as Map<String, dynamic>,
    ).toEntity();
  }

  @override
  Future<StreakEntity> getStreak() async {
    final response = await _dio.get('student/me/streak');
    return StreakResponse.fromJson(
      response.data as Map<String, dynamic>,
    ).toEntity();
  }

  @override
  Future<bool> recordActivity() async {
    final response = await _dio.post('student/me/activity');
    final data = response.data;
    return data is Map<String, dynamic> && data['recorded'] == true;
  }

  @override
  Future<UserEntity> uploadAvatar(String imagePath) async {
    final form = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(imagePath),
    });
    final response = await _dio.patch('student/me/avatar', data: form);
    return UserResponse.fromJson(
      response.data as Map<String, dynamic>,
    ).toEntity();
  }
}
