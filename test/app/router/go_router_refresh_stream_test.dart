import 'dart:async';

import 'package:flutter_bloc_app/app/router/go_router_refresh_stream.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoRouterRefreshStream', () {
    test('creates subscription to stream', () {
      final controller = StreamController<int>.broadcast();
      final refreshStream = GoRouterRefreshStream(controller.stream);

      // Verify subscription is created
      expect(controller.hasListener, isTrue);

      controller.close();
      refreshStream.dispose();
    });

    test('notifies listeners when stream emits', () async {
      final controller = StreamController<int>.broadcast();
      final refreshStream = GoRouterRefreshStream(controller.stream);

      final Completer<void> notificationReceived = Completer<void>();

      refreshStream.addListener(() {
        if (!notificationReceived.isCompleted) {
          notificationReceived.complete();
        }
      });

      controller.add(1);
      await notificationReceived.future.timeout(
        const Duration(seconds: 1),
        onTimeout: () {
          fail('Notification not received within timeout');
        },
      );

      controller.close();
      refreshStream.dispose();
    });

    test('disposes subscription on dispose', () async {
      final controller = StreamController<int>.broadcast();
      final refreshStream = GoRouterRefreshStream(controller.stream);

      expect(controller.hasListener, isTrue);

      refreshStream.dispose();

      // Wait for async cancellation to complete
      await Future.delayed(const Duration(milliseconds: 10));
      expect(controller.hasListener, isFalse);
    });

    test('handles multiple listeners', () async {
      final controller = StreamController<int>.broadcast();
      final refreshStream = GoRouterRefreshStream(controller.stream);

      int notificationCount1 = 0;
      int notificationCount2 = 0;
      final Completer<void> bothNotified = Completer<void>();

      void checkBothNotified() {
        if (notificationCount1 >= 1 &&
            notificationCount2 >= 1 &&
            !bothNotified.isCompleted) {
          bothNotified.complete();
        }
      }

      refreshStream.addListener(() {
        notificationCount1++;
        checkBothNotified();
      });
      refreshStream.addListener(() {
        notificationCount2++;
        checkBothNotified();
      });

      controller.add(1);
      await bothNotified.future.timeout(
        const Duration(seconds: 1),
        onTimeout: () {
          fail('Notifications not received within timeout');
        },
      );

      expect(notificationCount1, greaterThanOrEqualTo(1));
      expect(notificationCount2, greaterThanOrEqualTo(1));

      controller.close();
      refreshStream.dispose();
    });

    test('handles empty stream gracefully', () {
      final controller = StreamController<int>.broadcast();
      final refreshStream = GoRouterRefreshStream(controller.stream);

      bool notified = false;
      refreshStream.addListener(() {
        notified = true;
      });

      controller.close();

      expect(notified, isFalse);
      refreshStream.dispose();
    });
  });
}
