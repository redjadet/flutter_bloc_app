import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_messaging_service.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_permission_state.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/push_message.dart';
import 'package:flutter_bloc_app/features/fcm_demo/presentation/cubit/fcm_demo_state.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_subscription_mixin.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Cubit for the FCM demo: permission, token, and last message.
class FcmDemoCubit extends Cubit<FcmDemoState> with CubitSubscriptionMixin<FcmDemoState> {
  FcmDemoCubit({required final FcmMessagingService messaging})
    : _messaging = messaging,
      super(const FcmDemoState());

  final FcmMessagingService _messaging;
  bool _streamsSubscribed = false;

  /// Initialize FCM demo: request permission, load token and initial message,
  /// subscribe to foreground/opened/token streams.
  Future<void> initialize() async {
    if (isClosed || _streamsSubscribed) return;
    AppLogger.debug('FCM demo: initializing (permission, token, streams)');
    emit(state.copyWith(status: FcmDemoStatus.loading));
    bool permissionRequestFailed = false;
    await CubitExceptionHandler.executeAsync<FcmPermissionState>(
      operation: () => _messaging.requestPermission(),
      isAlive: () => !isClosed,
      onSuccess: (final permission) {
        if (isClosed) return;
        emit(state.copyWith(permissionState: permission));
      },
      onError: (final message) {
        if (isClosed) return;
        permissionRequestFailed = true;
        emit(
          state.copyWith(
            status: FcmDemoStatus.error,
            errorMessage: message,
          ),
        );
      },
      logContext: 'FcmDemoCubit.initialize.requestPermission',
    );
    if (isClosed || permissionRequestFailed) return;

    await CubitExceptionHandler.executeAsync<
      ({String? fcmToken, String? apnsToken, PushMessage? initialMessage})
    >(
      operation: () async {
        final String? token = await _messaging.getToken();
        final String? apnsToken = await _messaging.getApnsToken();
        final PushMessage? initial = await _messaging.getInitialMessage();
        return (
          fcmToken: token,
          apnsToken: apnsToken,
          initialMessage: initial,
        );
      },
      isAlive: () => !isClosed,
      onSuccess: (final data) {
        if (isClosed) return;
        AppLogger.debug(
          'FCM demo: ready fcmToken=${data.fcmToken != null ? "***" : null} '
          'apnsToken=${data.apnsToken != null ? "***" : null} '
          'initialMessage=${data.initialMessage != null}',
        );
        final PushMessage? initialMsg = data.initialMessage;
        if (initialMsg != null) {
          AppLogger.debug(
            'FCM demo: initial message (from getInitialMessage) '
            'id=${initialMsg.messageId}',
          );
        }
        emit(
          state.copyWith(
            status: FcmDemoStatus.ready,
            errorMessage: null,
            fcmToken: data.fcmToken,
            apnsToken: data.apnsToken,
            lastMessage: data.initialMessage ?? state.lastMessage,
          ),
        );
        _subscribeToStreams();
      },
      onError: (final message) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: FcmDemoStatus.error,
            errorMessage: message,
          ),
        );
      },
      logContext: 'FcmDemoCubit.initialize.loadInitialData',
    );
  }

  void _subscribeToStreams() {
    if (_streamsSubscribed) return;
    _streamsSubscribed = true;
    AppLogger.debug('FCM demo: subscribed to foreground, opened, tokenRefresh');

    final StreamSubscription<PushMessage> foreground = _messaging.foregroundMessages.listen(
      (final msg) {
        if (isClosed) return;
        AppLogger.debug(
          'FCM demo: foreground message received id=${msg.messageId}',
        );
        emit(state.copyWith(lastMessage: msg));
      },
      onError: (final Object error, final StackTrace stackTrace) {
        AppLogger.error('FCM foreground stream error', error, stackTrace);
        if (isClosed) return;
        emit(
          state.copyWith(
            status: FcmDemoStatus.error,
            errorMessage: error.toString(),
          ),
        );
      },
    );
    registerSubscription(foreground);

    final StreamSubscription<PushMessage> opened = _messaging.openedMessages.listen(
      (final msg) {
        if (isClosed) return;
        AppLogger.debug(
          'FCM demo: opened-from-notification id=${msg.messageId}',
        );
        emit(state.copyWith(lastMessage: msg));
      },
      onError: (final Object error, final StackTrace stackTrace) {
        AppLogger.error('FCM opened stream error', error, stackTrace);
        if (isClosed) return;
        emit(
          state.copyWith(
            status: FcmDemoStatus.error,
            errorMessage: error.toString(),
          ),
        );
      },
    );
    registerSubscription(opened);

    final StreamSubscription<String> tokenRefresh = _messaging.tokenRefreshes.listen(
      (final newToken) {
        if (isClosed) return;
        emit(state.copyWith(fcmToken: newToken));
      },
      onError: (final Object error, final StackTrace stackTrace) {
        AppLogger.error(
          'FCM token refresh stream error',
          error,
          stackTrace,
        );
      },
    );
    registerSubscription(tokenRefresh);
  }

  @override
  Future<void> close() {
    _streamsSubscribed = false;
    return super.close();
  }
}
