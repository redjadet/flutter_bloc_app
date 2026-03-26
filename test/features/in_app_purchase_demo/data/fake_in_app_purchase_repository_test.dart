import 'package:flutter_bloc_app/features/in_app_purchase_demo/data/fake_in_app_purchase_repository.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_demo_controls.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_product.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_helpers.dart';

void main() {
  group('FakeInAppPurchaseRepository', () {
    test('loadProducts returns all three IAP types', () async {
      final repo = FakeInAppPurchaseRepository(
        timerService: FakeTimerService(),
        delay: Duration.zero,
      );
      addTearDown(repo.dispose);

      final products = await repo.loadProducts();
      expect(products.any((p) => p.type == IapProductType.consumable), isTrue);
      expect(
        products.any((p) => p.type == IapProductType.nonConsumable),
        isTrue,
      );
      expect(
        products.any((p) => p.type == IapProductType.subscription),
        isTrue,
      );
    });

    test('forced success increments entitlements appropriately', () async {
      final repo = FakeInAppPurchaseRepository(
        clockNow: () => DateTime(2026, 1, 1),
        timerService: FakeTimerService(),
        delay: Duration.zero,
      );
      addTearDown(repo.dispose);
      repo.forcedOutcome = IapDemoForcedOutcome.success;

      final products = await repo.loadProducts();
      final consumable = products.firstWhere(
        (p) => p.id == IapDemoProductIds.consumableCredits100,
      );
      final nonConsumable = products.firstWhere(
        (p) => p.id == IapDemoProductIds.nonConsumablePremium,
      );
      final subscription = products.firstWhere(
        (p) => p.id == IapDemoProductIds.subscriptionMonthly,
      );

      await repo.purchase(consumable);
      var entitlements = await repo.refreshEntitlements();
      expect(entitlements.credits, 100);

      await repo.purchase(nonConsumable);
      entitlements = await repo.refreshEntitlements();
      expect(entitlements.isPremiumOwned, isTrue);

      await repo.purchase(subscription);
      entitlements = await repo.refreshEntitlements();
      expect(entitlements.isSubscriptionActive, isTrue);
      expect(entitlements.subscriptionExpiry, DateTime(2026, 1, 31));
    });

    test('restorePurchases does not promise consumable restore', () async {
      final repo = FakeInAppPurchaseRepository(
        clockNow: () => DateTime(2026, 1, 1),
        timerService: FakeTimerService(),
        delay: Duration.zero,
      );
      addTearDown(repo.dispose);

      await repo.restorePurchases();
      final entitlements = await repo.refreshEntitlements();
      expect(entitlements.isPremiumOwned, isTrue);
      expect(entitlements.isSubscriptionActive, isTrue);
      // credits are tracked locally; restore doesn't change consumable balance
      expect(entitlements.credits, 0);
    });
  });
}
