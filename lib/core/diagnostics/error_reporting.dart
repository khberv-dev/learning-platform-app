import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:student/app/data/network/config.dart';
import 'package:student/app/data/network/token_storage.dart';

const _maxMessageLength = 10000;
const _maxDeviceLength = 255;

/// Reports an uncaught error to `POST app-reports` so a crash we can't
/// attach a debugger to still leaves a trace.
///
/// The endpoint is public — it works even before sign-in — but attaches the
/// stored access token when there is one, since the backend resolves
/// `AppReport.userId` from that token itself rather than a body field. Built
/// on a bare [Dio] rather than [dioClientProvider] so it needs no Riverpod
/// container and can't be dragged into the main client's auth-refresh flow.
///
/// Never throws: a failure to report an error must not cause another one.
Future<void> reportAppError(Object error, StackTrace? stack) async {
  if (!kReleaseMode) return;

  try {
    final token = await TokenStorage().getAccessToken();
    final device = await _describeDevice();
    final message = '$error\n${stack ?? ''}';

    final dio = Dio(
      BaseOptions(
        baseUrl: baseApiUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    await dio.post(
      'app-reports',
      data: {
        'device': _truncate(device, _maxDeviceLength),
        'message': _truncate(message, _maxMessageLength),
      },
      options: Options(
        headers: token == null ? null : {'Authorization': 'Bearer $token'},
      ),
    );
  } catch (_) {
    // Best-effort — swallow so a failed report never becomes a second crash.
  }
}

Future<String> _describeDevice() async {
  try {
    final info = await PackageInfo.fromPlatform();
    final os = '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
    return '$os / ${info.appName} ${info.version}+${info.buildNumber}';
  } catch (_) {
    return Platform.operatingSystem;
  }
}

String _truncate(String value, int maxLength) =>
    value.length > maxLength ? value.substring(0, maxLength) : value;
