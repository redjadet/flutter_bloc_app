import 'dart:collection';

import 'package:flutter_bloc_app/app/analytics/app_analytics_event.dart';
import 'package:flutter_bloc_app/app/analytics/product_analytics.dart';

/// Bounded in-memory analytics for deterministic demo UI event counts.
class InMemoryProductAnalytics implements ProductAnalytics {
  InMemoryProductAnalytics({this.maxEvents = 50});

  final int maxEvents;

  bool _collectionEnabled = false;
  final Queue<AppAnalyticsEvent> _events = Queue<AppAnalyticsEvent>();

  bool get collectionEnabled => _collectionEnabled;

  int get eventCount => _events.length;

  List<AppAnalyticsEvent> get events =>
      List<AppAnalyticsEvent>.unmodifiable(_events);

  @override
  Future<void> setCollectionEnabled({required bool enabled}) async {
    _collectionEnabled = enabled;
    if (!enabled) {
      _events.clear();
    }
  }

  @override
  Future<void> track(AppAnalyticsEvent event) async {
    if (!_collectionEnabled) {
      return;
    }
    AppAnalyticsEvent.validateParameters(event.parameters);
    _events.addLast(event);
    while (_events.length > maxEvents) {
      _events.removeFirst();
    }
  }
}
