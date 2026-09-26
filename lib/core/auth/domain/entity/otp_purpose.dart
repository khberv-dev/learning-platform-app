/// Why a code is being asked for, matching the API's `OtpPurpose` on
/// `auth/otp/send`.
///
/// Only password recovery still uses that endpoint — registration has its own
/// session-based `auth/register/otp/*` flow — but the API still requires the
/// purpose, and checks it: a [recover] code is only ever sent to a number
/// that has an account.
enum OtpPurpose {
  recover('recover');

  /// Wire value. The API's enum is lower-case, which Dart's names happen to
  /// match — spelled out anyway so a rename here can't change the request.
  final String value;

  const OtpPurpose(this.value);
}
