/// Why a code is being asked for, matching the API's `OtpPurpose`.
///
/// One endpoint serves both flows, but it checks opposite things: a
/// [registration] code is refused for a number that already has an account,
/// while [recover] is only ever for a number that does. Send the wrong one and
/// the flow it belongs to cannot get a code at all.
enum OtpPurpose {
  registration('registration'),
  recover('recover');

  /// Wire value. The API's enum is lower-case, which Dart's names happen to
  /// match — spelled out anyway so a rename here can't change the request.
  final String value;

  const OtpPurpose(this.value);
}
