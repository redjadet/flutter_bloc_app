import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_parser.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_service.dart';
import 'package:flutter_bloc_app/features/deeplink/presentation/deep_link_state.dart';
import 'package:flutter_bloc_app/features/deeplink/presentation/deep_link_target_extensions.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Handles incoming deep/universal links and exposes navigation events.
class DeepLinkCubit extends Cubit<DeepLinkState> {
  DeepLinkCubit({
    required final DeepLinkService service,
    required final DeepLinkParser parser,
  }) : _service = service,
       _parser = parser,
       super(const DeepLinkIdle());

  final DeepLinkService _service;
  final DeepLinkParser _parser;

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
      emit(const DeepLinkLoading());
    }

    try {
      await _startListening();
      _initialized = true;
      _consecutiveFailureCount = 0;
      AppLogger.info('Deep link cubit initialized successfully');
      if (!isClosed && state is! DeepLinkIdle) {
        emit(const DeepLinkIdle());
      }
    } on Object catch (error, stackTrace) {
      _consecutiveFailureCount++;
      AppLogger.error('Deep link initialization failed', error, stackTrace);
      _logFailureTelemetry(error);
      await _disposeSubscription();
      _initialized = false;
      if (!isClosed) {
        emit(DeepLinkError(error.toString()));
      }
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
    if (initialUri != null) {
      AppLogger.info('Found initial URI: $initialUri');
      _handleUri(initialUri, DeepLinkOrigin.initial);
    }

    await _disposeSubscription();
    _subscription = _service.linkStream().listen(
      (final Uri uri) {
        AppLogger.info('Received deep link from stream: $uri');
        _handleUri(uri, DeepLinkOrigin.resumed);
      },
      onError: (final Object error, final StackTrace stackTrace) {
        _consecutiveFailureCount++;
        AppLogger.error('Deep link stream error', error, stackTrace);
        _logFailureTelemetry(error);
        unawaited(_disposeSubscription());
        _initialized = false;
        if (isClosed) {
          return;
        }
        emit(DeepLinkError(error.toString()));
      },
    );
  }

  void _handleUri(final Uri uri, final DeepLinkOrigin origin) {
    AppLogger.info('Deep link received: $uri (origin: $origin)');
    final target = _parser.parse(uri);
    if (target == null) {
      AppLogger.warning('Unsupported deep link: $uri');
      return;
    }
    AppLogger.info('Deep link parsed to target: ${target.location}');
    if (isClosed) return;
    emit(DeepLinkNavigate(target, origin));
    if (isClosed) return;
    emit(const DeepLinkIdle());
  }

  @override
  Future<void> close() async {
    await _disposeSubscription();
    return super.close();
  }

  Future<void> _disposeSubscription() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  void _logFailureTelemetry(final Object error) {
    if (_consecutiveFailureCount == 3) {
      AppLogger.warning(
        'Deep link initialization has failed 3 consecutive times. '
        'This may indicate a platform configuration issue. '
        'Last error: $error',
      );
    } else if (_consecutiveFailureCount == 5) {
      AppLogger.warning(
        'Deep link initialization has failed 5 consecutive times. '
        'Platform misconfiguration likely. Consider checking deep link setup. '
        'Last error: $error',
      );
    } else if (_consecutiveFailureCount >= 10 &&
        _consecutiveFailureCount % 5 == 0) {
      AppLogger.warning(
        'Deep link initialization has failed $_consecutiveFailureCount '
        'consecutive times. Persistent platform issue detected. '
        'Last error: $error',
      );
    }
  }
}
