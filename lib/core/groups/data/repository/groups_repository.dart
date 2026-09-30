import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/data/network/dio_client.dart';
import 'package:student/core/groups/data/model/group_response.dart';
import 'package:student/core/groups/domain/entity/group_entity.dart';
import 'package:student/core/groups/domain/repository/i_groups_repository.dart';

final groupsRepositoryProvider = Provider<IGroupsRepository>(
  (ref) => GroupsRepository(dio: ref.read(dioClientProvider)),
);

class GroupsRepository implements IGroupsRepository {
  final Dio _dio;

  const GroupsRepository({required Dio dio}) : _dio = dio;

  @override
  Future<List<GroupEntity>> getMyGroups() async {
    // Paginated, but a student is in one group per course, so a single page
    // holds them all.
    final response = await _dio.get(
      'student/groups/me',
      queryParameters: {'limit': 100},
    );
    final envelope = response.data as Map<String, dynamic>;
    final list = envelope['data'] as List<dynamic>? ?? const [];
    return list
        .map(
          (e) => GroupResponse.fromJson(e as Map<String, dynamic>).toEntity(),
        )
        .toList();
  }
}
