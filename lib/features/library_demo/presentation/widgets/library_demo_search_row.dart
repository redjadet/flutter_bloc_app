import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_filter_icon.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_icon_button.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_theme.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

class LibrarySearchRow extends StatelessWidget {
  const LibrarySearchRow({required this.l10n, super.key});

  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) => Row(
    children: [
      Expanded(
        child: Container(
          height: EpochSpacing.buttonSize,
          padding: EdgeInsets.symmetric(
            horizontal: EpochSpacing.panelPadding,
          ),
          decoration: BoxDecoration(
            color: EpochColors.ash.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(
              EpochSpacing.borderRadiusLarge,
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextField(
              style: EpochTextStyles.searchPlaceholder(context).copyWith(
                color: EpochColors.warmGreyLightest,
              ),
              decoration: InputDecoration(
                hintText: l10n.libraryDemoSearchHint.toUpperCase(),
                hintStyle: EpochTextStyles.searchPlaceholder(context),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
        ),
      ),
      SizedBox(width: EpochSpacing.gapTight),
      LibraryDemoIconButton(
        icon: const LibraryFilterIcon(),
        onPressed: () {},
        tooltip: l10n.libraryDemoFilterButtonLabel,
        backgroundColor: EpochColors.ash.withValues(alpha: 0.5),
      ),
    ],
  );
}
