/// Matches the API's `Gender` enum. Optional on sign-up — the API defaults
/// to [male] when it isn't sent.
enum Gender {
  male('male'),
  female('female');

  /// Wire value, e.g. `male`.
  final String code;

  const Gender(this.code);
}
