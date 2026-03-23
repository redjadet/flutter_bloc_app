import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_body.dart';
import 'package:flutter_bloc_app/features/scapes/data/mock_scapes_repository.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/scapes_cubit.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/widgets/scapes_grid_content.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_helpers.dart' show FakeTimerService;

void main() {
  late MockScapesRepository repository;
  late FakeTimerService timerService;

  setUp(() {
    repository = MockScapesRepository();
    timerService = FakeTimerService();
  });

  Future<void> pumpBody(WidgetTester tester, {bool isGridView = false}) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider<ScapesCubit>(
            create: (_) =>
                ScapesCubit(repository: repository, timerService: timerService),
            child: SizedBox(
              width: 400,
              height: 2000,
              child: LibraryDemoBody(
                isGridView: isGridView,
                onGridPressed: () {},
                onListPressed: () {},
                gridTrailingSlivers: const [ScapesGridSliverContent()],
                timerService: timerService,
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('LibraryDemoBody', () {
    testWidgets('grid view shows scapes grid content after load', (
      WidgetTester tester,
    ) async {
      await pumpBody(tester, isGridView: true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(ScapesGridSliverContent), findsOneWidget);
    });
  });
}
