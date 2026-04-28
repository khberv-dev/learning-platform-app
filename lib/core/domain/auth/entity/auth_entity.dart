class AuthEntity {
  final String accessToken;
  final String refreshToken;

  const AuthEntity({
    required this.accessToken,
    required this.refreshToken,
  });
}
