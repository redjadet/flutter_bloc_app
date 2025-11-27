import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/remote_config/presentation/cubit/remote_config_cubit.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/remote_config_diagnostics_section.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_de.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_es.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_fr.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_tr.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemoteConfigCubit extends MockCubit<RemoteConfigState>
    implements RemoteConfigCubit {}

class _MockSyncStatusCubit extends MockCubit<SyncStatusState>
    implements SyncStatusCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RemoteConfigDiagnosticsSection', () {
    late _MockRemoteConfigCubit cubit;
    late _MockSyncStatusCubit syncStatusCubit;

    setUp(() {
      cubit = _MockRemoteConfigCubit();
      syncStatusCubit = _MockSyncStatusCubit();
    });

    Future<void> pumpWidget(
      final WidgetTester tester, {
      bool includeSyncCubit = false,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MultiBlocProvider(
            providers: <BlocProvider<dynamic>>[
              BlocProvider<RemoteConfigCubit>.value(value: cubit),
              if (includeSyncCubit)
                BlocProvider<SyncStatusCubit>.value(value: syncStatusCubit),
            ],
            child: const Scaffold(body: RemoteConfigDiagnosticsSection()),
          ),
        ),
      );
    }

    testWidgets('shows error message when remote config fails', (
      final WidgetTester tester,
    ) async {
      const RemoteConfigError state = RemoteConfigError('Network unavailable');
      when(() => cubit.state).thenReturn(state);
      whenListen(
        cubit,
        Stream<RemoteConfigState>.value(state),
        initialState: state,
      );

      await pumpWidget(tester);

      expect(find.textContaining('Network unavailable'), findsOneWidget);
      expect(
        find.text(AppLocalizationsEn().settingsRemoteConfigStatusError),
        findsOneWidget,
      );
    });

    testWidgets('shows flag status and test value when config loads', (
      final WidgetTester tester,
    ) async {
      const RemoteConfigLoaded state = RemoteConfigLoaded(
        isAwesomeFeatureEnabled: true,
        testValue: 'test-123',
        dataSource: 'remote',
      );
      when(() => cubit.state).thenReturn(state);
      whenListen(
        cubit,
        Stream<RemoteConfigState>.value(state),
        initialState: state,
      );

      await pumpWidget(tester);

      expect(
        find.textContaining(
          AppLocalizationsEn().settingsRemoteConfigFlagEnabled,
        ),
        findsOneWidget,
      );
      expect(find.textContaining('test-123'), findsOneWidget);
      expect(find.textContaining('remote'), findsOneWidget);
    });

    testWidgets('invokes fetchValues when retry button tapped', (
      final WidgetTester tester,
    ) async {
      const RemoteConfigError state = RemoteConfigError('boom');
      when(() => cubit.state).thenReturn(state);
      whenListen(
        cubit,
        Stream<RemoteConfigState>.value(state),
        initialState: state,
      );
      when(() => cubit.fetchValues()).thenAnswer((_) async {});

      await pumpWidget(tester);

      await tester.tap(
        find.text(AppLocalizationsEn().settingsRemoteConfigRetryButton),
      );
      await tester.pump();

      verify(() => cubit.fetchValues()).called(1);
    });

    testWidgets('shows sync status banner when offline', (
      final WidgetTester tester,
    ) async {
      const RemoteConfigLoaded state = RemoteConfigLoaded(
        isAwesomeFeatureEnabled: true,
        testValue: 'cached',
      );
      when(() => cubit.state).thenReturn(state);
      whenListen(
        cubit,
        Stream<RemoteConfigState>.value(state),
        initialState: state,
      );

      const SyncStatusState syncState = SyncStatusState(
        networkStatus: NetworkStatus.offline,
        syncStatus: SyncStatus.idle,
      );
      when(() => syncStatusCubit.state).thenReturn(syncState);
      whenListen(
        syncStatusCubit,
        Stream<SyncStatusState>.value(syncState),
        initialState: syncState,
      );

      await pumpWidget(tester, includeSyncCubit: true);

      expect(
        find.text(AppLocalizationsEn().syncStatusOfflineTitle),
        findsOneWidget,
      );
    });

    group('localization regression', () {
      test('all remote config diagnostic strings exist in all supported locales', () {
        final List<AppLocalizations> localizations = [
          AppLocalizationsEn(),
          AppLocalizationsTr(),
          AppLocalizationsDe(),
          AppLocalizationsFr(),
          AppLocalizationsEs(),
        ];

        for (final AppLocalizations l10n in localizations) {
          // Verify all required strings are non-empty
          expect(
            l10n.settingsRemoteConfigSectionTitle,
            isNotEmpty,
            reason:
                'settingsRemoteConfigSectionTitle missing in ${l10n.localeName}',
          );
          expect(
            l10n.settingsRemoteConfigErrorLabel,
            isNotEmpty,
            reason:
                'settingsRemoteConfigErrorLabel missing in ${l10n.localeName}',
          );
          expect(
            l10n.settingsRemoteConfigRetryButton,
            isNotEmpty,
            reason:
                'settingsRemoteConfigRetryButton missing in ${l10n.localeName}',
          );
          expect(
            l10n.settingsRemoteConfigFlagLabel,
            isNotEmpty,
            reason:
                'settingsRemoteConfigFlagLabel missing in ${l10n.localeName}',
          );
          expect(
            l10n.settingsRemoteConfigFlagEnabled,
            isNotEmpty,
            reason:
                'settingsRemoteConfigFlagEnabled missing in ${l10n.localeName}',
          );
          expect(
            l10n.settingsRemoteConfigFlagDisabled,
            isNotEmpty,
            reason:
                'settingsRemoteConfigFlagDisabled missing in ${l10n.localeName}',
          );
          expect(
            l10n.settingsRemoteConfigTestValueLabel,
            isNotEmpty,
            reason:
                'settingsRemoteConfigTestValueLabel missing in ${l10n.localeName}',
          );
          expect(
            l10n.settingsRemoteConfigTestValueEmpty,
            isNotEmpty,
            reason:
                'settingsRemoteConfigTestValueEmpty missing in ${l10n.localeName}',
          );
          expect(
            l10n.settingsRemoteConfigStatusLoading,
            isNotEmpty,
            reason:
                'settingsRemoteConfigStatusLoading missing in ${l10n.localeName}',
          );
          expect(
            l10n.settingsRemoteConfigStatusLoaded,
            isNotEmpty,
            reason:
                'settingsRemoteConfigStatusLoaded missing in ${l10n.localeName}',
          );
          expect(
            l10n.settingsRemoteConfigStatusError,
            isNotEmpty,
            reason:
                'settingsRemoteConfigStatusError missing in ${l10n.localeName}',
          );
          expect(
            l10n.settingsRemoteConfigStatusIdle,
            isNotEmpty,
            reason:
                'settingsRemoteConfigStatusIdle missing in ${l10n.localeName}',
          );
        }
      });
    });
  });
}
