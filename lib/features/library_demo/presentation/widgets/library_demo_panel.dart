import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_assets_header.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_category_list.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_search_row.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/design_system/epoch_theme_extension.dart';

/// Shared dark rounded panel: title, search, categories, assets header, and
/// optional trailing content (e.g. gap only for grid, or gap + tiles for list).
class LibraryDemoPanel extends StatelessWidget {
  const LibraryDemoPanel({
    required this.l10n,
    required this.panelTopPadding,
    required this.panelBottomPadding,
    required this.sectionGap,
    required this.categoryGap,
    required this.isGridView,
    required this.onGridPressed,
    required this.onListPressed,
    required this.trailing,
    super.key,
  });

  final AppLocalizations l10n;
  final double panelTopPadding;
  final double panelBottomPadding;
  final double sectionGap;
  final double categoryGap;
  final bool isGridView;
  final VoidCallback onGridPressed;
  final VoidCallback onListPressed;
  final List<Widget> trailing;

  @override
  Widget build(final BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: EpochColors.darkGrey,
        borderRadius: BorderRadius.all(
          Radius.circular(EpochSpacing.borderRadiusLarge),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        EpochSpacing.panelPadding,
        panelTopPadding,
        EpochSpacing.panelPadding,
        panelBottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.libraryDemoPanelTitle,
            style: EpochTextStyles.heading(context),
          ),
          SizedBox(height: EpochSpacing.gapMedium),
          LibrarySearchRow(
            key: const ValueKey('library-demo-search-row'),
            l10n: l10n,
          ),
          SizedBox(height: categoryGap),
          LibraryCategoryList(l10n: l10n),
          SizedBox(height: sectionGap),
          LibraryAssetsHeader(
            l10n: l10n,
            isGridView: isGridView,
            onGridPressed: onGridPressed,
            onListPressed: onListPressed,
          ),
          SizedBox(height: sectionGap),
          ...trailing,
        ],
      ),
    );
  }
}
