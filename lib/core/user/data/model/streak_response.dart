import 'package:student/core/user/domain/entity/streak_entity.dart';

class StreakResponse {
  final int currentStreak;
  final int longestStreak;
  final int totalActiveDays;
  final bool activeToday;
  final DateTime? lastActiveDate;

  const StreakResponse({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalActiveDays,
    required this.activeToday,
    required this.lastActiveDate,
  });

  factory StreakResponse.fromJson(Map<String, dynamic> json) {
    final lastActiveDate = json['lastActiveDate'] as String?;
    return StreakResponse(
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      totalActiveDays: (json['totalActiveDays'] as num?)?.toInt() ?? 0,
      activeToday: json['activeToday'] as bool? ?? false,
      lastActiveDate: lastActiveDate == null
          ? null
          : DateTime.tryParse('${lastActiveDate}T00:00:00.000Z'),
    );
  }

  StreakEntity toEntity() => StreakEntity(
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    totalActiveDays: totalActiveDays,
    activeToday: activeToday,
    lastActiveDate: lastActiveDate,
  );
}
