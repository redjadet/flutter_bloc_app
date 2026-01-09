import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_icon_button.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_theme.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_view_icons.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

class LibraryAssetsHeader extends StatelessWidget {
  const LibraryAssetsHeader({
    required this.l10n,
    required this.isGridView,
    required this.onGridPressed,
    required this.onListPressed,
    super.key,
  });

  final AppLocalizations l10n;
  final bool isGridView;
  final VoidCallback onGridPressed;
  final VoidCallback onListPressed;

  @override
  Widget build(final BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          l10n.libraryDemoAssetsTitle,
          style: EpochTextStyles.heading(context),
        ),
      ),
      Row(
        children: [
          LibraryDemoIconButton(
            icon: LibraryGridViewIcon(isActive: isGridView),
            onPressed: onGridPressed,
            tooltip: 'Grid view',
            backgroundColor: Colors.transparent,
            size: 16,
          ),
          SizedBox(width: EpochSpacing.gapMedium),
          LibraryDemoIconButton(
            icon: LibraryListViewIcon(isActive: !isGridView),
            onPressed: onListPressed,
            tooltip: 'List view',
            backgroundColor: Colors.transparent,
            size: 16,
          ),
        ],
      ),
    ],
  );
}
