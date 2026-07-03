import 'dart:async';

/// A small event payload emitted when the app is automatically retrying work.
///
/// Intended for optional UI feedback such as a subtle SnackBar.
class RetryNotification {
  const RetryNotification({
    required this.method,
    required this.uri,
    required this.attempt,
    required this.maxAttempts,
    required this.delay,
    required this.error,
  });

  final String method;
  final Uri uri;
  final int attempt;
  final int maxAttempts;
  final Duration delay;
  final Object error;
}

abstract class RetryNotificationService {
  Stream<RetryNotification> get notifications;

  void notifyRetrying(final RetryNotification notification);

  Future<void> dispose();
}

class InMemoryRetryNotificationService implements RetryNotificationService {
  final StreamController<RetryNotification> _controller =
      StreamController<RetryNotification>.broadcast(sync: true);

  @override
  Stream<RetryNotification> get notifications => _controller.stream;

  @override
  void notifyRetrying(final RetryNotification notification) {
    if (_controller.isClosed) return;
    _controller.add(notification);
  }

  @override
  Future<void> dispose() => _controller.close();
}
