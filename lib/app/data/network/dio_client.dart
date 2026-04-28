import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/data/network/auth_interceptor.dart';
import 'package:student/app/data/network/config.dart';
import 'package:student/app/data/network/token_storage.dart';
import 'package:student/app/router/app_router.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

final dioClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseApiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(
      dio: dio,
      tokenStorage: ref.read(tokenStorageProvider),
      router: ref.read(appRouterProvider),
    ),
    TalkerDioLogger(),
  ]);

  return dio;
});
