part of 'flutter_in_app_purchase_repository.dart';

extension _FlutterInAppPurchaseRepositoryPurchases
    on FlutterInAppPurchaseRepository {
  void ensurePurchaseSubscriptionImpl() {
    _purchaseSub ??= _store.purchaseStream.listen(
      onPurchaseUpdatesImpl,
      onError: (final Object error, final StackTrace st) {},
    );
  }

  Future<void> onPurchaseUpdatesImpl(
    final List<PurchaseDetails> purchases,
  ) async {
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
          _entitlements = applyEntitlementImpl(productId);
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

  IapEntitlements applyEntitlementImpl(final String productId) {
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

  static bool matchesProductIdImpl(
    final IapPurchaseResult r,
    final String id,
  ) => r.when(
    success: (final productId, final message) => productId == id,
    cancelled: (final productId, final message) => productId == id,
    pending: (final productId, final message) => productId == id,
    failure: (final productId, final message) => productId == id,
  );

  static bool isTerminalImpl(final IapPurchaseResult r) => r.maybeWhen(
    pending: (final productId, final message) => false,
    orElse: () => true,
  );
}
