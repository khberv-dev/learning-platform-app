import 'dart:async';

import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/data/network/token_storage.dart';
import 'package:student/ui/auth/login_screen.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStorage _tokenStorage;
  final GoRouter _router;

  // Serialises concurrent 401s — only one refresh flies at a time.
  Completer<String>? _refreshCompleter;

  AuthInterceptor({
    required Dio dio,
    required TokenStorage tokenStorage,
    required GoRouter router,
  })  : _dio = dio,
        _tokenStorage = tokenStorage,
        _router = router;

  // ── Attach access token to every outgoing request ────────────────────────

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.path != 'auth/refresh') {
      final token = await _tokenStorage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  // ── Handle 401 responses ─────────────────────────────────────────────────

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) return handler.next(err);

    // Guard: don't retry a request that was already retried once.
    if (err.requestOptions.extra['retried'] == true) {
      return handler.reject(err);
    }

    // Guard: the refresh endpoint itself returned 401 → force logout.
    if (err.requestOptions.path == 'auth/refresh') {
      await _logout();
      return handler.reject(err);
    }

    String newToken;

    if (_refreshCompleter != null) {
      // A refresh is already in flight — wait for its result.
      try {
        newToken = await _refreshCompleter!.future;
      } catch (_) {
        return handler.reject(err);
      }
    } else {
      // Start a new refresh and let concurrent waiters piggyback on it.
      _refreshCompleter = Completer<String>();
      try {
        newToken = await _doRefresh();
        _refreshCompleter!.complete(newToken);
      } on DioException catch (e) {
        _refreshCompleter!.completeError(e);
        if (e.response?.statusCode == 401) await _logout();
        return handler.reject(e);
      } catch (e) {
        _refreshCompleter!.completeError(e);
        return handler.reject(err);
      } finally {
        _refreshCompleter = null;
      }
    }

    // Retry the original request with the fresh token.
    try {
      final retryOptions = err.requestOptions
        ..extra['retried'] = true
        ..headers['Authorization'] = 'Bearer $newToken';
      final response = await _dio.fetch(retryOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.reject(e);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<String> _doRefresh() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) {
      await _logout();
      throw Exception('No refresh token available');
    }

    final response = await _dio.post(
      'auth/refresh',
      options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
    );

    final data = response.data as Map<String, dynamic>;
    final newAccessToken =
        (data['accessToken'] ?? data['access_token']) as String;
    final newRefreshToken =
        (data['refreshToken'] ?? data['refresh_token'] ?? refreshToken)
            as String;

    await _tokenStorage.saveTokens(
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    );

    return newAccessToken;
  }

  Future<void> _logout() async {
    await _tokenStorage.clearTokens();
    _router.go(LoginScreen.path);
  }
}
