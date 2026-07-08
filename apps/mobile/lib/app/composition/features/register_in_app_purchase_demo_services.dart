import 'package:core/core.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/data/fake_in_app_purchase_repository.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/data/flutter_in_app_purchase_repository.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/data/iap_demo_credits_store.dart';
import 'package:storage/storage.dart';

void registerInAppPurchaseDemoServices() {
  registerLazySingletonIfAbsent<IapDemoCreditsStore>(
    () => HiveIapDemoCreditsStore(hiveService: getIt<HiveService>()),
  );
  registerLazySingletonIfAbsent<FakeInAppPurchaseRepository>(
    () => FakeInAppPurchaseRepository(
      timerService: getIt<TimerService>(),
      creditsStore: getIt<IapDemoCreditsStore>(),
    ),
    dispose: (final repo) => repo.dispose(),
  );
  registerLazySingletonIfAbsent<FlutterInAppPurchaseRepository>(
    () => FlutterInAppPurchaseRepository(
      creditsStore: getIt<IapDemoCreditsStore>(),
    ),
    dispose: (final repo) => repo.dispose(),
  );
}
