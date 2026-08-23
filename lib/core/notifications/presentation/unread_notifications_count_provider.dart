import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/core/notifications/domain/usecase/use_get_unread_notifications_count.dart';

final unreadNotificationsCountProvider = FutureProvider<int>(
  (ref) => ref.read(useGetUnreadNotificationsCountProvider).call(),
);
