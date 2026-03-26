import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_demo_controls.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_entitlement.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_product.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/presentation/cubit/in_app_purchase_demo_cubit.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/presentation/cubit/in_app_purchase_demo_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_card.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

class InAppPurchaseDemoPage extends StatelessWidget {
  const InAppPurchaseDemoPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.iapDemoPageTitle,
      body: BlocBuilder<InAppPurchaseDemoCubit, InAppPurchaseDemoState>(
        builder: (final context, final state) {
          final cubit = context.cubit<InAppPurchaseDemoCubit>();
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: context.responsiveGapL),
            child: Column(
              children: [
                CommonCard(
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
                              value: state.useFakeRepository,
                              onChanged: state.isBusy
                                  ? null
                                  : (final useFake) => cubit.toggleRepository(
                                      useFake: useFake,
                                    ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.responsiveGapS),
                        _DemoControls(
                          cubit: cubit,
                          enabled: state.useFakeRepository,
                          selected: state.forcedOutcome,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: context.responsiveGapL),
                CommonCard(
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
                          '${l10n.iapDemoCreditsLabel}: ${state.entitlements.credits}',
                        ),
                        Text(
                          '${l10n.iapDemoPremiumLabel}: ${state.entitlements.isPremiumOwned ? l10n.commonYes : l10n.commonNo}',
                        ),
                        Text(
                          '${l10n.iapDemoSubscriptionLabel}: ${state.entitlements.isSubscriptionActive ? l10n.commonYes : l10n.commonNo}',
                        ),
                        if (state.entitlements.subscriptionExpiry != null)
                          Text(
                            '${l10n.iapDemoSubscriptionExpiryLabel}: ${state.entitlements.subscriptionExpiry}',
                          ),
                        SizedBox(height: context.responsiveGapM),
                        PlatformAdaptive.filledButton(
                          context: context,
                          onPressed: state.isBusy ? null : cubit.restore,
                          child: Text(l10n.iapDemoRestoreButton),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: context.responsiveGapL),
                CommonCard(
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
                        if (state.status ==
                            InAppPurchaseDemoStatus.loadingProducts)
                          const Center(child: CircularProgressIndicator())
                        else ...[
                          _ProductSection(
                            title: l10n.iapDemoConsumablesTitle,
                            products: state.products
                                .where(
                                  (final p) =>
                                      p.type == IapProductType.consumable,
                                )
                                .toList(),
                            entitlements: state.entitlements,
                            isBusy: state.isBusy,
                            onBuy: cubit.buy,
                          ),
                          SizedBox(height: context.responsiveGapM),
                          _ProductSection(
                            title: l10n.iapDemoNonConsumablesTitle,
                            products: state.products
                                .where(
                                  (final p) =>
                                      p.type == IapProductType.nonConsumable,
                                )
                                .toList(),
                            entitlements: state.entitlements,
                            isBusy: state.isBusy,
                            onBuy: cubit.buy,
                          ),
                          SizedBox(height: context.responsiveGapM),
                          _ProductSection(
                            title: l10n.iapDemoSubscriptionsTitle,
                            products: state.products
                                .where(
                                  (final p) =>
                                      p.type == IapProductType.subscription,
                                )
                                .toList(),
                            entitlements: state.entitlements,
                            isBusy: state.isBusy,
                            onBuy: cubit.buy,
                          ),
                        ],
                        if (state.lastResult != null) ...[
                          SizedBox(height: context.responsiveGapM),
                          Text(
                            '${l10n.iapDemoLastResultLabel}: ${state.lastResult}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        if (state.errorMessage != null) ...[
                          SizedBox(height: context.responsiveGapM),
                          Text(
                            state.errorMessage ?? '',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DemoControls extends StatelessWidget {
  const _DemoControls({
    required this.cubit,
    required this.enabled,
    required this.selected,
  });

  final InAppPurchaseDemoCubit cubit;
  final bool enabled;
  final IapDemoForcedOutcome selected;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final List<DropdownMenuItem<IapDemoForcedOutcome>> items =
        IapDemoForcedOutcome.values
            .map(
              (final o) => DropdownMenuItem(
                value: o,
                child: Text(o.name),
              ),
            )
            .toList();

    return Row(
      children: [
        Expanded(child: Text(l10n.iapDemoForceOutcomeLabel)),
        DropdownButton<IapDemoForcedOutcome>(
          value: selected,
          items: items,
          onChanged: enabled
              ? (final v) {
                  if (v == null) return;
                  cubit.setForcedOutcome(v);
                }
              : null,
        ),
      ],
    );
  }
}

class _ProductSection extends StatelessWidget {
  const _ProductSection({
    required this.title,
    required this.products,
    required this.entitlements,
    required this.isBusy,
    required this.onBuy,
  });

  final String title;
  final List<IapProduct> products;
  final IapEntitlements entitlements;
  final bool isBusy;
  final Future<void> Function(IapProduct) onBuy;

  bool _isOwned(final IapProduct p) {
    switch (p.type) {
      case IapProductType.consumable:
        return false;
      case IapProductType.nonConsumable:
        return entitlements.isPremiumOwned;
      case IapProductType.subscription:
        return entitlements.isSubscriptionActive;
    }
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        SizedBox(height: context.responsiveGapS),
        for (final p in products)
          Padding(
            padding: EdgeInsets.only(bottom: context.responsiveGapS),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.title),
                      Text(
                        p.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                PlatformAdaptive.filledButton(
                  context: context,
                  onPressed: (isBusy || _isOwned(p)) ? null : () => onBuy(p),
                  child: Text('${l10n.iapDemoBuyButton} ${p.priceLabel}'),
                ),
              ],
            ),
          ),
        if (products.isEmpty)
          Text(
            l10n.iapDemoNoProductsFound,
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}
