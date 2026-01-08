import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_body.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_theme.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

class LibraryDemoPage extends StatelessWidget {
  const LibraryDemoPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ThemeData pageTheme = theme.copyWith(
      scaffoldBackgroundColor: EpochColors.warmGrey,
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: EpochColors.warmGrey,
        foregroundColor: EpochColors.darkGrey,
        elevation: 0,
      ),
    );

    return Theme(
      data: pageTheme,
      child: CommonPageLayout(
        title: context.l10n.libraryDemoPageTitle,
        useResponsiveBody: false,
        automaticallyImplyLeading: false,
        body: const SafeArea(
          child: LibraryDemoBody(),
        ),
      ),
    );
  }
}
