class StreakEntity {
  final int currentStreak;
  final int longestStreak;
  final int totalActiveDays;
  final bool activeToday;
  final DateTime? lastActiveDate;

  const StreakEntity({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalActiveDays,
    required this.activeToday,
    required this.lastActiveDate,
  });

  /// Active days in the UTC calendar week used by the API, Monday first.
  List<bool> week({DateTime? now}) {
    final result = List<bool>.filled(7, false);
    if (currentStreak <= 0 || lastActiveDate == null) return result;

    final today = now?.toUtc() ?? DateTime.now().toUtc();
    final monday = DateTime.utc(
      today.year,
      today.month,
      today.day - (today.weekday - DateTime.monday),
    );

    for (var offset = 0; offset < currentStreak; offset++) {
      final date = lastActiveDate!.subtract(Duration(days: offset));
      final index = date.difference(monday).inDays;
      if (index >= 0 && index < result.length) result[index] = true;
    }
    return result;
  }
}
