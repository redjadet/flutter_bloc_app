import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_body.dart';
import 'package:flutter_bloc_app/shared/design_system/epoch_theme_extension.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

class LibraryDemoPage extends StatefulWidget {
  const LibraryDemoPage({
    required this.gridTrailingSlivers,
    required this.timerService,
    super.key,
  });

  /// Trailing slivers after the library header when grid mode is on; composed
  /// in app/router (e.g. scapes grid) so library_demo stays feature-isolated.
  final List<Widget> gridTrailingSlivers;
  final TimerService timerService;

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
    final TimerService timerService = widget.timerService;
    final ThemeData theme = Theme.of(context);
    final EpochThemeExtension epoch = context.epoch;
    final ThemeData pageTheme = theme.copyWith(
      extensions: () {
        final List<ThemeExtension<dynamic>> list = [
          epoch,
          ...theme.extensions.values,
        ];
        return list;
      }(),
      scaffoldBackgroundColor: epoch.warmGrey,
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: epoch.warmGrey,
        foregroundColor: epoch.darkGrey,
        elevation: 0,
      ),
    );

    return Theme(
      data: pageTheme,
      child: CommonPageLayout(
        title: context.l10n.libraryDemoPageTitle,
        appBarBackgroundColor: epoch.warmGrey,
        appBarForegroundColor: epoch.darkGrey,
        useResponsiveBody: false,
        body: SafeArea(
          child: LibraryDemoBody(
            isGridView: _isGridView,
            onGridPressed: _toggleToGridView,
            onListPressed: _toggleToListView,
            gridTrailingSlivers: widget.gridTrailingSlivers,
            timerService: timerService,
          ),
        ),
      ),
    );
  }
}
