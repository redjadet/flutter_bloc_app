import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/scapes/domain/scape.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/scapes_cubit.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/scapes_state.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/widgets/scapes_grid_content.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockScapesCubit extends MockCubit<ScapesState> implements ScapesCubit {}

void main() {
  group('ScapesGridSliverContent rebuild regression', () {
    late _MockScapesCubit cubit;

    setUp(() {
      cubit = _MockScapesCubit();
    });

    tearDown(() async {
      await cubit.close();
    });

    testWidgets('selector rebuilds only when selected tuple changes', (
      final WidgetTester tester,
    ) async {
      const ScapesState initial = ScapesState(
        viewMode: ScapesViewMode.grid,
        isLoading: false,
      );
      final StreamController<ScapesState> streamController =
          StreamController<ScapesState>.broadcast();
      addTearDown(streamController.close);

      whenListen(cubit, streamController.stream, initialState: initial);
      when(() => cubit.state).thenReturn(initial);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<ScapesCubit>.value(
            value: cubit,
            child: const Scaffold(
              body: CustomScrollView(
                slivers: <Widget>[ScapesGridSliverContent()],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(
        find.byType(
          TypeSafeBlocSelector<
            ScapesCubit,
            ScapesState,
            (bool, bool, String?, List<Scape>)
          >,
        ),
        findsOneWidget,
      );

      int buildCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ScapesCubit>.value(
            value: cubit,
            child:
                TypeSafeBlocSelector<
                  ScapesCubit,
                  ScapesState,
                  (bool, bool, String?, List<Scape>)
                >(
                  selector: (final s) =>
                      (s.isLoading, s.hasError, s.errorMessage, s.scapes),
                  builder: (final context, final data) {
                    buildCount++;
                    return Text(
                      'loading=${data.$1}, error=${data.$2}, scapes=${data.$4.length}',
                      textDirection: TextDirection.ltr,
                    );
                  },
                ),
          ),
        ),
      );
      await tester.pump();
      expect(buildCount, 1);

      streamController.add(initial.copyWith(viewMode: ScapesViewMode.list));
      await tester.pump();
      expect(buildCount, 1);

      streamController.add(initial.copyWith(errorMessage: 'boom'));
      await tester.pump();
      expect(buildCount, 2);
    });
  });
}
