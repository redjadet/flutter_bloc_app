import 'package:flutter_bloc_app/features/in_app_purchase_demo/data/fake_in_app_purchase_repository.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/data/iap_demo_credits_store.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_demo_controls.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_product.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_helpers.dart' as test_helpers;

void main() {
  group('IAP demo credits persistence', () {
    late HiveService hiveService;
    late IapDemoCreditsStore store;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await test_helpers.setupHiveForTesting();
    });

    setUp(() async {
      hiveService = await test_helpers.createHiveService();
      store = HiveIapDemoCreditsStore(hiveService: hiveService);
    });

    tearDown(() async {
      await test_helpers.cleanupHiveBoxes(<String>['iap_demo']);
    });

    test('credits survive creating a new repository instance', () async {
      final repo1 = FakeInAppPurchaseRepository(
        timerService: test_helpers.FakeTimerService(),
        delay: Duration.zero,
        creditsStore: store,
      )..forcedOutcome = IapDemoForcedOutcome.success;
      addTearDown(repo1.dispose);

      final products = await repo1.loadProducts();
      final creditsProduct = products.firstWhere(
        (p) => p.id == IapDemoProductIds.consumableCredits100,
      );

      await repo1.purchase(creditsProduct);
      final afterPurchase = await repo1.refreshEntitlements();
      expect(afterPurchase.credits, 100);

      final repo2 = FakeInAppPurchaseRepository(
        timerService: test_helpers.FakeTimerService(),
        delay: Duration.zero,
        creditsStore: store,
      );
      addTearDown(repo2.dispose);

      final loaded = await repo2.refreshEntitlements();
      expect(loaded.credits, 100);
    });
  });
}
