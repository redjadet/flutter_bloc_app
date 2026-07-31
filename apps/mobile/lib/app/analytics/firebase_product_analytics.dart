import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter_bloc_app/app/analytics/app_analytics_event.dart';
import 'package:flutter_bloc_app/app/analytics/product_analytics.dart';

/// Thin gateway so unit tests can fake Firebase Analytics without plugins.
abstract class FirebaseAnalyticsGateway {
  Future<void> setAnalyticsCollectionEnabled({required bool enabled});

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  });
}

/// Firebase Analytics adapter. No-ops tracks while collection is disabled.
///
/// Platform channel failures (tests / missing plugin) are logged once then
/// swallowed so DI bootstrap never aborts the rest of app registration.
class FirebaseProductAnalytics implements ProductAnalytics {
  FirebaseProductAnalytics(this._gateway);

  final FirebaseAnalyticsGateway _gateway;
  bool _collectionEnabled = false;
  bool _gatewayUnavailable = false;

  bool get collectionEnabled => _collectionEnabled;

  @override
  Future<void> setCollectionEnabled({required final bool enabled}) async {
    _collectionEnabled = enabled;
    if (_gatewayUnavailable) {
      return;
    }
    try {
      await _gateway.setAnalyticsCollectionEnabled(enabled: enabled);
    } on Object catch (error) {
      AppLogger.warning(
        '${IntegrationLogMessages.firebaseAnalyticsGatewayUnavailablePrefix} '
        '(setCollectionEnabled): $error',
      );
      _gatewayUnavailable = true;
    }
  }

  @override
  Future<void> track(final AppAnalyticsEvent event) async {
    if (!_collectionEnabled || _gatewayUnavailable) {
      return;
    }
    AppAnalyticsEvent.validateParameters(event.parameters);
    try {
      await _gateway.logEvent(
        name: event.name,
        parameters: Map<String, Object>.from(event.parameters),
      );
    } on Object catch (error) {
      AppLogger.warning(
        '${IntegrationLogMessages.firebaseAnalyticsGatewayUnavailablePrefix} '
        '(logEvent): $error',
      );
      _gatewayUnavailable = true;
    }
  }
}
