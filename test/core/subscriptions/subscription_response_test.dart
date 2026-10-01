import 'package:flutter_test/flutter_test.dart';
import 'package:student/core/subscriptions/data/model/subscription_response.dart';
import 'package:student/core/subscriptions/domain/entity/subscription_entity.dart';
import 'package:student/ui/profile/widget/subscription_card.dart';

SubscriptionEntity _sub(String id, DateTime end, {bool isActive = true}) =>
    SubscriptionEntity(
      id: id,
      course: SubscriptionCourseEntity(id: 'c-$id', title: 'Course $id'),
      start: end.subtract(const Duration(days: 30)),
      end: end,
      isActive: isActive,
    );

void main() {
  test('reads a subscription and its course', () {
    final sub = SubscriptionResponse.fromJson({
      'id': 'ab9bb43c',
      'course': {
        'id': '95a0b4ea',
        'title': 'General English',
        'image': 'https://storage.example/c.jpg',
      },
      'start': '2026-09-30T18:28:08.239Z',
      'end': '2026-10-30T18:28:08.239Z',
      'isActive': true,
    }).toEntity();

    expect(sub.course.id, '95a0b4ea');
    expect(sub.course.title, 'General English');
    expect(sub.course.image, 'https://storage.example/c.jpg');
    expect(sub.end.toUtc(), DateTime.utc(2026, 10, 30, 18, 28, 8, 239));
    expect(sub.isActive, isTrue);
  });

  group('isCurrentAt', () {
    final now = DateTime(2026, 10, 1);

    test('active and not yet ended is current', () {
      expect(_sub('a', DateTime(2026, 10, 30)).isCurrentAt(now), isTrue);
    });

    test('past its end is not current, even if still flagged active', () {
      expect(_sub('a', DateTime(2026, 9, 30)).isCurrentAt(now), isFalse);
    });

    test('flagged inactive is not current, even before its end', () {
      expect(
        _sub('a', DateTime(2026, 10, 30), isActive: false).isCurrentAt(now),
        isFalse,
      );
    });
  });

  group('PlanStatus', () {
    final now = DateTime(2026, 10, 1);

    test('none when there are no subscriptions', () {
      expect(PlanStatus.of([], now), isA<PlanNone>());
    });

    test('current ones only, soonest to end first', () {
      final status = PlanStatus.of([
        _sub('later', DateTime(2026, 12, 1)),
        _sub('old', DateTime(2026, 8, 1)),
        _sub('sooner', DateTime(2026, 10, 20)),
      ], now);

      expect(status, isA<PlanActive>());
      expect((status as PlanActive).subscriptions.map((s) => s.id), [
        'sooner',
        'later',
      ]);
    });

    test('all expired picks the one that ended last', () {
      final status = PlanStatus.of([
        _sub('first', DateTime(2026, 7, 1)),
        _sub('last', DateTime(2026, 9, 22)),
      ], now);

      expect(status, isA<PlanExpired>());
      expect((status as PlanExpired).latest.id, 'last');
    });
  });
}
