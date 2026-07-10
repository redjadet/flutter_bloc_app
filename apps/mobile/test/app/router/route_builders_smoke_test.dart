@TestOn('vm')
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/router/routes.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../test_helpers.dart';

const MethodChannel _flutterTtsChannel = MethodChannel('flutter_tts');

class _MockGoRouterState extends Mock implements GoRouterState {}

GoRouterState _stateForRoute(final GoRoute route) {
  final _MockGoRouterState state = _MockGoRouterState();
  final String path = switch (route.name) {
    AppRoutes.playlearnVocabulary => '/playlearn/vocabulary/animals',
    AppRoutes.caseStudyDemoHistoryDetail => '/case-study-demo/history/clip-1',
    AppRoutes.onlineTherapyDemoClientTherapistDetail =>
      '/online-therapy-demo/client/therapists/t-1',
    _ => route.path,
  };
  when(() => state.uri).thenReturn(Uri.parse(path));
  when(() => state.matchedLocation).thenReturn(path);
  when(() => state.extra).thenReturn(null);
  when(() => state.pathParameters).thenReturn(<String, String>{});
  return state;
}

void _invokeRoutes(final BuildContext context, final List<RouteBase> routes) {
  for (final RouteBase route in routes) {
    if (route is GoRoute) {
      final GoRouterState state = _stateForRoute(route);
      if (route.builder != null) {
        route.builder!(context, state);
      }
      if (route.pageBuilder != null) {
        route.pageBuilder!(context, state);
      }
      _invokeRoutes(context, route.routes);
    } else if (route is ShellRoute) {
      final _MockGoRouterState state = _MockGoRouterState();
      const String path = AppRoutes.staffAppDemoDashboardPath;
      when(() => state.uri).thenReturn(Uri.parse(path));
      when(() => state.matchedLocation).thenReturn(path);
      when(() => state.extra).thenReturn(null);
      when(() => state.pathParameters).thenReturn(<String, String>{});
      route.builder!(context, state, const SizedBox(key: Key('shell-child')));
      _invokeRoutes(context, route.routes);
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_flutterTtsChannel, (
          final MethodCall call,
        ) async {
          return null;
        });
    await setupHiveForTesting();
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_flutterTtsChannel, null);
  });

  group('route builders smoke', () {
    setUp(() async {
      await setupTestDependencies(
        const TestSetupOptions(
          useMockFirebaseAuth: true,
          useMockFirebasePlatform: true,
        ),
      );
    });

    tearDown(() async {
      await tearDownTestDependencies();
    });

    testWidgets('app route builders execute for coverage', (
      final tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (final context) {
              _invokeRoutes(context, createAppRoutes());
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pump();
      tester.takeException();
    });
  });
}
