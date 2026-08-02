import 'package:flutter_test/flutter_test.dart';
import 'package:student/app/data/network/config.dart';
import 'package:student/core/payments/data/model/payment_response.dart';
import 'package:student/core/payments/data/model/payment_type_response.dart';
import 'package:student/core/payments/domain/entity/payment_entity.dart';
import 'package:student/utils/lib.dart';

void main() {
  group('resolveMediaUrl', () {
    test('passes absolute URLs through', () {
      expect(
        resolveMediaUrl('https://cdn.example.com/a.png'),
        'https://cdn.example.com/a.png',
      );
    });

    test('adds the /public prefix the stored paths omit', () {
      // Uploads are served at /public but stored as /payment-type/x.png.
      expect(
        resolveMediaUrl('/payment-type/payme.png'),
        '$hostUrl/public/payment-type/payme.png',
      );
      expect(
        resolveMediaUrl('/course/eng-a1.png'),
        '$hostUrl/public/course/eng-a1.png',
      );
    });

    test('never doubles a slash, whichever way the parts are punctuated', () {
      // baseCdnUrl carries a trailing slash and the stored paths are rooted.
      for (final raw in ['/course/a.png', 'course/a.png']) {
        final url = resolveMediaUrl(raw)!;
        expect(url, '$hostUrl/public/course/a.png', reason: raw);
        expect(url.split('://').last, isNot(contains('//')), reason: raw);
      }
    });

    test('handles paths without a leading slash', () {
      expect(
        resolveMediaUrl('payment-type/payme.png'),
        '$hostUrl/public/payment-type/payme.png',
      );
    });

    test('treats null and empty as absent', () {
      expect(resolveMediaUrl(null), isNull);
      expect(resolveMediaUrl(''), isNull);
    });
  });

  group('PaymentTypeResponse', () {
    test('reads the documented shape', () {
      final entity = PaymentTypeResponse.fromJson({
        'id': 'p1',
        'title': 'Payme',
        'icon': '/payment-type/payme.png',
        'url': 'https://payme.uz/checkout',
      }).toEntity();

      expect(entity.id, 'p1');
      expect(entity.title, 'Payme');
      expect(entity.iconUrl, '$hostUrl/public/payment-type/payme.png');
      expect(entity.checkoutUrl, 'https://payme.uz/checkout');
    });

    test('accepts name and logo as aliases', () {
      final entity = PaymentTypeResponse.fromJson({
        'id': 7,
        'name': 'Click',
        'logo': 'payment-type/click.png',
      }).toEntity();

      expect(entity.id, '7');
      expect(entity.title, 'Click');
      expect(entity.iconUrl, '$hostUrl/public/payment-type/click.png');
    });

    test('survives a missing icon', () {
      final entity = PaymentTypeResponse.fromJson({
        'id': 'p2',
        'title': 'Uzum',
      }).toEntity();

      expect(entity.iconUrl, isNull);
    });
  });

  group('PaymentRequestResponse', () {
    test('reads the request payload the docs describe', () {
      final entity = PaymentRequestResponse.fromJson({
        'payment': {
          'id': 'pa1',
          'status': 'created',
          'paymentType': null,
          'enrollment': {
            'id': 'en1',
            'status': 'created',
            'start': null,
            'end': null,
            'course': {'id': 'c1', 'title': 'English A1', 'price': 250000},
          },
        },
        'paymentTypes': [
          {
            'id': 'pt1',
            'icon': '/payment-type/payme.png',
            'title': 'Payme',
            'url': 'https://payme.uz/checkout',
            'isActive': true,
          },
        ],
      }).toEntity();

      expect(entity.payment.id, 'pa1');
      expect(entity.payment.status, PaymentStatus.created);
      expect(entity.payment.paymentType, isNull);
      expect(
        entity.payment.enrollment?.status,
        PaymentEnrollmentStatus.created,
      );
      // Null until an admin confirms.
      expect(entity.payment.enrollment?.start, isNull);
      expect(entity.payment.enrollment?.courseTitle, 'English A1');
      expect(entity.paymentTypes.single.title, 'Payme');
      expect(
        entity.paymentTypes.single.iconUrl,
        '$hostUrl/public/payment-type/payme.png',
      );
    });

    test('reads a confirmed payment', () {
      final entity = PaymentResponse.fromJson({
        'id': 'pa1',
        'status': 'paid',
        'enrollment': {
          'id': 'en1',
          'status': 'active',
          'start': '2026-05-18T00:00:00.000Z',
          'end': '2026-08-18T00:00:00.000Z',
          'course': {'id': 'c1', 'title': 'English A1'},
        },
      }).toEntity();

      expect(entity.status, PaymentStatus.paid);
      expect(entity.status.isSettled, isTrue);
      expect(entity.enrollment?.status, PaymentEnrollmentStatus.active);
      expect(entity.enrollment?.start, DateTime.utc(2026, 5, 18));
    });

    test('unknown statuses fall back to the pending ones', () {
      expect(PaymentStatus.parse('wat'), PaymentStatus.created);
      expect(PaymentStatus.parse(null), PaymentStatus.created);
      expect(
        PaymentEnrollmentStatus.parse('wat'),
        PaymentEnrollmentStatus.created,
      );
    });
  });
}
