import 'package:flutter_test/flutter_test.dart';
import 'package:student/core/payments/data/model/payment_response.dart';
import 'package:student/core/payments/data/model/payment_type_response.dart';
import 'package:student/core/payments/domain/entity/payment_entity.dart';
import 'package:student/utils/lib.dart';

void main() {
  group('resolveMediaUrl', () {
    test('passes absolute URLs through unchanged', () {
      expect(
        resolveMediaUrl('https://cdn.example.com/a.png'),
        'https://cdn.example.com/a.png',
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
        'icon': 'https://cp.i-teach.uz/public/payment-type/payme.png',
        'url': 'https://payme.uz/checkout',
      }).toEntity();

      expect(entity.id, 'p1');
      expect(entity.title, 'Payme');
      expect(
        entity.iconUrl,
        'https://cp.i-teach.uz/public/payment-type/payme.png',
      );
      expect(entity.checkoutUrl, 'https://payme.uz/checkout');
    });

    test('accepts name and logo as aliases', () {
      final entity = PaymentTypeResponse.fromJson({
        'id': 7,
        'name': 'Click',
        'logo': 'https://cp.i-teach.uz/public/payment-type/click.png',
      }).toEntity();

      expect(entity.id, '7');
      expect(entity.title, 'Click');
      expect(
        entity.iconUrl,
        'https://cp.i-teach.uz/public/payment-type/click.png',
      );
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
        'payment': {'id': 'pa1', 'status': 'created', 'paymentType': null},
        'paymentTypes': [
          {
            'id': 'pt1',
            'icon': 'https://cp.i-teach.uz/public/payment-type/payme.png',
            'title': 'Payme',
            'url': 'https://payme.uz/checkout',
            'isActive': true,
          },
        ],
      }).toEntity();

      expect(entity.payment.id, 'pa1');
      expect(entity.payment.status, PaymentStatus.created);
      expect(entity.payment.paymentType, isNull);
      // Not yet settled — no purchase/subscription has been created.
      expect(entity.payment.courseTitle, isNull);
      expect(entity.paymentTypes.single.title, 'Payme');
      expect(
        entity.paymentTypes.single.iconUrl,
        'https://cp.i-teach.uz/public/payment-type/payme.png',
      );
    });

    test('reads a confirmed payment', () {
      final entity = PaymentResponse.fromJson({
        'id': 'pa1',
        'status': 'paid',
        'purchases': [
          {
            'id': 'pu1',
            'subscription': {
              'id': 'su1',
              'start': '2026-05-18T00:00:00.000Z',
              'end': '2026-08-18T00:00:00.000Z',
              'plan': {
                'id': 'pl1',
                'title': 'Premium',
                'course': {'id': 'c1', 'title': 'English A1'},
              },
            },
          },
        ],
      }).toEntity();

      expect(entity.status, PaymentStatus.paid);
      expect(entity.status.isSettled, isTrue);
      expect(entity.planTitle, 'Premium');
      expect(entity.courseTitle, 'English A1');
    });

    test('unknown statuses fall back to the pending ones', () {
      expect(PaymentStatus.parse('wat'), PaymentStatus.created);
      expect(PaymentStatus.parse(null), PaymentStatus.created);
    });
  });
}
