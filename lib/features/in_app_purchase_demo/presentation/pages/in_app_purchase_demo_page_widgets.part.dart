part of 'in_app_purchase_demo_page.dart';

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
