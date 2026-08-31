import 'package:flutter_test/flutter_test.dart';
import 'package:student/core/user/data/model/streak_response.dart';

void main() {
  test('parses the streak API response', () {
    final streak = StreakResponse.fromJson({
      'currentStreak': 4,
      'longestStreak': 9,
      'totalActiveDays': 14,
      'activeToday': true,
      'lastActiveDate': '2026-08-27',
    }).toEntity();

    expect(streak.currentStreak, 4);
    expect(streak.longestStreak, 9);
    expect(streak.totalActiveDays, 14);
    expect(streak.activeToday, isTrue);
    expect(streak.lastActiveDate, DateTime.utc(2026, 8, 27));
  });

  test('maps the current streak onto Monday-first card cells', () {
    final streak = StreakResponse.fromJson({
      'currentStreak': 4,
      'lastActiveDate': '2026-08-27',
    }).toEntity();

    expect(streak.week(now: DateTime.utc(2026, 8, 30)), [
      true,
      true,
      true,
      true,
      false,
      false,
      false,
    ]);
  });

  test('only includes streak dates in the current week', () {
    final streak = StreakResponse.fromJson({
      'currentStreak': 5,
      'lastActiveDate': '2026-08-25',
    }).toEntity();

    expect(streak.week(now: DateTime.utc(2026, 8, 30)), [
      true,
      true,
      false,
      false,
      false,
      false,
      false,
    ]);
  });
}
