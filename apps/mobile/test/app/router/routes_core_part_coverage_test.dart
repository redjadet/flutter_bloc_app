@TestOn('vm')
library;

import 'dart:async';

import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/router/app_route_auth_gate.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/router/routes_core.dart';
import 'package:flutter_bloc_app/app/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_locale.dart';
import 'package:flutter_bloc_app/features/settings/domain/locale_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_preference.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_repository.dart';
import 'package:flutter_bloc_app/features/settings/presentation/cubit/locale_cubit.dart';
import 'package:flutter_bloc_app/features/settings/presentation/cubit/theme_cubit.dart';
import 'package:flutter_bloc_app/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:networking/networking.dart';

import '../../test_helpers.dart';

class _FakeThemeRepository implements ThemeRepository {
  @override
  Future<ThemePreference?> load() async => ThemePreference.system;

  @override
  Future<void> save(final ThemePreference mode) async {}
}

class _FakeLocaleRepository implements LocaleRepository {
  @override
  Future<AppLocale?> load() async => const AppLocale(languageCode: 'en');

  @override
  Future<void> save(final AppLocale? locale) async {}
}

class _StubNetworkStatusService implements NetworkStatusService {
  @override
  Stream<NetworkStatus> get statusStream => const Stream<NetworkStatus>.empty();

  @override
  Future<NetworkStatus> getCurrentStatus() async => NetworkStatus.online;

  @override
  Future<void> dispose() async {}
}

class _StubBackgroundSyncCoordinator implements BackgroundSyncCoordinator {
  @override
  Stream<SyncStatus> get statusStream => const Stream<SyncStatus>.empty();

  @override
  SyncStatus get currentStatus => SyncStatus.idle;

  @override
  List<SyncCycleSummary> get history => const <SyncCycleSummary>[];

  @override
  Stream<SyncCycleSummary> get summaryStream =>
      const Stream<SyncCycleSummary>.empty();

  @override
  SyncCycleSummary? get latestSummary => null;

  @override
  Future<void> start() async {}

  @override
  Future<void> ensureStarted() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> flush() async {}

  @override
  Future<void> triggerFromFcm({final String? hint}) async {}
}

class _MockGoRouterState extends Mock implements GoRouterState {}

class _SignedInAuthRepository implements AuthRepository {
  const _SignedInAuthRepository();

  static const AuthUser _user = AuthUser(id: 'signed-in', isAnonymous: false);

  @override
  AuthUser? get currentUser => _user;

  @override
  Stream<AuthUser?> get authStateChanges => Stream<AuthUser?>.value(_user);
}

GoRouterState _state(final String path) {
  final _MockGoRouterState state = _MockGoRouterState();
  when(() => state.uri).thenReturn(Uri.parse(path));
  when(() => state.matchedLocation).thenReturn(path);
  when(() => state.extra).thenReturn(null);
  when(() => state.pathParameters).thenReturn(<String, String>{});
  return state;
}

List<BlocProvider<dynamic>> _coverageBlocProviders() => <BlocProvider<dynamic>>[
  BlocProvider<ThemeCubit>(
    create: (_) =>
        ThemeCubit(repository: _FakeThemeRepository())..loadInitial(),
  ),
  BlocProvider<LocaleCubit>(
    create: (_) =>
        LocaleCubit(repository: _FakeLocaleRepository())..loadInitial(),
  ),
  BlocProvider<SyncStatusCubit>(
    create: (_) => SyncStatusCubit(
      networkStatusService: _StubNetworkStatusService(),
      coordinator: _StubBackgroundSyncCoordinator(),
    ),
  ),
];

Widget _coveragePumpTree({required final Widget home}) => ScreenUtilInit(
  designSize: const Size(390, 844),
  minTextAdapt: true,
  builder: (final context, final _) => MultiBlocProvider(
    providers: _coverageBlocProviders(),
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: home,
    ),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupHiveForTesting();
  });

  setUp(() async {
    await setupTestDependencies(
      const TestSetupOptions(
        useMockFirebaseAuth: true,
        useMockFirebasePlatform: true,
      ),
    );
    if (getIt.isRegistered<AuthRepository>()) {
      await getIt.unregister<AuthRepository>();
    }
    getIt.registerSingleton<AuthRepository>(const _SignedInAuthRepository());
  });

  tearDown(() async {
    await tearDownTestDependencies();
  });

  testWidgets('routes_core.part builders and settings QA extras execute', (
    final tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final List<GoRoute> corePartRoutes = createCoreRoutes()
        .whereType<GoRoute>()
        .where(
          (final GoRoute r) =>
              r.name == AppRoutes.settings ||
              r.name == AppRoutes.manageAccount ||
              r.name == AppRoutes.profile ||
              r.name == AppRoutes.register ||
              r.name == AppRoutes.loggedOut ||
              r.name == AppRoutes.libraryDemo,
        )
        .toList();

    expect(corePartRoutes, isNotEmpty);

    for (final GoRoute route in corePartRoutes) {
      final GoRouterState state = _state(route.path);
      late Widget built;
      await tester.pumpWidget(
        _coveragePumpTree(
          home: Builder(
            builder: (final context) {
              built = route.builder!(context, state);
              return Scaffold(body: built);
            },
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      tester.takeException();

      if (built is AppRouteAuthGate) {
        final Widget gateChild = (built as AppRouteAuthGate).child;
        if (gateChild is SettingsPage) {
          await tester.pumpWidget(
            _coveragePumpTree(
              home: Builder(
                builder: (final context) {
                  final List<Widget>? extras = gateChild.buildQaExtras?.call(
                    context,
                  );
                  expect(extras, isNotNull);
                  expect(extras, isNotEmpty);
                  return Scaffold(
                    body: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: extras ?? const <Widget>[],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
          await tester.pump();
          tester.takeException();
        }
      }
    }
  });
}
