import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/constants/constants.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/features/counter/presentation/pages/counter_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/platform/biometric_authenticator.dart';
import 'package:flutter_bloc_app/shared/services/error_notification_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_helpers.dart'
    show FakeTimerService, MockCounterRepository;

class _FakeBiometricAuthenticator implements BiometricAuthenticator {
  @override
  Future<bool> authenticate({String? localizedReason}) async => true;
}

class _FakeErrorNotificationService implements ErrorNotificationService {
  @override
  Future<void> showAlertDialog(
    final BuildContext context,
    final String title,
    final String message,
  ) async {}

  @override
  Future<void> showSnackBar(
    final BuildContext context,
    final String message,
  ) async {}
}

void main() {
  testWidgets('cannot-go-below-zero snackbar auto-dismisses in 2 seconds', (
    final WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(AppConstants.designSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final CounterCubit cubit = CounterCubit(
      repository: MockCounterRepository(),
      timerService: FakeTimerService(),
      startTicker: false,
    );
    addTearDown(cubit.close);
    await cubit.loadInitial();

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: AppConstants.designSize,
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (final context, final child) => MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<CounterCubit>.value(
            value: cubit,
            child: CounterPage(
              title: 'Counter',
              errorNotificationService: _FakeErrorNotificationService(),
              biometricAuthenticator: _FakeBiometricAuthenticator(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();

    expect(find.text('Count cannot go below 0'), findsOneWidget);
    final SnackBar snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.duration, const Duration(seconds: 2));
    expect(snackBar.action, isNull);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Count cannot go below 0'), findsNothing);
  });

  testWidgets(
    'cannot-go-below-zero snackbar shows again on repeated subtract',
    (final WidgetTester tester) async {
      await tester.binding.setSurfaceSize(AppConstants.designSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final CounterCubit cubit = CounterCubit(
        repository: MockCounterRepository(),
        timerService: FakeTimerService(),
        startTicker: false,
      );
      addTearDown(cubit.close);
      await cubit.loadInitial();

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: AppConstants.designSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (final context, final child) => MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: BlocProvider<CounterCubit>.value(
              value: cubit,
              child: CounterPage(
                title: 'Counter',
                errorNotificationService: _FakeErrorNotificationService(),
                biometricAuthenticator: _FakeBiometricAuthenticator(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(find.text('Count cannot go below 0'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('Count cannot go below 0'), findsNothing);

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(
        find.text('Count cannot go below 0'),
        findsOneWidget,
        reason:
            'Snackbar should show again when subtracting at zero a second time',
      );
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'cannot-go-below-zero snackbar is not stacked when subtract is spammed',
    (final WidgetTester tester) async {
      await tester.binding.setSurfaceSize(AppConstants.designSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final CounterCubit cubit = CounterCubit(
        repository: MockCounterRepository(),
        timerService: FakeTimerService(),
        startTicker: false,
      );
      addTearDown(cubit.close);
      await cubit.loadInitial();

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: AppConstants.designSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (final context, final child) => MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: BlocProvider<CounterCubit>.value(
              value: cubit,
              child: CounterPage(
                title: 'Counter',
                errorNotificationService: _FakeErrorNotificationService(),
                biometricAuthenticator: _FakeBiometricAuthenticator(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.remove));
      }
      await tester.pump();

      expect(
        find.text('Count cannot go below 0'),
        findsOneWidget,
        reason: 'Only one snackbar when subtract is spammed at zero',
      );
      expect(find.byType(SnackBar), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    },
  );
}
