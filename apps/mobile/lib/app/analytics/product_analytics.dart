import 'package:flutter_bloc_app/app/analytics/app_analytics_event.dart';

/// App-level product analytics port (consent-gated).
abstract class ProductAnalytics {
  Future<void> setCollectionEnabled({required bool enabled});

  Future<void> track(AppAnalyticsEvent event);
}
