import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/pages/library_demo_page.dart';
import 'package:flutter_bloc_app/features/scapes/data/mock_scapes_repository.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/scapes_cubit.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/widgets/scapes_grid_content.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_helpers.dart' show FakeTimerService;

void main() {
  late MockScapesRepository repository;
  late FakeTimerService timerService;

  setUp(() {
    repository = MockScapesRepository();
    timerService = FakeTimerService();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<ScapesCubit>(
          create: (_) =>
              ScapesCubit(repository: repository, timerService: timerService),
          child: LibraryDemoPage(
            timerService: timerService,
            gridTrailingSlivers: const [ScapesGridSliverContent()],
          ),
        ),
      ),
    );
  }

  group('LibraryDemoPage', () {
    testWidgets('renders page title from l10n', (WidgetTester tester) async {
      await pumpPage(tester);

      expect(
        find.text(AppLocalizationsEn().libraryDemoPageTitle),
        findsOneWidget,
      );
    });

    testWidgets('starts in list view and shows list content', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester);

      expect(find.byType(ScapesGridSliverContent), findsNothing);
    });

    testWidgets('switching to grid view shows scapes grid', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester);

      await tester.tap(find.byTooltip('Grid view'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(ScapesGridSliverContent), findsOneWidget);
    });
  });
}
