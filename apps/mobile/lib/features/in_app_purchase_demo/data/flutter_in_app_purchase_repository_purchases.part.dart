part of 'flutter_in_app_purchase_repository.dart';

extension _FlutterInAppPurchaseRepositoryPurchases
    on FlutterInAppPurchaseRepository {
  void ensurePurchaseSubscriptionImpl() {
    _purchaseSub ??= _store.purchaseStream.listen(
      onPurchaseUpdatesImpl,
      onError: onPurchaseStreamErrorImpl,
    );
  }

  void onPurchaseStreamErrorImpl(
    Object error,
    StackTrace stackTrace,
  ) {
    AppLogger.error(
      'FlutterInAppPurchaseRepository.purchaseStream',
      error,
      stackTrace,
    );
    if (_resultsController.isClosed) {
      return;
    }
    _resultsController.add(
      IapPurchaseResult.failure(
        productId: IapDemoProductIds.unknownPurchaseStream,
        message: error.toString(),
      ),
    );
  }

  Future<void> onPurchaseUpdatesImpl(
    List<PurchaseDetails> purchases,
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

  IapEntitlements applyEntitlementImpl(String productId) {
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
    IapPurchaseResult r,
    String id,
  ) => r.when(
    success: (productId, message) => productId == id,
    cancelled: (productId, message) => productId == id,
    pending: (productId, message) => productId == id,
    failure: (productId, message) => productId == id,
  );

  static bool isTerminalImpl(IapPurchaseResult r) => r.maybeWhen(
    pending: (productId, message) => false,
    orElse: () => true,
  );
}
