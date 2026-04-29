import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/courses/domain/entity/course_detail_entity.dart';
import 'package:student/core/courses/domain/usecase/use_get_course_detail.dart';

final courseDetailControllerProvider =
    FutureProvider.family<CourseDetailEntity, String>(
      (ref, id) => ref.read(useGetCourseDetailProvider).call(id),
    );
