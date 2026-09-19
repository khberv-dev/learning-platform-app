import 'package:flutter_test/flutter_test.dart';
import 'package:student/core/user/domain/entity/streak_entity.dart';
import 'package:student/core/user/domain/entity/user_entity.dart';
import 'package:student/core/user/domain/repository/i_user_repository.dart';
import 'package:student/core/user/domain/usecase/use_record_activity.dart';
import 'package:student/core/user/presentation/activity_recorder.dart';

class _FakeUserRepository implements IUserRepository {
  int calls = 0;
  bool recorded = true;
  Object? error;

  @override
  Future<bool> recordActivity() async {
    calls++;
    if (error != null) throw error!;
    return recorded;
  }

  @override
  Future<UserEntity> getMe() => throw UnimplementedError();

  @override
  Future<StreakEntity> getStreak() => throw UnimplementedError();

  @override
  Future<UserEntity> uploadAvatar(String imagePath) =>
      throw UnimplementedError();
}

void main() {
  late _FakeUserRepository repository;
  late int refreshes;
  late DateTime now;
  late ActivityRecorder recorder;

  setUp(() {
    repository = _FakeUserRepository();
    refreshes = 0;
    now = DateTime.utc(2026, 9, 14, 10);
    recorder = ActivityRecorder(
      UseRecordActivity(repository),
      onRecorded: () => refreshes++,
      now: () => now,
    );
  });

  test('calls the API once per UTC day and refreshes the streak', () async {
    await recorder.record();
    await recorder.record();
    expect(repository.calls, 1);
    expect(refreshes, 1);

    now = DateTime.utc(2026, 9, 15, 0, 1);
    await recorder.record();
    expect(repository.calls, 2);
    expect(refreshes, 2);
  });

  test('shares one request between overlapping calls', () async {
    await Future.wait([recorder.record(), recorder.record()]);
    expect(repository.calls, 1);
  });

  test('does not refresh the streak when today was already recorded', () async {
    repository.recorded = false;
    await recorder.record();
    await recorder.record();
    expect(repository.calls, 1);
    expect(refreshes, 0);
  });

  test('swallows failures and retries on the next call', () async {
    repository.error = Exception('offline');
    await recorder.record();
    expect(refreshes, 0);

    repository.error = null;
    await recorder.record();
    expect(repository.calls, 2);
    expect(refreshes, 1);
  });
}
