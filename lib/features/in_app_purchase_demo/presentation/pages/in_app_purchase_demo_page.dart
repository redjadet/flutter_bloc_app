import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_demo_controls.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_entitlement.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_product.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_purchase_result.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/presentation/cubit/in_app_purchase_demo_cubit.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/presentation/cubit/in_app_purchase_demo_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_card.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

part 'in_app_purchase_demo_page_widgets.part.dart';

class InAppPurchaseDemoPage extends StatelessWidget {
  const InAppPurchaseDemoPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.iapDemoPageTitle,
      body: Builder(
        builder: (final context) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: context.responsiveGapL),
            child: const Column(
              children: [
                _RepositoryControlsCard(),
                _IapSectionGap(),
                _EntitlementsCard(),
                _IapSectionGap(),
                _ProductsCard(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _IapSectionGap extends StatelessWidget {
  const _IapSectionGap();

  @override
  Widget build(final BuildContext context) {
    return SizedBox(height: context.responsiveGapL);
  }
}

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
    final productsState = context
        .selectState<
          InAppPurchaseDemoCubit,
          InAppPurchaseDemoState,
          ({
            InAppPurchaseDemoStatus status,
            List<IapProduct> products,
            IapEntitlements entitlements,
            bool isBusy,
            IapPurchaseResult? lastResult,
            String? errorMessage,
          })
        >(
          selector: (final state) => (
            status: state.status,
            products: state.products,
            entitlements: state.entitlements,
            isBusy: state.isBusy,
            lastResult: state.lastResult,
            errorMessage: state.errorMessage,
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
              l10n.iapDemoProductsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: context.responsiveGapS),
            if (productsState.status == InAppPurchaseDemoStatus.loadingProducts)
              const Center(child: CircularProgressIndicator())
            else ...[
              _ProductSection(
                title: l10n.iapDemoConsumablesTitle,
                products: productsState.products
                    .where(
                      (final product) =>
                          product.type == IapProductType.consumable,
                    )
                    .toList(growable: false),
                entitlements: productsState.entitlements,
                isBusy: productsState.isBusy,
                onBuy: cubit.buy,
              ),
              SizedBox(height: context.responsiveGapM),
              _ProductSection(
                title: l10n.iapDemoNonConsumablesTitle,
                products: productsState.products
                    .where(
                      (final product) =>
                          product.type == IapProductType.nonConsumable,
                    )
                    .toList(growable: false),
                entitlements: productsState.entitlements,
                isBusy: productsState.isBusy,
                onBuy: cubit.buy,
              ),
              SizedBox(height: context.responsiveGapM),
              _ProductSection(
                title: l10n.iapDemoSubscriptionsTitle,
                products: productsState.products
                    .where(
                      (final product) =>
                          product.type == IapProductType.subscription,
                    )
                    .toList(growable: false),
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
