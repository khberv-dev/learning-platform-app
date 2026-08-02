import 'package:student/app/data/network/config.dart';

/// Resolves a media path from the API into an absolute URL.
///
/// Uploads land in the API's `./uploads` directory and are served at `/public`,
/// while the stored paths omit that prefix — a course image is `/course/x.png`
/// and a payment icon is `/payment-type/x.png`. Both need [baseCdnUrl] in
/// front.
///
/// Trims a slash from each side of the join: the stored paths are rooted and
/// [baseCdnUrl] carries a trailing slash, so a naive `'$baseCdnUrl/$raw'`
/// yields `/public//course/x.png`.
String? resolveMediaUrl(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  if (raw.startsWith('http')) return raw;

  final base = baseCdnUrl.endsWith('/')
      ? baseCdnUrl.substring(0, baseCdnUrl.length - 1)
      : baseCdnUrl;
  final path = raw.startsWith('/') ? raw.substring(1) : raw;
  return '$base/$path';
}

// Formats 998900012644 → +998 90 001 26 44
String formatPhone(String? raw) {
  if (raw == null || raw.isEmpty) return '—';
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 12) {
    return '+${digits.substring(0, 3)} ${digits.substring(3, 5)} ${digits.substring(5, 8)} ${digits.substring(8, 10)} ${digits.substring(10, 12)}';
  }
  return '+$digits';
}

String formatNumber(num value) {
  final s = value.toInt().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(s[i]);
  }
  return buffer.toString();
}
