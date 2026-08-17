import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc_app/app/analytics/firebase_product_analytics.dart';

/// Production gateway wrapping [FirebaseAnalytics].
class PluginFirebaseAnalyticsGateway implements FirebaseAnalyticsGateway {
  PluginFirebaseAnalyticsGateway([FirebaseAnalytics? analytics])
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> setAnalyticsCollectionEnabled({required bool enabled}) =>
      _analytics.setAnalyticsCollectionEnabled(enabled);

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) => _analytics.logEvent(name: name, parameters: parameters);
}
