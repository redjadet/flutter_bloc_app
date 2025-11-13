import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_service.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:meta/meta.dart';

/// Deep link service backed by the `app_links` plugin.
class AppLinksDeepLinkService implements DeepLinkService {
  AppLinksDeepLinkService({final AppLinksApi? api})
    : _api = api ?? DefaultAppLinksApi();

  final AppLinksApi _api;
  static bool _pluginAvailable = true;

  @override
  Stream<Uri> linkStream() {
    if (!_pluginAvailable) {
      return const Stream<Uri>.empty();
    }

    final StreamController<Uri> controller = StreamController<Uri>.broadcast();

    controller.onListen = () {
      // Store subscription in a variable accessible to both onListen and onCancel
      // Subscription cancellation is handled by onCancel callback below.
      // onCancel is guaranteed to be called when the stream has no more listeners,
      // ensuring the subscription is properly cancelled even if this function exits early.
      // ignore: cancel_subscriptions
      StreamSubscription<Uri?>? subscription;

      Future<void> cancelSubscription() async {
        final StreamSubscription<Uri?>? sub = subscription;
        subscription = null;
        try {
          await sub?.cancel();
        } on Object {
          // Ignore cancellation errors (subscription might already be cancelled)
        }
      }

      Future<void> closeDueToMissingPlugin() async {
        _pluginAvailable = false;
        await cancelSubscription();
        if (!controller.isClosed) {
          await controller.close();
        }
      }

      // Set up cancellation handler - this will be called when listeners unsubscribe
      controller.onCancel = cancelSubscription;

      try {
        subscription = _api.uriLinkStream.listen(
          (final Uri? uri) {
            if (uri != null && !controller.isClosed) {
              controller.add(uri);
            }
          },
          onError: (final Object error, final StackTrace stackTrace) {
            if (error is MissingPluginException) {
              unawaited(closeDueToMissingPlugin());
              return;
            }
            AppLogger.error('Failed to receive deep link', error, stackTrace);
          },
        );
      } on MissingPluginException {
        unawaited(closeDueToMissingPlugin());
      }
    };

    return controller.stream;
  }

  @override
  Future<Uri?> getInitialLink() async {
    try {
      return await _api.getInitialUri();
    } on PlatformException catch (error, stackTrace) {
      AppLogger.error('Failed to read initial deep link', error, stackTrace);
      return null;
    } on MissingPluginException {
      // Happens in widget tests where the plugin channel is not registered.
      _pluginAvailable = false;
      return null;
    } on FormatException catch (error, stackTrace) {
      AppLogger.error('Malformed initial deep link', error, stackTrace);
      return null;
    }
  }

  @visibleForTesting
  static void debugResetPluginAvailability() {
    _pluginAvailable = true;
  }
}

/// Abstraction over the `app_links` plugin to ease testing.
abstract class AppLinksApi {
  Stream<Uri?> get uriLinkStream;
  Future<Uri?> getInitialUri();
}

class DefaultAppLinksApi implements AppLinksApi {
  DefaultAppLinksApi() : _appLinks = AppLinks();

  final AppLinks _appLinks;

  @override
  Stream<Uri?> get uriLinkStream => _appLinks.uriLinkStream;

  @override
  Future<Uri?> getInitialUri() => _appLinks.getInitialLink();
}
