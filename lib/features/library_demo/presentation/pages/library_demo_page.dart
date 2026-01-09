import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_body.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_theme.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

class LibraryDemoPage extends StatefulWidget {
  const LibraryDemoPage({super.key});

  @override
  State<LibraryDemoPage> createState() => _LibraryDemoPageState();
}

class _LibraryDemoPageState extends State<LibraryDemoPage> {
  bool _isGridView = false;

  void _toggleToGridView() {
    setState(() {
      _isGridView = true;
    });
  }

  void _toggleToListView() {
    setState(() {
      _isGridView = false;
    });
  }

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
        body: SafeArea(
          child: LibraryDemoBody(
            isGridView: _isGridView,
            onGridPressed: _toggleToGridView,
            onListPressed: _toggleToListView,
          ),
        ),
      ),
    );
  }
}
