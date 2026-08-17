import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc_app/app/analytics/analytics_consent_repository.dart';
import 'package:flutter_bloc_app/app/analytics/composite_product_analytics.dart';
import 'package:flutter_bloc_app/app/analytics/firebase_product_analytics.dart';
import 'package:flutter_bloc_app/app/analytics/in_memory_product_analytics.dart';
import 'package:flutter_bloc_app/app/analytics/plugin_firebase_analytics_gateway.dart';
import 'package:flutter_bloc_app/app/analytics/product_analytics.dart';
import 'package:flutter_bloc_app/app/analytics/shared_preferences_analytics_consent_repository.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';

/// Registers consent + composite product analytics (memory always; Firebase when live).
Future<void> registerAnalyticsServices() async {
  registerLazySingletonIfAbsent<AnalyticsConsentRepository>(
    SharedPreferencesAnalyticsConsentRepository.new,
    dispose: (repository) => repository.dispose(),
  );
  registerLazySingletonIfAbsent<InMemoryProductAnalytics>(
    InMemoryProductAnalytics.new,
  );
  registerLazySingletonIfAbsent<ProductAnalytics>(() {
    final InMemoryProductAnalytics memory = getIt<InMemoryProductAnalytics>();
    if (Firebase.apps.isEmpty) {
      return memory;
    }
    return CompositeProductAnalytics(
      memory: memory,
      delegate: FirebaseProductAnalytics(PluginFirebaseAnalyticsGateway()),
    );
  });

  final bool enabled = await getIt<AnalyticsConsentRepository>().load();
  await getIt<ProductAnalytics>().setCollectionEnabled(enabled: enabled);
}
