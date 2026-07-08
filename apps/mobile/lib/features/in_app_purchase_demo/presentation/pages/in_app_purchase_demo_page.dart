import 'package:collection/collection.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_demo_controls.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_entitlement.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_product.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_purchase_result.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/presentation/cubit/in_app_purchase_demo_cubit.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/presentation/cubit/in_app_purchase_demo_state.dart';

part 'in_app_purchase_demo_page_cards.part.dart';
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
