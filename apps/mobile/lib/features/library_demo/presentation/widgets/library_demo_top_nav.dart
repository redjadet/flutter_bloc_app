import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_icon_button.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_menu_icon.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

class LibraryTopNav extends StatelessWidget {
  const LibraryTopNav({
    required this.l10n,
    required this.onBack,
    this.padding,
    super.key,
  });

  final AppLocalizations l10n;
  final VoidCallback onBack;
  final EdgeInsets? padding;

  @override
  Widget build(final BuildContext context) {
    final EpochThemeExtension epoch = context.epoch;
    return Padding(
      padding:
          padding ??
          EdgeInsets.only(
            top: EpochSpacing.topPadding,
            left: EpochSpacing.panelPadding,
          ),
      child: LibraryDemoIconButton(
        icon: const LibraryMenuIcon(),
        onPressed: onBack,
        tooltip: l10n.libraryDemoBackButtonLabel,
        backgroundColor: epoch.warmGreyLightest,
        size: EpochSpacing.buttonSize,
      ),
    );
  }
}
