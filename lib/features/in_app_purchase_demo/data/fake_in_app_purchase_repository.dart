import 'dart:async';

import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/data/iap_demo_credits_store.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_demo_controls.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_entitlement.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_product.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_purchase_result.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/in_app_purchase_repository.dart';

class FakeInAppPurchaseRepository implements InAppPurchaseRepository {
  FakeInAppPurchaseRepository({
    required final TimerService timerService,
    final IapDemoCreditsStore? creditsStore,
    this.delay = const Duration(milliseconds: 450),
    this.clockNow,
  }) : _timerService = timerService,
       _creditsStore = creditsStore ?? InMemoryIapDemoCreditsStore();

  final Duration delay;
  final DateTime Function()? clockNow;
  final TimerService _timerService;
  final IapDemoCreditsStore _creditsStore;

  final StreamController<IapPurchaseResult> _resultsController =
      StreamController<IapPurchaseResult>.broadcast();

  IapDemoForcedOutcome forcedOutcome = IapDemoForcedOutcome.deterministic;

  IapEntitlements _entitlements = const IapEntitlements();

  void resetDemoState() {
    _entitlements = _entitlements.copyWith(
      isPremiumOwned: false,
      isSubscriptionActive: false,
      subscriptionExpiry: null,
    );
    forcedOutcome = IapDemoForcedOutcome.deterministic;
  }

  @override
  Future<List<IapProduct>> loadProducts() async => const <IapProduct>[
    IapProduct(
      id: IapDemoProductIds.consumableCredits100,
      title: '100 Credits',
      description: 'Adds 100 demo credits.',
      priceLabel: r'$0.99',
      type: IapProductType.consumable,
    ),
    IapProduct(
      id: IapDemoProductIds.nonConsumablePremium,
      title: 'Premium Unlock',
      description: 'One-time premium unlock.',
      priceLabel: r'$4.99',
      type: IapProductType.nonConsumable,
    ),
    IapProduct(
      id: IapDemoProductIds.subscriptionMonthly,
      title: 'Pro Monthly',
      description: 'Monthly subscription (demo).',
      priceLabel: r'$1.99',
      type: IapProductType.subscription,
    ),
  ];

  @override
  Stream<IapPurchaseResult> watchPurchaseResults() => _resultsController.stream;

  @override
  Future<IapPurchaseResult> purchase(final IapProduct product) async {
    await _sleep(delay);
    final outcome = _resolveOutcome(product.id);

    late final IapPurchaseResult result;
    switch (outcome) {
      case IapDemoForcedOutcome.success:
        _entitlements = _applyEntitlement(product);
        if (product.type == IapProductType.consumable) {
          await _creditsStore.saveCredits(_entitlements.credits);
        }
        result = IapPurchaseResult.success(productId: product.id);
        break;
      case IapDemoForcedOutcome.cancelled:
        result = IapPurchaseResult.cancelled(productId: product.id);
        break;
      case IapDemoForcedOutcome.pending:
        result = IapPurchaseResult.pending(productId: product.id);
        break;
      case IapDemoForcedOutcome.failure:
        result = IapPurchaseResult.failure(
          productId: product.id,
          message: 'Simulated purchase failure.',
        );
        break;
      case IapDemoForcedOutcome.deterministic:
        // unreachable: _resolveOutcome never returns deterministic
        result = IapPurchaseResult.failure(
          productId: product.id,
          message: 'Invalid fake outcome.',
        );
        break;
    }

    _resultsController.add(result);
    return result;
  }

  @override
  Future<void> restorePurchases() async {
    await _sleep(delay);
    // Restore is meaningful for non-consumables/subscriptions.
    _entitlements = _entitlements.copyWith(
      isPremiumOwned: true,
      isSubscriptionActive: true,
      subscriptionExpiry: _now().add(const Duration(days: 30)),
    );
  }

  @override
  Future<IapEntitlements> refreshEntitlements() async {
    final int credits = await _creditsStore.loadCredits();
    if (_entitlements.credits != credits) {
      _entitlements = _entitlements.copyWith(credits: credits);
    }
    return _entitlements;
  }

  Future<void> dispose() async {
    await _resultsController.close();
  }

  IapDemoForcedOutcome _resolveOutcome(final String productId) {
    if (forcedOutcome != IapDemoForcedOutcome.deterministic) {
      return forcedOutcome;
    }
    // Demo-friendly default: deterministic always succeeds, so the "Buy" flow
    // behaves predictably. Use the dropdown to force failure/cancel/pending.
    return IapDemoForcedOutcome.success;
  }

  IapEntitlements _applyEntitlement(final IapProduct product) {
    switch (product.type) {
      case IapProductType.consumable:
        return _entitlements.copyWith(credits: _entitlements.credits + 100);
      case IapProductType.nonConsumable:
        return _entitlements.copyWith(isPremiumOwned: true);
      case IapProductType.subscription:
        return _entitlements.copyWith(
          isSubscriptionActive: true,
          subscriptionExpiry: _now().add(const Duration(days: 30)),
        );
    }
  }

  DateTime _now() => (clockNow ?? DateTime.now)();

  Future<void> _sleep(final Duration d) {
    if (d <= Duration.zero) return Future<void>.value();
    final completer = Completer<void>();
    _timerService.runOnce(d, completer.complete);
    return completer.future;
  }
}
