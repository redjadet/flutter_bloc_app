import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_icon_button.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_menu_icon.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_theme.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

class LibraryTopNav extends StatelessWidget {
  const LibraryTopNav({
    required this.l10n,
    required this.onBack,
    super.key,
  });

  final AppLocalizations l10n;
  final VoidCallback onBack;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: EdgeInsets.only(
      top: EpochSpacing.topPadding,
      left: EpochSpacing.panelPadding,
    ),
    child: LibraryDemoIconButton(
      icon: const LibraryMenuIcon(),
      onPressed: onBack,
      tooltip: l10n.libraryDemoBackButtonLabel,
      backgroundColor: EpochColors.warmGreyLightest,
      size: EpochSpacing.buttonSize,
    ),
  );
}
