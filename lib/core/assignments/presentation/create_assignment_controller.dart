import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/assignments/domain/entity/assignment_entity.dart';
import 'package:student/core/assignments/domain/usecase/use_create_assignment.dart';

final createAssignmentControllerProvider =
    AsyncNotifierProvider<CreateAssignmentController, AssignmentEntity?>(
      CreateAssignmentController.new,
    );

class CreateAssignmentController extends AsyncNotifier<AssignmentEntity?> {
  @override
  FutureOr<AssignmentEntity?> build() => null;

  Future<void> book({required String teacherId}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(useCreateAssignmentProvider).call(
        teacherId: teacherId,
        startDate: DateTime.now(),
      ),
    );
  }

  static String errorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final msg = data['message'];
        if (msg is String) return msg;
        if (msg is List && msg.isNotEmpty) return msg.first.toString();
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
