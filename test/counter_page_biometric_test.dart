import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/constants.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/features/counter/presentation/pages/counter_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/platform/biometric_authenticator.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'test_helpers.dart';

class _FakeCounterRepository implements CounterRepository {
  @override
  Future<CounterSnapshot> load() async =>
      const CounterSnapshot(userId: 'test', count: 0);

  @override
  Future<void> save(CounterSnapshot snapshot) async {}

  @override
  Stream<CounterSnapshot> watch() async* {
    yield await load();
  }
}

class _FakeBiometricAuthenticator implements BiometricAuthenticator {
  _FakeBiometricAuthenticator(this.result);

  final bool result;
  int callCount = 0;
  String? lastReason;

  @override
  Future<bool> authenticate({String? localizedReason}) async {
    callCount++;
    lastReason = localizedReason;
    return result;
  }
}

Widget _buildApp(GoRouter router) {
  UI.resetScreenUtilReady();
  return ScreenUtilInit(
    designSize: AppConstants.designSize,
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, child) {
      UI.markScreenUtilReady();
      return MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(useMaterial3: true),
      );
    },
  );
}

GoRouter _createRouter(
  CounterRepository repository,
  BiometricAuthenticator auth, {
  required bool startTicker,
}) {
  return GoRouter(
    initialLocation: AppRoutes.counterPath,
    routes: [
      GoRoute(
        path: AppRoutes.counterPath,
        name: AppRoutes.counter,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => CounterCubit(
              repository: repository,
              timerService: FakeTimerService(),
              startTicker: startTicker,
            )..loadInitial(),
            child: const CounterPage(title: 'Counter'),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.settingsPath,
        name: AppRoutes.settings,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Settings Screen'))),
      ),
    ],
  );
}

void main() {
  setUp(() async {
    getIt.pushNewScope();
    await configureDependencies();
  });

  tearDown(() {
    getIt.popScope();
  });

  testWidgets('navigates to settings after successful biometric auth', (
    tester,
  ) async {
    final _FakeBiometricAuthenticator auth = _FakeBiometricAuthenticator(true);
    getIt.unregister<BiometricAuthenticator>();
    getIt.registerSingleton<BiometricAuthenticator>(auth);
    final GoRouter router = _createRouter(
      _FakeCounterRepository(),
      auth,
      startTicker: false,
    );

    await tester.pumpWidget(_buildApp(router));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.text('Settings Screen'), findsOneWidget);
    expect(auth.callCount, 1);
    expect(auth.lastReason, isNotEmpty);
  });

  testWidgets('shows error feedback when biometric auth fails', (tester) async {
    final _FakeBiometricAuthenticator auth = _FakeBiometricAuthenticator(false);
    getIt.unregister<BiometricAuthenticator>();
    getIt.registerSingleton<BiometricAuthenticator>(auth);
    final GoRouter router = _createRouter(
      _FakeCounterRepository(),
      auth,
      startTicker: false,
    );

    await tester.pumpWidget(_buildApp(router));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.text('Settings Screen'), findsNothing);
    expect(auth.callCount, 1);
    expect(find.text("Couldn't verify your identity."), findsOneWidget);
  });
}
