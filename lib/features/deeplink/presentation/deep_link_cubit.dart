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

  /// Begins listening to deep link events. Safe to call multiple times.
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    AppLogger.info('Initializing deep link cubit');

    final Uri? initialUri = await _service.getInitialLink();
    if (initialUri != null) {
      AppLogger.info('Found initial URI: $initialUri');
      _handleUri(initialUri, DeepLinkOrigin.initial);
    }

    _subscription = _service.linkStream().listen(
      (final Uri uri) {
        AppLogger.info('Received deep link from stream: $uri');
        _handleUri(uri, DeepLinkOrigin.resumed);
      },
      onError: (final Object error, final StackTrace stackTrace) {
        AppLogger.error('Deep link stream error', error, stackTrace);
      },
    );

    AppLogger.info('Deep link cubit initialized successfully');
  }

  void _handleUri(final Uri uri, final DeepLinkOrigin origin) {
    AppLogger.info('Deep link received: $uri (origin: $origin)');
    final target = _parser.parse(uri);
    if (target == null) {
      AppLogger.warning('Unsupported deep link: $uri');
      return;
    }
    AppLogger.info('Deep link parsed to target: ${target.location}');
    emit(DeepLinkNavigate(target, origin));
    emit(const DeepLinkIdle());
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
