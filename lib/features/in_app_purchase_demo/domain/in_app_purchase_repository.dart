import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_entitlement.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_product.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_purchase_result.dart';

abstract interface class InAppPurchaseRepository {
  Future<List<IapProduct>> loadProducts();

  /// Emits purchase results (success/pending/cancelled/failure) from store updates.
  ///
  /// Fake repository emits results when [purchase] is called.
  Stream<IapPurchaseResult> watchPurchaseResults();

  Future<IapPurchaseResult> purchase(final IapProduct product);

  Future<void> restorePurchases();

  Future<IapEntitlements> refreshEntitlements();
}
