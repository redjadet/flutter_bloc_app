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
    @Default(InAppPurchaseDemoStatus.initial) InAppPurchaseDemoStatus status,
    @Default(<IapProduct>[]) List<IapProduct> products,
    @Default(IapEntitlements()) IapEntitlements entitlements,
    IapPurchaseResult? lastResult,
    String? errorMessage,
    @Default(true) bool useFakeRepository,
    @Default(IapDemoForcedOutcome.deterministic)
    IapDemoForcedOutcome forcedOutcome,
    @Default(false) bool isBusy,
  }) = _InAppPurchaseDemoState;

  const InAppPurchaseDemoState._();
}
