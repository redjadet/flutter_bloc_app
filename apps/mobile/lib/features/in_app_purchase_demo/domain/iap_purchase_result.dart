import 'package:freezed_annotation/freezed_annotation.dart';

part 'iap_purchase_result.freezed.dart';

@freezed
abstract class IapPurchaseResult with _$IapPurchaseResult {
  const factory IapPurchaseResult.success({
    required String productId,
    String? message,
  }) = _IapPurchaseSuccess;

  const factory IapPurchaseResult.cancelled({
    required String productId,
    String? message,
  }) = _IapPurchaseCancelled;

  const factory IapPurchaseResult.pending({
    required String productId,
    String? message,
  }) = _IapPurchasePending;

  const factory IapPurchaseResult.failure({
    required String productId,
    required String message,
  }) = _IapPurchaseFailure;
}
