import 'package:freezed_annotation/freezed_annotation.dart';

part 'iap_purchase_result.freezed.dart';

@freezed
abstract class IapPurchaseResult with _$IapPurchaseResult {
  const factory success({required String productId, String? message}) =
      _IapPurchaseSuccess;

  const factory cancelled({required String productId, String? message}) =
      _IapPurchaseCancelled;

  const factory pending({required String productId, String? message}) =
      _IapPurchasePending;

  const factory failure({required String productId, required String message}) =
      _IapPurchaseFailure;
}
