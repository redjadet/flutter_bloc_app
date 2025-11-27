import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/sync_diagnostics_section.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSyncStatusCubit extends MockCubit<SyncStatusState>
    implements SyncStatusCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SyncDiagnosticsSection', () {
    late _MockSyncStatusCubit cubit;

    setUp(() {
      cubit = _MockSyncStatusCubit();
    });

    Future<void> pump(final WidgetTester tester) {
      return tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<SyncStatusCubit>.value(
            value: cubit,
            child: const Scaffold(body: SyncDiagnosticsSection()),
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
      expect(find.textContaining('chat: 1'), findsOneWidget);
      expect(find.textContaining('Duration'), findsOneWidget);
      expect(find.textContaining('Recent sync runs'), findsOneWidget);
    });
  });
}
