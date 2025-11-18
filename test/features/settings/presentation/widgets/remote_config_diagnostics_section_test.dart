import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/remote_config/presentation/cubit/remote_config_cubit.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/remote_config_diagnostics_section.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemoteConfigCubit extends MockCubit<RemoteConfigState>
    implements RemoteConfigCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RemoteConfigDiagnosticsSection', () {
    late _MockRemoteConfigCubit cubit;

    setUp(() {
      cubit = _MockRemoteConfigCubit();
    });

    Future<void> pumpWidget(final WidgetTester tester) {
      return tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<RemoteConfigCubit>.value(
            value: cubit,
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
  });
}
