import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final tokenStorageProvider = Provider((ref) => TokenStorage());

class TokenStorage {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _storage async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<String?> getAccessToken() async =>
      (await _storage).getString(_accessKey);

  Future<String?> getRefreshToken() async =>
      (await _storage).getString(_refreshKey);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await _storage;
    await prefs.setString(_accessKey, accessToken);
    await prefs.setString(_refreshKey, refreshToken);
  }

  Future<void> clearTokens() async {
    final prefs = await _storage;
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
  }

  Future<void> clearAll() async => (await _storage).clear();
}
