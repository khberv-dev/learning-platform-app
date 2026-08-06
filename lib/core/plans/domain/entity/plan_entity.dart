/// A purchasable tariff for a course. Price lives here, not on the course —
/// a course can be sold at several durations.
class PlanEntity {
  final String id;
  final String title;
  final int price;

  /// How many months of access the plan buys.
  final int month;

  final bool hasMentor;

  const PlanEntity({
    required this.id,
    required this.title,
    required this.price,
    required this.month,
    required this.hasMentor,
  });
}
