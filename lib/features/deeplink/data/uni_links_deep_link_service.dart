import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_service.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:uni_links/uni_links.dart' as uni_links;

/// Deep link service backed by the `uni_links` plugin.
class UniLinksDeepLinkService implements DeepLinkService {
  const UniLinksDeepLinkService();

  static bool _pluginAvailable = true;

  @override
  Stream<Uri> linkStream() {
    if (!_pluginAvailable) {
      return const Stream<Uri>.empty();
    }

    final controller = StreamController<Uri>.broadcast();

    controller.onListen = () {
      StreamSubscription<Uri?>? subscription;
      try {
        subscription = uni_links.uriLinkStream.listen(
          (Uri? uri) {
            if (uri != null && !controller.isClosed) {
              controller.add(uri);
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            if (error is MissingPluginException) {
              controller.close();
              return;
            }
            AppLogger.error('Failed to receive deep link', error, stackTrace);
          },
        );
      } on MissingPluginException {
        _pluginAvailable = false;
        controller.close();
        return;
      }

      controller.onCancel = () async {
        await subscription?.cancel();
      };
    };

    return controller.stream;
  }

  @override
  Future<Uri?> getInitialLink() async {
    try {
      return await uni_links.getInitialUri();
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
}
