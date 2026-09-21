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
  Future<GroupEntity?> getMyGroup() async {
    final response = await _dio.get('student/groups/me');
    final data = response.data;
    if (data == null) return null;
    return GroupResponse.fromJson(data as Map<String, dynamic>).toEntity();
  }
}
