import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/data/network/dio_client.dart';
import 'package:student/app/data/network/token_storage.dart';
import 'package:student/core/auth/data/model/auth_response.dart';
import 'package:student/core/auth/domain/entity/auth_entity.dart';
import 'package:student/core/auth/domain/repository/i_auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>(
  (ref) => AuthRepository(
    dio: ref.read(dioClientProvider),
    tokenStorage: ref.read(tokenStorageProvider),
  ),
);

class AuthRepository implements IAuthRepository {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  const AuthRepository({required Dio dio, required TokenStorage tokenStorage})
    : _dio = dio,
      _tokenStorage = tokenStorage;

  @override
  Future<AuthEntity> signIn({
    required String phoneNumber,
    required String password,
  }) async {
    final response = await _dio.post(
      'auth/sign-in',
      data: {'phoneNumber': phoneNumber, 'password': password},
    );

    final auth = AuthResponse.fromJson(response.data as Map<String, dynamic>);

    await _tokenStorage.saveTokens(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
    );

    return auth.toEntity();
  }
}
