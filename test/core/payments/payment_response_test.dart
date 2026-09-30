import 'package:flutter_test/flutter_test.dart';
import 'package:student/core/payments/data/model/payment_response.dart';

void main() {
  group('PaymentResponse', () {
    test('an unpaid payment reads its plan from the purchase', () {
      final payment = PaymentResponse.fromJson({
        'id': 'p1',
        'status': 'pending',
        'amount': 250000,
        'purchases': [
          {
            'plan': {
              'title': 'Standard',
              'course': {'title': 'General English'},
            },
            'subscription': null,
          },
        ],
      }).toEntity();

      expect(payment.planTitle, 'Standard');
      expect(payment.courseTitle, 'General English');
    });

    test("still reads a plan nested under the subscription", () {
      final payment = PaymentResponse.fromJson({
        'id': 'p1',
        'purchases': [
          {
            'subscription': {
              'plan': {
                'title': 'Standard',
                'course': {'title': 'General English'},
              },
            },
          },
        ],
      }).toEntity();

      expect(payment.planTitle, 'Standard');
      expect(payment.courseTitle, 'General English');
    });

    test('a payment with no purchases has no plan', () {
      final payment = PaymentResponse.fromJson({'id': 'p1'}).toEntity();

      expect(payment.planTitle, isNull);
      expect(payment.courseTitle, isNull);
    });
  });
}
