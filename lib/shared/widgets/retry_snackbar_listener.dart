import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/services/retry_notification_service.dart';
import 'package:flutter_bloc_app/shared/utils/context_utils.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

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
  StreamSubscription<RetryNotification>? _subscription;
  DateTime? _lastShownAt;

  @override
  void initState() {
    super.initState();
    _subscription = widget.notifications.listen(
      _handleNotification,
      onError: (final Object error, final StackTrace stackTrace) {
        AppLogger.error(
          'RetrySnackBarListener stream error',
          error,
          stackTrace,
        );
      },
    );
  }

  @override
  void didUpdateWidget(final RetrySnackBarListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifications != widget.notifications) {
      unawaited(_subscription?.cancel());
      _subscription = widget.notifications.listen(
        _handleNotification,
        onError: (final Object error, final StackTrace stackTrace) {
          AppLogger.error(
            'RetrySnackBarListener stream error',
            error,
            stackTrace,
          );
        },
      );
    }
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
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => widget.child;
}
