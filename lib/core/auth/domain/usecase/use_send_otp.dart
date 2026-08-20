import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/auth/data/repository/auth_repository.dart';
import 'package:student/core/auth/domain/entity/otp_purpose.dart';
import 'package:student/core/auth/domain/repository/i_auth_repository.dart';

final useSendOtpProvider = Provider(
  (ref) => UseSendOtp(ref.read(authRepositoryProvider)),
);

class UseSendOtp {
  final IAuthRepository _repository;

  const UseSendOtp(this._repository);

  Future<void> call({
    required String phoneNumber,
    required OtpPurpose purpose,
  }) => _repository.sendOtp(phoneNumber: phoneNumber, purpose: purpose);
}
