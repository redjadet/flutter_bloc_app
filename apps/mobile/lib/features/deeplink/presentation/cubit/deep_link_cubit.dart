import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/utils/bloc/cubit_subscription_mixin.dart';
import 'package:flutter_bloc_app/app/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_parser.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_service.dart';
import 'package:flutter_bloc_app/features/deeplink/presentation/cubit/deep_link_state.dart';

/// Handles incoming deep/universal links and exposes navigation events.
class DeepLinkCubit extends Cubit<DeepLinkState>
    with CubitSubscriptionMixin<DeepLinkState> {
  DeepLinkCubit({required this._service, required this._parser})
    : super(const DeepLinkState.idle());

  final DeepLinkService _service;
  final DeepLinkParser _parser;

  // ignore: cancel_subscriptions - Subscription is managed by CubitSubscriptionMixin
  StreamSubscription<Uri>? _subscription;
  bool _initialized = false;
  bool _isInitializing = false;
  int _consecutiveFailureCount = 0;

  /// Begins listening to deep link events. Safe to call multiple times.
  Future<void> initialize() async {
    if (_initialized || _isInitializing) {
      return;
    }
    _isInitializing = true;
    AppLogger.info('Initializing deep link cubit');
    if (!isClosed) {
      emit(const DeepLinkState.loading());
    }

    try {
      await CubitExceptionHandler.executeAsyncVoid(
        operation: _startListening,
        isAlive: () => !isClosed,
        logContext: 'DeepLinkCubit.initialize',
        onSuccess: () {
          _initialized = true;
          _consecutiveFailureCount = 0;
          AppLogger.info('Deep link cubit initialized successfully');
          if (!isClosed && state is! DeepLinkIdle) {
            emit(const DeepLinkState.idle());
          }
        },
        onError: (_) {},
        onErrorWithDetails: _handleInitializeError,
      );
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> retryInitialize() async {
    AppLogger.info('Retrying deep link initialization');
    await _disposeSubscription();
    _initialized = false;
    await initialize();
  }

  Future<void> _startListening() async {
    final Uri? initialUri = await _service.getInitialLink();
    if (isClosed) return;
    if (initialUri != null) {
      AppLogger.event(
        AppLogLevel.info,
        'deeplink.initial',
        fields: _uriFields(initialUri),
      );
      _handleUri(initialUri, DeepLinkOrigin.initial);
    }

    await _disposeSubscription();
    _subscription = registerSubscription(
      _service.linkStream().listen(
        (uri) {
          AppLogger.event(
            AppLogLevel.info,
            'deeplink.stream',
            fields: _uriFields(uri),
          );
          _handleUri(uri, DeepLinkOrigin.resumed);
        },
        onError: (Object error, StackTrace stackTrace) {
          _consecutiveFailureCount++;
          AppLogger.event(
            AppLogLevel.error,
            'deeplink.stream_failed',
            fields: {'count': _consecutiveFailureCount},
            error: error,
            stackTrace: stackTrace,
          );
          _logFailureTelemetry(error);
          unawaited(_disposeSubscription());
          _initialized = false;
          if (isClosed) {
            return;
          }
          emit(DeepLinkState.error(error.toString()));
        },
      ),
    );
  }

  void _handleUri(Uri uri, DeepLinkOrigin origin) {
    AppLogger.event(
      AppLogLevel.info,
      'deeplink.received',
      fields: {..._uriFields(uri), 'origin': origin.name},
    );
    final target = _parser.parse(uri);
    if (target == null) {
      AppLogger.event(
        AppLogLevel.warning,
        'deeplink.unsupported',
        fields: _uriFields(uri),
      );
      return;
    }
    AppLogger.event(
      AppLogLevel.info,
      'deeplink.parsed',
      fields: {..._uriFields(uri), 'target': target.name},
    );
    if (isClosed) return;
    emit(DeepLinkState.navigate(target, origin));
    if (isClosed) return;
    emit(const DeepLinkState.idle());
  }

  @override
  Future<void> close() async {
    await _disposeSubscription();
    return super.close();
  }

  Future<void> _disposeSubscription() async {
    final StreamSubscription<Uri>? subscription = _subscription;
    _subscription = null;
    await cancelRegisteredSubscription(subscription);
  }

  void _handleInitializeError(
    Object error,
    StackTrace? stackTrace,
  ) {
    _consecutiveFailureCount++;
    AppLogger.error('Deep link initialization failed', error, stackTrace);
    _logFailureTelemetry(error);
    unawaited(_disposeSubscription());
    _initialized = false;
    if (!isClosed) {
      emit(DeepLinkState.error(error.toString()));
    }
  }

  void _logFailureTelemetry(Object error) {
    if (_consecutiveFailureCount == 3) {
      AppLogger.event(
        AppLogLevel.warning,
        'deeplink.init_failed_streak',
        fields: {'count': 3},
        error: error,
      );
    } else if (_consecutiveFailureCount == 5) {
      AppLogger.event(
        AppLogLevel.warning,
        'deeplink.init_failed_streak',
        fields: {'count': 5},
        error: error,
      );
    } else if (_consecutiveFailureCount >= 10 &&
        _consecutiveFailureCount % 5 == 0) {
      AppLogger.event(
        AppLogLevel.warning,
        'deeplink.init_failed_streak',
        fields: {'count': _consecutiveFailureCount},
        error: error,
      );
    }
  }

  Map<String, Object?> _uriFields(Uri uri) => {
    'scheme': uri.scheme,
    'host': uri.host,
    'path': uri.path,
  };
}
