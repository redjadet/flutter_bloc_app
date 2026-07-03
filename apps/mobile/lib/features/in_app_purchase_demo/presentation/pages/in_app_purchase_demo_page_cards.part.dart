part of 'in_app_purchase_demo_page.dart';

class _RepositoryControlsCard extends StatelessWidget {
  const _RepositoryControlsCard();

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.cubit<InAppPurchaseDemoCubit>();
    final controls = context
        .selectState<
          InAppPurchaseDemoCubit,
          InAppPurchaseDemoState,
          ({
            bool useFakeRepository,
            IapDemoForcedOutcome forcedOutcome,
            bool isBusy,
          })
        >(
          selector: (final state) => (
            useFakeRepository: state.useFakeRepository,
            forcedOutcome: state.forcedOutcome,
            isBusy: state.isBusy,
          ),
        );

    return CommonCard(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(context.responsiveGapL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.iapDemoDisclaimer,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: context.responsiveGapM),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.iapDemoUseFakeRepoLabel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Switch.adaptive(
                  value: controls.useFakeRepository,
                  onChanged: controls.isBusy
                      ? null
                      : (final useFake) =>
                            cubit.toggleRepository(useFake: useFake),
                ),
              ],
            ),
            SizedBox(height: context.responsiveGapS),
            _DemoControls(
              cubit: cubit,
              enabled: controls.useFakeRepository,
              selected: controls.forcedOutcome,
            ),
          ],
        ),
      ),
    );
  }
}

class _EntitlementsCard extends StatelessWidget {
  const _EntitlementsCard();

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.cubit<InAppPurchaseDemoCubit>();
    final entitlementsState = context
        .selectState<
          InAppPurchaseDemoCubit,
          InAppPurchaseDemoState,
          ({IapEntitlements entitlements, bool isBusy})
        >(
          selector: (final state) => (
            entitlements: state.entitlements,
            isBusy: state.isBusy,
          ),
        );

    return CommonCard(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(context.responsiveGapL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.iapDemoEntitlementsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: context.responsiveGapS),
            Text(
              '${l10n.iapDemoCreditsLabel}: ${entitlementsState.entitlements.credits}',
            ),
            Text(
              '${l10n.iapDemoPremiumLabel}: ${entitlementsState.entitlements.isPremiumOwned ? l10n.commonYes : l10n.commonNo}',
            ),
            Text(
              '${l10n.iapDemoSubscriptionLabel}: ${entitlementsState.entitlements.isSubscriptionActive ? l10n.commonYes : l10n.commonNo}',
            ),
            if (entitlementsState.entitlements.subscriptionExpiry != null)
              Text(
                '${l10n.iapDemoSubscriptionExpiryLabel}: ${entitlementsState.entitlements.subscriptionExpiry}',
              ),
            SizedBox(height: context.responsiveGapM),
            PlatformAdaptive.filledButton(
              context: context,
              onPressed: entitlementsState.isBusy ? null : cubit.restore,
              child: Text(l10n.iapDemoRestoreButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductsCard extends StatelessWidget {
  const _ProductsCard();

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.cubit<InAppPurchaseDemoCubit>();
    final _IapProductsViewData productsState = context
        .selectState<
          InAppPurchaseDemoCubit,
          InAppPurchaseDemoState,
          _IapProductsViewData
        >(
          selector: _IapProductsViewData.fromState,
        );

    return CommonCard(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(context.responsiveGapL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.iapDemoProductsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: context.responsiveGapS),
            if (productsState.status == InAppPurchaseDemoStatus.loadingProducts)
              const Center(child: CircularProgressIndicator())
            else ...[
              _ProductSection(
                title: l10n.iapDemoConsumablesTitle,
                products: productsState.consumableProducts,
                entitlements: productsState.entitlements,
                isBusy: productsState.isBusy,
                onBuy: cubit.buy,
              ),
              SizedBox(height: context.responsiveGapM),
              _ProductSection(
                title: l10n.iapDemoNonConsumablesTitle,
                products: productsState.nonConsumableProducts,
                entitlements: productsState.entitlements,
                isBusy: productsState.isBusy,
                onBuy: cubit.buy,
              ),
              SizedBox(height: context.responsiveGapM),
              _ProductSection(
                title: l10n.iapDemoSubscriptionsTitle,
                products: productsState.subscriptionProducts,
                entitlements: productsState.entitlements,
                isBusy: productsState.isBusy,
                onBuy: cubit.buy,
              ),
            ],
            if (productsState.lastResult != null) ...[
              SizedBox(height: context.responsiveGapM),
              Text(
                '${l10n.iapDemoLastResultLabel}: ${productsState.lastResult}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (productsState.errorMessage case final String message?) ...[
              SizedBox(height: context.responsiveGapM),
              Text(
                message,
                style:
                    Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

@immutable
class _IapProductsViewData {
  const _IapProductsViewData({
    required this.status,
    required this.consumableProducts,
    required this.nonConsumableProducts,
    required this.subscriptionProducts,
    required this.entitlements,
    required this.isBusy,
    required this.lastResult,
    required this.errorMessage,
  });

  factory _IapProductsViewData.fromState(final InAppPurchaseDemoState state) {
    final List<IapProduct> consumable = <IapProduct>[];
    final List<IapProduct> nonConsumable = <IapProduct>[];
    final List<IapProduct> subscriptions = <IapProduct>[];

    for (final product in state.products) {
      switch (product.type) {
        case IapProductType.consumable:
          consumable.add(product);
          break;
        case IapProductType.nonConsumable:
          nonConsumable.add(product);
          break;
        case IapProductType.subscription:
          subscriptions.add(product);
          break;
      }
    }

    return _IapProductsViewData(
      status: state.status,
      consumableProducts: List<IapProduct>.unmodifiable(consumable),
      nonConsumableProducts: List<IapProduct>.unmodifiable(nonConsumable),
      subscriptionProducts: List<IapProduct>.unmodifiable(subscriptions),
      entitlements: state.entitlements,
      isBusy: state.isBusy,
      lastResult: state.lastResult,
      errorMessage: state.errorMessage,
    );
  }

  final InAppPurchaseDemoStatus status;
  final List<IapProduct> consumableProducts;
  final List<IapProduct> nonConsumableProducts;
  final List<IapProduct> subscriptionProducts;
  final IapEntitlements entitlements;
  final bool isBusy;
  final IapPurchaseResult? lastResult;
  final String? errorMessage;

  static const DeepCollectionEquality _listEq = DeepCollectionEquality();

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is _IapProductsViewData &&
          other.status == status &&
          other.isBusy == isBusy &&
          other.lastResult == lastResult &&
          other.errorMessage == errorMessage &&
          other.entitlements == entitlements &&
          _listEq.equals(other.consumableProducts, consumableProducts) &&
          _listEq.equals(other.nonConsumableProducts, nonConsumableProducts) &&
          _listEq.equals(other.subscriptionProducts, subscriptionProducts);

  @override
  int get hashCode => Object.hash(
    status,
    isBusy,
    lastResult,
    errorMessage,
    entitlements,
    _listEq.hash(consumableProducts),
    _listEq.hash(nonConsumableProducts),
    _listEq.hash(subscriptionProducts),
  );
}
