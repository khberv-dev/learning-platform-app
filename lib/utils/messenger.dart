import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

String apiErrorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map) {
      final msg = data['message'];
      if (msg is String && msg.isNotEmpty) return msg;
      if (msg is List && msg.isNotEmpty) return msg.first.toString();
    }
  }
  return 'Something went wrong. Please try again.';
}

void showErrorMessage(BuildContext context, String message) {
  showErrorOn(
    ScaffoldMessenger.of(context),
    message,
    background: Theme.of(context).colorScheme.error,
  );
}

/// For when the screen that started the work may be gone by the time the
/// outcome is known — capture the messenger before navigating away.
void showErrorOn(
  ScaffoldMessengerState messenger,
  String message, {
  required Color background,
}) {
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(content: Text(message), backgroundColor: background),
    );
}
