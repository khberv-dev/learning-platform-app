import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/user/domain/usecase/use_record_activity.dart';
import 'package:student/core/user/presentation/streak_provider.dart';

final activityRecorderProvider = Provider<ActivityRecorder>(
  (ref) => ActivityRecorder(
    ref.read(useRecordActivityProvider),
    onRecorded: () => ref.invalidate(streakProvider),
  ),
);

/// Tells the API the student studied today, which is what keeps the streak.
///
/// Called on study actions (AI speaking partner, playing a lesson video,
/// opening tasks). The API stores one row per UTC day, so after a successful
/// call the rest of the day's calls are skipped locally. Failures are swallowed
/// — a missed ping must never block the action — and retried on the next call.
class ActivityRecorder {
  final UseRecordActivity _recordActivity;
  final void Function() _onRecorded;
  final DateTime Function() _now;

  DateTime? _recordedDay;
  Future<void>? _pending;

  ActivityRecorder(
    this._recordActivity, {
    required void Function() onRecorded,
    DateTime Function() now = DateTime.now,
  }) : _onRecorded = onRecorded,
       _now = now;

  Future<void> record() {
    final today = _utcDay(_now());
    if (_recordedDay == today) return Future.value();
    return _pending ??= _send(today).whenComplete(() => _pending = null);
  }

  Future<void> _send(DateTime today) async {
    try {
      final recorded = await _recordActivity();
      _recordedDay = today;
      if (recorded) _onRecorded();
    } catch (_) {
      // Best effort; the next study action tries again.
    }
  }

  static DateTime _utcDay(DateTime time) {
    final utc = time.toUtc();
    return DateTime.utc(utc.year, utc.month, utc.day);
  }
}
