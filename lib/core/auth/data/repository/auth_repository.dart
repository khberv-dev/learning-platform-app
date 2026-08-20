import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/data/network/dio_client.dart';
import 'package:student/app/data/network/token_storage.dart';
import 'package:student/core/auth/data/model/auth_response.dart';
import 'package:student/core/auth/domain/entity/auth_entity.dart';
import 'package:student/core/auth/domain/entity/otp_purpose.dart';
import 'package:student/core/auth/domain/repository/i_auth_repository.dart';
import 'package:student/core/user/domain/entity/student_level.dart';

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
    return _saveAndReturn(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthEntity> signUp({
    required String firstName,
    required String phoneNumber,
    required String password,
    required String code,
    StudentLevel? level,
  }) async {
    final response = await _dio.post(
      'auth/sign-up',
      data: {
        'firstName': firstName,
        'phoneNumber': phoneNumber,
        'password': password,
        'code': code,
        // Left out rather than sent null: the field is optional, and the API
        // rejects a null against its enum validator.
        if (level != null) 'level': level.code,
      },
    );
    return _saveAndReturn(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> sendOtp({
    required String phoneNumber,
    required OtpPurpose purpose,
  }) async {
    await _dio.post(
      'auth/otp/send',
      data: {'phoneNumber': phoneNumber, 'purpose': purpose.value},
    );
  }

  @override
  Future<void> recoverPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
  }) async {
    await _dio.post(
      'auth/recover-password',
      data: {
        'phoneNumber': phoneNumber,
        'code': code,
        'newPassword': newPassword,
      },
    );
  }

  Future<AuthEntity> _saveAndReturn(Map<String, dynamic> json) async {
    final auth = AuthResponse.fromJson(json);
    await _tokenStorage.saveTokens(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
    );
    return auth.toEntity();
  }
}
