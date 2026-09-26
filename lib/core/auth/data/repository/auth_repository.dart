import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/data/network/dio_client.dart';
import 'package:student/app/data/network/token_storage.dart';
import 'package:student/core/auth/data/model/auth_response.dart';
import 'package:student/core/auth/domain/entity/auth_entity.dart';
import 'package:student/core/auth/domain/entity/otp_purpose.dart';
import 'package:student/core/auth/domain/repository/i_auth_repository.dart';
import 'package:student/core/user/domain/entity/gender.dart';
import 'package:student/core/user/domain/entity/student_level.dart';

final authRepositoryProvider = Provider<IAuthRepository>(
  (ref) => AuthRepository(
    dio: ref.read(dioClientProvider),
    tokenStorage: ref.read(tokenStorageProvider),
  ),
);

class AuthRepository implements IAuthRepository, IEmailAuthRepository {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  const AuthRepository({required Dio dio, required TokenStorage tokenStorage})
    : _dio = dio,
      _tokenStorage = tokenStorage;

  @override
  Future<bool> checkPhoneExists(String phoneNumber) async {
    final response = await _dio.get(
      'auth/check-phone',
      queryParameters: {'phoneNumber': phoneNumber},
    );
    return (response.data as Map<String, dynamic>)['exists'] as bool? ?? false;
  }

  @override
  Future<bool> checkEmailExists(String email) async {
    final response = await _dio.get(
      'auth/check-email',
      queryParameters: {'email': email.trim().toLowerCase()},
    );
    return (response.data as Map<String, dynamic>)['exists'] as bool? ?? false;
  }

  @override
  Future<AuthEntity> signIn({
    required String phoneNumber,
    required String password,
  }) async {
    final response = await _dio.post(
      'auth/student/sign-in',
      data: {'phoneNumber': phoneNumber, 'password': password},
    );
    return _saveAndReturn(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      'auth/student/sign-in',
      data: {'email': email.trim().toLowerCase(), 'password': password},
    );
    return _saveAndReturn(response.data as Map<String, dynamic>);
  }

  @override
  Future<String> sendRegisterOtp({String? phoneNumber, String? email}) async {
    assert((phoneNumber == null) != (email == null));
    final response = await _dio.post(
      'auth/register/otp/send',
      data: {
        'phoneNumber': ?phoneNumber,
        if (email != null) 'email': email.trim().toLowerCase(),
      },
    );
    return (response.data as Map<String, dynamic>)['sessionId'] as String;
  }

  @override
  Future<void> verifyRegisterOtp({
    required String sessionId,
    required String code,
  }) async {
    await _dio.post(
      'auth/register/otp/verify',
      data: {'sessionId': sessionId, 'code': code},
    );
  }

  @override
  Future<AuthEntity> register({
    required String sessionId,
    required String firstName,
    String? lastName,
    required String password,
    StudentLevel? level,
    Gender? gender,
  }) async {
    final response = await _dio.post(
      'auth/register',
      data: {
        'sessionId': sessionId,
        'firstName': firstName.trim(),
        'password': password,
        // Left out rather than sent null: all three are optional, and the API
        // rejects a null against its enum validators.
        if (lastName != null && lastName.trim().isNotEmpty)
          'lastName': lastName.trim(),
        if (level != null) 'level': level.code,
        if (gender != null) 'gender': gender.code,
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
  Future<void> sendEmailOtp({
    required String email,
    required OtpPurpose purpose,
  }) async {
    await _dio.post(
      'auth/otp/send',
      data: {'email': email.trim().toLowerCase(), 'purpose': purpose.value},
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
