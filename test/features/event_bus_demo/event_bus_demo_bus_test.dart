import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter_bloc_app/features/event_bus_demo/domain/event_bus_demo_events.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EventBus demo events', () {
    late EventBus bus;

    setUp(() => bus = EventBus());

    tearDown(() => bus.destroy());

    test('UserLoggedInEvent is delivered to typed listeners', () async {
      final List<UserLoggedInEvent> received = <UserLoggedInEvent>[];
      final StreamSubscription<UserLoggedInEvent> subscription = bus
          .on<UserLoggedInEvent>()
          .listen(received.add);

      bus.fire(const UserLoggedInEvent('101'));
      await Future<void>.delayed(Duration.zero);

      expect(received, hasLength(1));
      expect(received.single.userId, '101');
      await subscription.cancel();
    });

    test('UserLoggedOutEvent does not notify login listeners', () async {
      final List<UserLoggedInEvent> logins = <UserLoggedInEvent>[];
      final StreamSubscription<UserLoggedInEvent> loginSub = bus
          .on<UserLoggedInEvent>()
          .listen(logins.add);
      final StreamSubscription<UserLoggedOutEvent> logoutSub = bus
          .on<UserLoggedOutEvent>()
          .listen((_) {});

      bus.fire(const UserLoggedOutEvent());
      await Future<void>.delayed(Duration.zero);

      expect(logins, isEmpty);
      await loginSub.cancel();
      await logoutSub.cancel();
    });
  });
}
