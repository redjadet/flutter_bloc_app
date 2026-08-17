import 'package:flutter_bloc_app/app/analytics/app_analytics_event.dart';
import 'package:flutter_bloc_app/app/analytics/in_memory_product_analytics.dart';
import 'package:flutter_bloc_app/app/analytics/product_analytics.dart';

/// Always records to [memory] for demo counts; optionally forwards to Firebase.
class CompositeProductAnalytics implements ProductAnalytics {
  CompositeProductAnalytics({
    required this.memory,
    this.delegate,
  });

  final InMemoryProductAnalytics memory;
  final ProductAnalytics? delegate;

  @override
  Future<void> setCollectionEnabled({required bool enabled}) async {
    await memory.setCollectionEnabled(enabled: enabled);
    await delegate?.setCollectionEnabled(enabled: enabled);
  }

  @override
  Future<void> track(AppAnalyticsEvent event) async {
    await memory.track(event);
    await delegate?.track(event);
  }
}
