import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_body.dart';
import 'package:flutter_bloc_app/features/scapes/domain/scapes_repository.dart';
import 'package:flutter_bloc_app/shared/design_system/epoch_theme_extension.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

class LibraryDemoPage extends StatefulWidget {
  const LibraryDemoPage({
    required this.scapesRepository,
    required this.timerService,
    super.key,
  });

  final ScapesRepository scapesRepository;
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
    final ScapesRepository scapesRepository = widget.scapesRepository;
    final TimerService timerService = widget.timerService;
    final ThemeData theme = Theme.of(context);
    final ThemeData pageTheme = theme.copyWith(
      extensions: () {
        final List<ThemeExtension<dynamic>> list = [
          EpochThemeExtension.defaults,
          ...theme.extensions.values,
        ];
        return list;
      }(),
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
        appBarBackgroundColor: EpochColors.warmGrey,
        appBarForegroundColor: EpochColors.darkGrey,
        useResponsiveBody: false,
        body: SafeArea(
          child: LibraryDemoBody(
            isGridView: _isGridView,
            onGridPressed: _toggleToGridView,
            onListPressed: _toggleToListView,
            scapesRepository: scapesRepository,
            timerService: timerService,
          ),
        ),
      ),
    );
  }
}
