import 'package:freezed_annotation/freezed_annotation.dart';

part 'iap_purchase_result.freezed.dart';

@freezed
abstract class IapPurchaseResult with _$IapPurchaseResult {
  const factory IapPurchaseResult.success({
    required final String productId,
    final String? message,
  }) = _IapPurchaseSuccess;

  const factory IapPurchaseResult.cancelled({
    required final String productId,
    final String? message,
  }) = _IapPurchaseCancelled;

  const factory IapPurchaseResult.pending({
    required final String productId,
    final String? message,
  }) = _IapPurchasePending;

  const factory IapPurchaseResult.failure({
    required final String productId,
    required final String message,
  }) = _IapPurchaseFailure;
}
