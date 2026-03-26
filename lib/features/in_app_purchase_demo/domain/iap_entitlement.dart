import 'package:freezed_annotation/freezed_annotation.dart';

part 'iap_entitlement.freezed.dart';

@freezed
abstract class IapEntitlements with _$IapEntitlements {
  const factory IapEntitlements({
    @Default(0) final int credits,
    @Default(false) final bool isPremiumOwned,
    @Default(false) final bool isSubscriptionActive,
    final DateTime? subscriptionExpiry,
  }) = _IapEntitlements;
}
