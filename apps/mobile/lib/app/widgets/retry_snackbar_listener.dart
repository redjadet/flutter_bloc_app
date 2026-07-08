import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/utils/context_utils.dart';
import 'package:networking/networking.dart' show RetryNotification;
import 'package:utilities/utilities.dart';

/// Listens to [RetryNotification] stream and shows a SnackBar with retry action.
class RetrySnackBarListener extends StatefulWidget {
  const RetrySnackBarListener({
    required this.notifications,
    required this.child,
    super.key,
  });

  final Stream<RetryNotification> notifications;
  final Widget child;

  @override
  State<RetrySnackBarListener> createState() => _RetrySnackBarListenerState();
}

class _RetrySnackBarListenerState extends State<RetrySnackBarListener> {
  final DisposableBag _disposables = DisposableBag();
  // ignore: cancel_subscriptions - Lifecycle is centralized via DisposableBag.
  StreamSubscription<RetryNotification>? _subscription;
  DateTime? _lastShownAt;

  @override
  void initState() {
    super.initState();
    _subscribeToNotifications();
  }

  @override
  void didUpdateWidget(final RetrySnackBarListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifications != widget.notifications) {
      final StreamSubscription<RetryNotification>? previousSubscription =
          _subscription;
      _subscription = null;
      _disposables.untrackSubscription(previousSubscription);
      unawaited(previousSubscription?.cancel());
      _subscribeToNotifications();
    }
  }

  void _subscribeToNotifications() {
    _subscription = _disposables.trackSubscription(
      widget.notifications.listen(
        _handleNotification,
        onError: (final Object error, final StackTrace stackTrace) {
          AppLogger.error(
            'RetrySnackBarListener stream error',
            error,
            stackTrace,
          );
        },
      ),
    );
  }

  void _handleNotification(final RetryNotification notification) {
    if (!mounted) {
      ContextUtils.logNotMounted('RetrySnackBarListener._handleNotification');
      return;
    }

    final DateTime now = DateTime.now();
    final DateTime? last = _lastShownAt;
    if (last != null && now.difference(last) < const Duration(seconds: 2)) {
      return;
    }
    _lastShownAt = now;

    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(
      context,
    );
    if (messenger == null || Scaffold.maybeOf(context) == null) {
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(context.l10n.networkRetryingSnackBarMessage),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _subscription = null;
    unawaited(_disposables.dispose());
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => widget.child;
}
