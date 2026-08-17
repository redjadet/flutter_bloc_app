import 'package:freezed_annotation/freezed_annotation.dart';

part 'iap_entitlement.freezed.dart';

@freezed
abstract class IapEntitlements with _$IapEntitlements {
  const factory IapEntitlements({
    @Default(0) int credits,
    @Default(false) bool isPremiumOwned,
    @Default(false) bool isSubscriptionActive,
    DateTime? subscriptionExpiry,
  }) = _IapEntitlements;
}
