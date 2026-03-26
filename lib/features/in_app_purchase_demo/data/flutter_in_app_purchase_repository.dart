import 'dart:async';

import 'package:flutter_bloc_app/features/in_app_purchase_demo/data/iap_demo_credits_store.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_entitlement.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_product.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_purchase_result.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/in_app_purchase_repository.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Real store-backed implementation using `in_app_purchase`.
///
/// Notes:
/// - This is **demo-grade** and intentionally avoids backend receipt validation.
/// - Premium/subscription entitlements are kept in-memory for now.
/// - Consumable credits are persisted locally (demo UX) via [IapDemoCreditsStore].
class FlutterInAppPurchaseRepository implements InAppPurchaseRepository {
  FlutterInAppPurchaseRepository({
    final InAppPurchase? store,
    final IapDemoCreditsStore? creditsStore,
  }) : _store = store ?? InAppPurchase.instance,
       _creditsStore = creditsStore ?? InMemoryIapDemoCreditsStore();

  final InAppPurchase _store;
  final IapDemoCreditsStore _creditsStore;

  final StreamController<IapPurchaseResult> _resultsController =
      StreamController<IapPurchaseResult>.broadcast();

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  IapEntitlements _entitlements = const IapEntitlements();

  void resetDemoState() {
    _entitlements = _entitlements.copyWith(
      isPremiumOwned: false,
      isSubscriptionActive: false,
      subscriptionExpiry: null,
    );
  }

  @override
  Future<List<IapProduct>> loadProducts() async {
    final bool available = await _store.isAvailable();
    if (!available) {
      return const <IapProduct>[];
    }

    final ProductDetailsResponse response = await _store.queryProductDetails(
      IapDemoProductIds.all.toSet(),
    );

    if (response.error != null) {
      return const <IapProduct>[];
    }

    final Map<String, ProductDetails> byId = <String, ProductDetails>{
      for (final p in response.productDetails) p.id: p,
    };

    IapProduct build(final String id, final IapProductType type) {
      final details = byId[id];
      if (details == null) {
        return IapProduct(
          id: id,
          title: id,
          description: 'Unavailable (create product in store console).',
          priceLabel: '—',
          type: type,
        );
      }
      return IapProduct(
        id: details.id,
        title: details.title,
        description: details.description,
        priceLabel: details.price,
        type: type,
      );
    }

    return <IapProduct>[
      build(IapDemoProductIds.consumableCredits100, IapProductType.consumable),
      build(
        IapDemoProductIds.nonConsumablePremium,
        IapProductType.nonConsumable,
      ),
      build(IapDemoProductIds.subscriptionMonthly, IapProductType.subscription),
    ];
  }

  @override
  Stream<IapPurchaseResult> watchPurchaseResults() {
    _ensurePurchaseSubscription();
    return _resultsController.stream;
  }

  @override
  Future<IapPurchaseResult> purchase(final IapProduct product) async {
    _ensurePurchaseSubscription();
    final bool available = await _store.isAvailable();
    if (!available) {
      return IapPurchaseResult.failure(
        productId: product.id,
        message: 'Store is unavailable on this device.',
      );
    }

    // Best-effort: wait for the corresponding purchase stream result so the
    // UI can update deterministically after a "Buy" tap.
    final Stream<IapPurchaseResult> resultsForProduct = _resultsController
        .stream
        .where((final r) => _matchesProductId(r, product.id))
        .where(_isTerminal)
        .take(1);

    final ProductDetailsResponse response = await _store.queryProductDetails(
      <String>{product.id},
    );
    final ProductDetails? details = response.productDetails.isNotEmpty
        ? response.productDetails.first
        : null;
    if (details == null) {
      return IapPurchaseResult.failure(
        productId: product.id,
        message:
            'Product not found. Configure it in App Store Connect / Play Console.',
      );
    }

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: details);
    switch (product.type) {
      case IapProductType.consumable:
        await _store.buyConsumable(
          purchaseParam: purchaseParam,
        );
        break;
      case IapProductType.nonConsumable:
        await _store.buyNonConsumable(purchaseParam: purchaseParam);
        break;
      case IapProductType.subscription:
        await _store.buyNonConsumable(purchaseParam: purchaseParam);
        break;
    }

    try {
      return await resultsForProduct.first.timeout(
        const Duration(seconds: 12),
        onTimeout: () => IapPurchaseResult.pending(
          productId: product.id,
          message: 'Waiting for store confirmation…',
        ),
      );
    } on Exception {
      // If anything goes wrong while awaiting the stream, fall back to pending.
      return IapPurchaseResult.pending(
        productId: product.id,
        message: 'Waiting for store confirmation…',
      );
    }
  }

  @override
  Future<void> restorePurchases() async {
    _ensurePurchaseSubscription();
    await _store.restorePurchases();
  }

  @override
  Future<IapEntitlements> refreshEntitlements() async {
    final int credits = await _creditsStore.loadCredits();
    if (_entitlements.credits != credits) {
      _entitlements = _entitlements.copyWith(credits: credits);
    }
    return _entitlements;
  }

  void dispose() {
    unawaited(_purchaseSub?.cancel());
    _purchaseSub = null;
    unawaited(_resultsController.close());
  }

  void _ensurePurchaseSubscription() {
    _purchaseSub ??= _store.purchaseStream.listen(
      _onPurchaseUpdates,
      onError: (final Object error, final StackTrace st) {},
    );
  }

  Future<void> _onPurchaseUpdates(final List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      final String productId = purchase.productID;
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _resultsController.add(
            IapPurchaseResult.pending(productId: productId),
          );
          break;
        case PurchaseStatus.canceled:
          _resultsController.add(
            IapPurchaseResult.cancelled(productId: productId),
          );
          break;
        case PurchaseStatus.error:
          _resultsController.add(
            IapPurchaseResult.failure(
              productId: productId,
              message: purchase.error?.message ?? 'Purchase error.',
            ),
          );
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _entitlements = _applyEntitlement(productId);
          if (productId == IapDemoProductIds.consumableCredits100) {
            await _creditsStore.saveCredits(_entitlements.credits);
          }
          _resultsController.add(
            IapPurchaseResult.success(productId: productId),
          );
          if (purchase.pendingCompletePurchase) {
            await _store.completePurchase(purchase);
          }
          break;
      }
    }
  }

  IapEntitlements _applyEntitlement(final String productId) {
    if (productId == IapDemoProductIds.consumableCredits100) {
      return _entitlements.copyWith(credits: _entitlements.credits + 100);
    }
    if (productId == IapDemoProductIds.nonConsumablePremium) {
      return _entitlements.copyWith(isPremiumOwned: true);
    }
    if (productId == IapDemoProductIds.subscriptionMonthly) {
      // Best-effort demo expiry; real apps should validate via backend.
      return _entitlements.copyWith(
        isSubscriptionActive: true,
        subscriptionExpiry: DateTime.now().add(const Duration(days: 30)),
      );
    }
    return _entitlements;
  }

  static bool _matchesProductId(final IapPurchaseResult r, final String id) =>
      r.when(
        success: (final productId, final message) => productId == id,
        cancelled: (final productId, final message) => productId == id,
        pending: (final productId, final message) => productId == id,
        failure: (final productId, final message) => productId == id,
      );

  static bool _isTerminal(final IapPurchaseResult r) => r.maybeWhen(
    pending: (final productId, final message) => false,
    orElse: () => true,
  );
}
