part of 'production_readiness_cubit.dart';

mixin _ProductionReadinessCubitFcm on _ProductionReadinessCubitBase {
  @override
  Future<void> _initializeFcm() async {
    final FcmMessagingService? messaging = _messaging;
    if (messaging == null || isClosed) {
      return;
    }

    final permission = await messaging.requestPermission();
    if (isClosed) {
      return;
    }
    emit(state.copyWith(fcmPermission: permission));

    final PushMessage? initial = await messaging.getInitialMessage();
    if (initial != null && !isClosed) {
      _applyFcmMessageSummary(initial);
    }

    _subscribeToFcmStreams();
  }

  void _subscribeToFcmStreams() {
    final FcmMessagingService? messaging = _messaging;
    if (_fcmStreamsSubscribed || messaging == null) {
      return;
    }
    _fcmStreamsSubscribed = true;

    registerSubscription(
      messaging.foregroundMessages.listen(
        (final message) {
          if (isClosed) {
            return;
          }
          _applyFcmMessageSummary(message);
          unawaited(_trackNotificationReceived());
        },
        onError: (final Object _, final StackTrace _) {
          if (isClosed) {
            return;
          }
          emit(
            state.copyWith(
              errorMessage: _ProductionReadinessCubitBase.fcmStreamErrorMessage,
            ),
          );
        },
      ),
    );

    registerSubscription(
      messaging.openedMessages.listen(
        (final message) {
          if (isClosed) {
            return;
          }
          _applyFcmMessageSummary(message);
          unawaited(_trackNotificationOpened());
        },
        onError: (final Object _, final StackTrace _) {
          if (isClosed) {
            return;
          }
          emit(
            state.copyWith(
              errorMessage: _ProductionReadinessCubitBase.fcmStreamErrorMessage,
            ),
          );
        },
      ),
    );
  }

  void _applyFcmMessageSummary(final PushMessage message) {
    emit(
      state.copyWith(
        fcmDataKeyCount: message.data.length,
        fcmHasTitle: message.title?.isNotEmpty ?? false,
        fcmHasBody: message.body?.isNotEmpty ?? false,
        fcmLastSource: message.source.name,
      ),
    );
  }

  @override
  Future<void> _trackNotificationReceived() async {
    if (!state.analyticsConsentEnabled) {
      return;
    }
    await _analytics.track(
      AppAnalyticsEvent.notificationReceived(
        mode: state.fcmMode.name,
        source: 'production_readiness',
      ),
    );
    if (!isClosed) {
      emit(state.copyWith(localEventCount: _memoryAnalytics?.eventCount ?? 0));
    }
  }

  Future<void> _trackNotificationOpened() async {
    if (!state.analyticsConsentEnabled) {
      return;
    }
    await _analytics.track(
      AppAnalyticsEvent.notificationOpened(
        mode: state.fcmMode.name,
        source: 'production_readiness',
      ),
    );
    if (!isClosed) {
      emit(state.copyWith(localEventCount: _memoryAnalytics?.eventCount ?? 0));
    }
  }

  @override
  void _startFrameMonitor() {
    final FrameTimingMonitor? monitor = _frameMonitor;
    if (monitor == null) {
      return;
    }
    monitor.start(
      onSummary: (final summary) {
        if (isClosed) {
          return;
        }
        emit(
          state.copyWith(
            frameSampleCount: summary.sampleCount,
            frameP90Ms: summary.p90Ms,
            frameP99Ms: summary.p99Ms,
            framesMissedOver16_7Ms: summary.missedOver16_7Ms,
          ),
        );
      },
    );
  }
}
