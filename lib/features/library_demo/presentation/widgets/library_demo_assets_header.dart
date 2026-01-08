import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_theme.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_view_icons.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

class LibraryAssetsHeader extends StatelessWidget {
  const LibraryAssetsHeader({required this.l10n, super.key});

  final AppLocalizations l10n;

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
          const LibraryGridViewIcon(),
          SizedBox(width: EpochSpacing.gapMedium),
          const LibraryListViewIcon(isActive: true),
        ],
      ),
    ],
  );
}
