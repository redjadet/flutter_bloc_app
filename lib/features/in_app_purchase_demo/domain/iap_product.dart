import 'package:freezed_annotation/freezed_annotation.dart';

part 'iap_product.freezed.dart';

enum IapProductType { consumable, nonConsumable, subscription }

@freezed
abstract class IapProduct with _$IapProduct {
  const factory IapProduct({
    required final String id,
    required final String title,
    required final String description,
    required final String priceLabel,
    required final IapProductType type,
  }) = _IapProduct;
}

/// Demo product IDs used by the IAP demo.
///
/// These must match products you create in App Store Connect / Play Console
/// to exercise the real store repository.
class IapDemoProductIds {
  IapDemoProductIds._();

  static const consumableCredits100 = 'demo_consumable_credits_100';
  static const nonConsumablePremium = 'demo_nonconsumable_premium';
  static const subscriptionMonthly = 'demo_subscription_monthly';

  static const all = <String>[
    consumableCredits100,
    nonConsumablePremium,
    subscriptionMonthly,
  ];
}
