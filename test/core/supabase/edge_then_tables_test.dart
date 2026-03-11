import 'package:flutter_bloc_app/core/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/core/supabase/edge_then_tables.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_data_exception.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SecretConfig.resetForTest();
    SupabaseBootstrapService.resetForTest();
    SecretConfig.storage = InMemorySecretStorage();
  });

  tearDown(() {
    SecretConfig.resetForTest();
    SupabaseBootstrapService.resetForTest();
  });

  group('runSupabaseEdgeThenTables', () {
    test('throws when Supabase is not configured', () async {
      await expectLater(
        runSupabaseEdgeThenTables<int>(
          tryEdge: () async => <int>[1],
          fetchTables: () async => <int>[2],
          onPostgrestException: (final e) => Exception(e.message),
          onGenericException: (final message, final cause) =>
              Exception('$message $cause'),
          logContext: 'edgeThenTablesTest',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('returns edge results when edge succeeds', () async {
      await _initializeSupabaseForTest();
      bool fetchedTables = false;

      final SupabaseEdgeThenTablesResult<int> result =
          await runSupabaseEdgeThenTables<int>(
            tryEdge: () async => <int>[1, 2, 3],
            fetchTables: () async {
              fetchedTables = true;
              return <int>[4, 5, 6];
            },
            onPostgrestException: (final e) => Exception(e.message),
            onGenericException: (final message, final cause) =>
                Exception('$message $cause'),
            logContext: 'edgeThenTablesTest',
          );

      expect(result.result, <int>[1, 2, 3]);
      expect(result.fromEdge, isTrue);
      expect(fetchedTables, isFalse);
    });

    test('falls back to tables when edge returns empty', () async {
      await _initializeSupabaseForTest();

      final SupabaseEdgeThenTablesResult<int> result =
          await runSupabaseEdgeThenTables<int>(
            tryEdge: () async => const <int>[],
            fetchTables: () async => <int>[4, 5, 6],
            onPostgrestException: (final e) => Exception(e.message),
            onGenericException: (final message, final cause) =>
                Exception('$message $cause'),
            logContext: 'edgeThenTablesTest',
          );

      expect(result.result, <int>[4, 5, 6]);
      expect(result.fromEdge, isFalse);
    });

    test(
      'maps PostgrestException through repository-specific mapping',
      () async {
        await _initializeSupabaseForTest();
        final PostgrestException failure = PostgrestException(
          message: 'table exploded',
          code: '500',
        );

        await expectLater(
          runSupabaseEdgeThenTables<int>(
            tryEdge: () async => throw failure,
            fetchTables: () async => <int>[4, 5, 6],
            onPostgrestException: (final e) =>
                ChartDataException(e.message, cause: e),
            onGenericException: (final message, final cause) =>
                ChartDataException(message, cause: cause),
            logContext: 'edgeThenTablesTest',
          ),
          throwsA(
            isA<ChartDataException>()
                .having(
                  (final ChartDataException error) => error.message,
                  'message',
                  'table exploded',
                )
                .having(
                  (final ChartDataException error) => error.cause,
                  'cause',
                  same(failure),
                ),
          ),
        );
      },
    );

    test('maps generic failures with provided message and cause', () async {
      await _initializeSupabaseForTest();
      final StateError failure = StateError('boom');

      await expectLater(
        runSupabaseEdgeThenTables<int>(
          tryEdge: () async => throw failure,
          fetchTables: () async => <int>[4, 5, 6],
          onPostgrestException: (final e) =>
              ChartDataException(e.message, cause: e),
          onGenericException: (final message, final cause) =>
              ChartDataException(message, cause: cause),
          logContext: 'edgeThenTablesTest',
          genericFailureMessage: 'Failed to load chart data from Supabase',
        ),
        throwsA(
          isA<ChartDataException>()
              .having(
                (final ChartDataException error) => error.message,
                'message',
                'Failed to load chart data from Supabase',
              )
              .having(
                (final ChartDataException error) => error.cause,
                'cause',
                same(failure),
              ),
        ),
      );
    });
  });
}

Future<void> _initializeSupabaseForTest() async {
  SecretConfig.debugEnvironment = <String, dynamic>{
    'SUPABASE_URL': 'https://example.supabase.co',
    'SUPABASE_ANON_KEY': 'anon-key',
  };
  SupabaseBootstrapService.initializeClient =
      ({required final String url, required final String anonKey}) async {};
  await SecretConfig.load(persistToSecureStorage: false);
  await SupabaseBootstrapService.initializeSupabase();
}
