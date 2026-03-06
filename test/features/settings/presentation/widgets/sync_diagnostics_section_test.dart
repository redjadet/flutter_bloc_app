import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/theme/mix_app_theme.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/sync_diagnostics_section.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mix/mix.dart';
import 'package:mocktail/mocktail.dart';

class _MockSyncStatusCubit extends MockCubit<SyncStatusState>
    implements SyncStatusCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SyncDiagnosticsSection', () {
    late _MockSyncStatusCubit cubit;

    setUp(() {
      cubit = _MockSyncStatusCubit();
      when(() => cubit.ensureStarted()).thenAnswer((_) {});
    });

    Future<void> pump(final WidgetTester tester) {
      return tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (final context) => MixTheme(
              data: buildAppMixThemeData(context),
              child: BlocProvider<SyncStatusCubit>.value(
                value: cubit,
                child: const Scaffold(body: SyncDiagnosticsSection()),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('shows placeholder when no summary yet', (tester) async {
      const SyncStatusState state = SyncStatusState(
        networkStatus: NetworkStatus.online,
        syncStatus: SyncStatus.idle,
      );
      when(() => cubit.state).thenReturn(state);
      whenListen(
        cubit,
        Stream<SyncStatusState>.value(state),
        initialState: state,
      );

      await pump(tester);

      expect(find.textContaining('No sync runs'), findsOneWidget);
    });

    testWidgets('renders summary details when available', (tester) async {
      final SyncCycleSummary summary = SyncCycleSummary(
        recordedAt: DateTime.utc(2024, 1, 1, 12, 0),
        durationMs: 123,
        pullRemoteCount: 1,
        pullRemoteFailures: 0,
        pendingAtStart: 2,
        operationsProcessed: 2,
        operationsFailed: 0,
        prunedCount: 3,
        pendingByEntity: <String, int>{'chat': 1, 'counter': 1},
      );
      final SyncStatusState state = SyncStatusState(
        networkStatus: NetworkStatus.online,
        syncStatus: SyncStatus.idle,
        lastSummary: summary,
        history: <SyncCycleSummary>[summary],
      );
      when(() => cubit.state).thenReturn(state);
      whenListen(
        cubit,
        Stream<SyncStatusState>.value(state),
        initialState: state,
      );

      await pump(tester);

      expect(find.textContaining('Last run'), findsOneWidget);
      expect(find.textContaining('Ops:'), findsOneWidget);
      expect(find.textContaining('Pending at start'), findsOneWidget);
      expect(find.textContaining('Pruned'), findsOneWidget);
      expect(find.textContaining('chat: 1'), findsOneWidget);
      expect(find.textContaining('Duration'), findsOneWidget);
      expect(find.textContaining('Recent sync runs'), findsOneWidget);
    });

    testWidgets('hides pruned row when zero', (tester) async {
      final SyncCycleSummary summary = SyncCycleSummary(
        recordedAt: DateTime.utc(2024, 1, 1, 12, 0),
        durationMs: 50,
        pullRemoteCount: 0,
        pullRemoteFailures: 0,
        pendingAtStart: 0,
        operationsProcessed: 0,
        operationsFailed: 0,
        prunedCount: 0,
        pendingByEntity: const <String, int>{},
      );
      final SyncStatusState state = SyncStatusState(
        networkStatus: NetworkStatus.online,
        syncStatus: SyncStatus.idle,
        lastSummary: summary,
        history: <SyncCycleSummary>[summary],
      );
      when(() => cubit.state).thenReturn(state);
      whenListen(
        cubit,
        Stream<SyncStatusState>.value(state),
        initialState: state,
      );

      await pump(tester);

      expect(find.textContaining('Pruned'), findsNothing);
    });

    testWidgets('selector rebuilds only when history changes', (tester) async {
      final SyncCycleSummary summary = SyncCycleSummary(
        recordedAt: DateTime.utc(2026, 3, 6),
        durationMs: 50,
        pullRemoteCount: 0,
        pullRemoteFailures: 0,
        pendingAtStart: 0,
        operationsProcessed: 0,
        operationsFailed: 0,
        pendingByEntity: const <String, int>{},
      );
      final SyncStatusState initial = SyncStatusState(
        networkStatus: NetworkStatus.online,
        syncStatus: SyncStatus.idle,
        history: <SyncCycleSummary>[summary],
        lastSummary: summary,
      );
      final StreamController<SyncStatusState> controller =
          StreamController<SyncStatusState>.broadcast();
      addTearDown(controller.close);

      whenListen(cubit, controller.stream, initialState: initial);
      when(() => cubit.state).thenReturn(initial);

      await pump(tester);
      expect(
        find.byType(
          TypeSafeBlocSelector<
            SyncStatusCubit,
            SyncStatusState,
            List<SyncCycleSummary>
          >,
        ),
        findsOneWidget,
      );

      int buildCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SyncStatusCubit>.value(
            value: cubit,
            child:
                TypeSafeBlocSelector<
                  SyncStatusCubit,
                  SyncStatusState,
                  List<SyncCycleSummary>
                >(
                  selector: (final state) => state.history,
                  builder: (final context, final history) {
                    buildCount++;
                    return Text(
                      'history=${history.length}',
                      textDirection: TextDirection.ltr,
                    );
                  },
                ),
          ),
        ),
      );
      await tester.pump();
      expect(buildCount, 1);

      controller.add(initial.copyWith(networkStatus: NetworkStatus.offline));
      await tester.pump();
      expect(buildCount, 1);

      final SyncCycleSummary newer = summary.copyWith(durationMs: 75);
      controller.add(
        initial.copyWith(
          history: <SyncCycleSummary>[summary, newer],
          lastSummary: newer,
        ),
      );
      await tester.pump();
      expect(buildCount, 2);
    });
  });
}
