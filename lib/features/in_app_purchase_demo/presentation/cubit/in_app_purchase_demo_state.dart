import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_demo_controls.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_entitlement.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_product.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_purchase_result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'in_app_purchase_demo_state.freezed.dart';

enum InAppPurchaseDemoStatus {
  initial,
  loadingProducts,
  ready,
  purchasing,
  restoring,
  error,
}

@freezed
abstract class InAppPurchaseDemoState with _$InAppPurchaseDemoState {
  const factory InAppPurchaseDemoState({
    @Default(InAppPurchaseDemoStatus.initial)
    final InAppPurchaseDemoStatus status,
    @Default(<IapProduct>[]) final List<IapProduct> products,
    @Default(IapEntitlements()) final IapEntitlements entitlements,
    final IapPurchaseResult? lastResult,
    final String? errorMessage,
    @Default(true) final bool useFakeRepository,
    @Default(IapDemoForcedOutcome.deterministic)
    final IapDemoForcedOutcome forcedOutcome,
    @Default(false) final bool isBusy,
  }) = _InAppPurchaseDemoState;
}
