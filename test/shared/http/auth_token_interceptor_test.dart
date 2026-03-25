import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/shared/http/app_dio.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockUser extends Mock implements User {}

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockIdTokenResult extends Mock implements IdTokenResult {}

class _TestNetworkStatusService implements NetworkStatusService {
  _TestNetworkStatusService({
    final Iterable<NetworkStatus> statuses = const <NetworkStatus>[],
    final NetworkStatus fallbackStatus = NetworkStatus.online,
  }) : _statuses = Queue<NetworkStatus>.from(statuses),
       _fallbackStatus = fallbackStatus;

  final Queue<NetworkStatus> _statuses;
  final NetworkStatus _fallbackStatus;
  int statusChecks = 0;

  @override
  Stream<NetworkStatus> get statusStream => const Stream<NetworkStatus>.empty();

  @override
  Future<NetworkStatus> getCurrentStatus() async {
    statusChecks += 1;
    if (_statuses.isNotEmpty) {
      return _statuses.removeFirst();
    }
    return _fallbackStatus;
  }

  @override
  Future<void> dispose() async {}
}

class _SequenceAdapter implements HttpClientAdapter {
  _SequenceAdapter(this._fetch);

  final Future<ResponseBody> Function(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  )
  _fetch;

  @override
  Future<ResponseBody> fetch(
    final RequestOptions options,
    final Stream<List<int>>? requestStream,
    final Future<void>? cancelFuture,
  ) => _fetch(options, requestStream, cancelFuture);

  @override
  void close({final bool force = false}) {}
}

void main() {
  group('AuthTokenInterceptor', () {
    late Dio dio;
    late _MockFirebaseAuth auth;
    late _MockUser user1;
    late _MockUser user2;
    late _MockIdTokenResult user1InitialResult;
    late _MockIdTokenResult user1RefreshedResult;
    late _MockIdTokenResult user2TokenResult;
    late _TestNetworkStatusService networkStatusService;

    setUp(() {
      auth = _MockFirebaseAuth();
      user1 = _MockUser();
      user2 = _MockUser();
      user1InitialResult = _MockIdTokenResult();
      user1RefreshedResult = _MockIdTokenResult();
      user2TokenResult = _MockIdTokenResult();
      networkStatusService = _TestNetworkStatusService();

      when(() => user1.uid).thenReturn('user-1');
      when(() => user2.uid).thenReturn('user-2');
      when(() => user1InitialResult.token).thenReturn('token-user-1-initial');
      when(
        () => user1InitialResult.expirationTime,
      ).thenReturn(DateTime.now().toUtc().add(const Duration(hours: 1)));
      when(
        () => user1RefreshedResult.token,
      ).thenReturn('token-user-1-refreshed');
      when(
        () => user1RefreshedResult.expirationTime,
      ).thenReturn(DateTime.now().toUtc().add(const Duration(hours: 1)));
      when(() => user2TokenResult.token).thenReturn('token-user-2');
      when(
        () => user2TokenResult.expirationTime,
      ).thenReturn(DateTime.now().toUtc().add(const Duration(hours: 1)));
    });

    Dio buildDio({
      final void Function(
        RequestOptions options,
        int? statusCode,
        String? error,
        int elapsedMilliseconds,
      )?
      telemetryEventSink,
      final Future<void> Function(Duration delay)? waitForRetryDelay,
      final int maxRetries = 1,
    }) {
      return createAppDio(
        networkStatusService: networkStatusService,
        userAgent: 'test-agent',
        firebaseAuth: auth,
        telemetryEventSink: telemetryEventSink,
        waitForRetryDelay: waitForRetryDelay,
        maxRetries: maxRetries,
      );
    }

    test(
      'retries a managed 401 with the original user token when current user changes',
      () async {
        User? currentUser = user1;
        when(() => auth.currentUser).thenAnswer((_) => currentUser);

        int user1TokenResultCalls = 0;
        when(() => user1.getIdTokenResult()).thenAnswer((_) async {
          user1TokenResultCalls += 1;
          return user1TokenResultCalls == 1
              ? user1InitialResult
              : user1RefreshedResult;
        });
        when(() => user1.getIdToken(true)).thenAnswer((_) async => 'forced-1');
        when(
          () => user2.getIdTokenResult(),
        ).thenAnswer((_) async => user2TokenResult);
        when(() => user2.getIdToken(true)).thenAnswer((_) async => 'forced-2');

        final List<String?> seenAuthorizationHeaders = <String?>[];
        int requestCount = 0;
        dio = buildDio();
        dio.httpClientAdapter = _SequenceAdapter((
          final options,
          final _,
          final cancelFuture,
        ) async {
          if (cancelFuture != null) {}
          requestCount += 1;
          seenAuthorizationHeaders.add(
            options.headers['Authorization'] as String?,
          );
          if (requestCount == 1) {
            currentUser = user2;
            return ResponseBody.fromString(
              jsonEncode(<String, Object?>{'error': 'unauthorized'}),
              401,
              headers: <String, List<String>>{
                Headers.contentTypeHeader: <String>[Headers.jsonContentType],
              },
            );
          }
          return ResponseBody.fromString(
            jsonEncode(<String, Object?>{'ok': true}),
            200,
            headers: <String, List<String>>{
              Headers.contentTypeHeader: <String>[Headers.jsonContentType],
            },
          );
        });

        final Response<dynamic> response = await dio.get<dynamic>(
          'https://example.com/protected',
        );

        expect(response.statusCode, 200);
        expect(seenAuthorizationHeaders, <String?>[
          'Bearer token-user-1-initial',
          'Bearer token-user-1-refreshed',
        ]);
        expect(networkStatusService.statusChecks, 2);
        verify(() => user1.getIdToken(true)).called(1);
        verifyNever(() => user2.getIdToken(true));
      },
    );

    test(
      'does not retry 401 for externally managed authorization headers',
      () async {
        when(() => auth.currentUser).thenReturn(user1);
        when(
          () => user1.getIdTokenResult(),
        ).thenAnswer((_) async => user1InitialResult);
        when(() => user1.getIdToken(true)).thenAnswer((_) async => 'forced-1');

        int requestCount = 0;
        dio = buildDio();
        dio.httpClientAdapter = _SequenceAdapter((
          final options,
          final _,
          final cancelFuture,
        ) async {
          if (cancelFuture != null) {}
          requestCount += 1;
          return ResponseBody.fromString(
            jsonEncode(<String, Object?>{'error': 'unauthorized'}),
            401,
            headers: <String, List<String>>{
              Headers.contentTypeHeader: <String>[Headers.jsonContentType],
            },
          );
        });

        final Response<dynamic> response = await dio.get<dynamic>(
          'https://example.com/protected',
          options: Options(
            headers: <String, Object?>{
              'Authorization': 'Bearer external-token',
            },
          ),
        );

        expect(response.statusCode, 401);
        expect(requestCount, 1);
        expect(networkStatusService.statusChecks, 1);
        verifyNever(() => user1.getIdToken(true));
      },
    );

    test('does not auth-retry non-idempotent methods by default', () async {
      when(() => auth.currentUser).thenReturn(user1);
      when(
        () => user1.getIdTokenResult(),
      ).thenAnswer((_) async => user1InitialResult);
      when(() => user1.getIdToken(true)).thenAnswer((_) async => 'forced-1');

      int requestCount = 0;
      dio = buildDio();
      dio.httpClientAdapter = _SequenceAdapter((
        final options,
        final _,
        final cancelFuture,
      ) async {
        if (cancelFuture != null) {}
        requestCount += 1;
        return ResponseBody.fromString(
          jsonEncode(<String, Object?>{'error': 'unauthorized'}),
          401,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>[Headers.jsonContentType],
          },
        );
      });

      final Response<dynamic> response = await dio.post<dynamic>(
        'https://example.com/protected',
        data: <String, Object?>{'x': 1},
      );

      expect(response.statusCode, 401);
      expect(requestCount, 1);
      verifyNever(() => user1.getIdToken(true));
    });

    test('auth-retries idempotent delete methods by default', () async {
      when(() => auth.currentUser).thenReturn(user1);
      when(
        () => user1.getIdTokenResult(),
      ).thenAnswer((_) async => user1InitialResult);
      when(() => user1.getIdToken(true)).thenAnswer((_) async => 'forced-1');

      int requestCount = 0;
      dio = buildDio();
      dio.httpClientAdapter = _SequenceAdapter((
        final options,
        final _,
        final cancelFuture,
      ) async {
        if (cancelFuture != null) {}
        requestCount += 1;
        if (requestCount == 1) {
          return ResponseBody.fromString(
            jsonEncode(<String, Object?>{'error': 'unauthorized'}),
            401,
            headers: <String, List<String>>{
              Headers.contentTypeHeader: <String>[Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString(
          jsonEncode(<String, Object?>{'ok': true}),
          200,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>[Headers.jsonContentType],
          },
        );
      });

      final Response<dynamic> response = await dio.delete<dynamic>(
        'https://example.com/protected',
      );

      expect(response.statusCode, 200);
      expect(requestCount, 2);
      verify(() => user1.getIdToken(true)).called(1);
    });

    test(
      'propagates retry DioException instead of returning the original 401 response',
      () async {
        when(() => auth.currentUser).thenReturn(user1);

        int user1TokenResultCalls = 0;
        when(() => user1.getIdTokenResult()).thenAnswer((_) async {
          user1TokenResultCalls += 1;
          return user1TokenResultCalls == 1
              ? user1InitialResult
              : user1RefreshedResult;
        });
        when(() => user1.getIdToken(true)).thenAnswer((_) async => 'forced-1');

        int requestCount = 0;
        dio = buildDio();
        dio.httpClientAdapter = _SequenceAdapter((
          final options,
          final _,
          final cancelFuture,
        ) async {
          if (cancelFuture != null) {}
          requestCount += 1;
          if (requestCount == 1) {
            return ResponseBody.fromString(
              jsonEncode(<String, Object?>{'error': 'unauthorized'}),
              401,
              headers: <String, List<String>>{
                Headers.contentTypeHeader: <String>[Headers.jsonContentType],
              },
            );
          }
          throw DioException(
            requestOptions: options,
            error: StateError('retry failed'),
          );
        });

        await expectLater(
          dio.get<dynamic>('https://example.com/protected'),
          throwsA(
            isA<DioException>().having(
              (final DioException error) => error.error,
              'error',
              isA<StateError>(),
            ),
          ),
        );

        expect(requestCount, 2);
        expect(networkStatusService.statusChecks, 2);
        verify(() => user1.getIdToken(true)).called(1);
      },
    );

    test(
      'uses shared retry, network, and telemetry interceptors for auth retries',
      () async {
        when(() => auth.currentUser).thenReturn(user1);

        int user1TokenResultCalls = 0;
        when(() => user1.getIdTokenResult()).thenAnswer((_) async {
          user1TokenResultCalls += 1;
          return user1TokenResultCalls == 1
              ? user1InitialResult
              : user1RefreshedResult;
        });
        when(() => user1.getIdToken(true)).thenAnswer((_) async => 'forced-1');

        int telemetryEventCount = 0;
        final List<String?> seenAuthorizationHeaders = <String?>[];
        int requestCount = 0;
        dio = buildDio(
          telemetryEventSink:
              (
                final options,
                final statusCode,
                final error,
                final elapsedMilliseconds,
              ) {
                telemetryEventCount += 1;
              },
          waitForRetryDelay: (final _) async {},
        );
        dio.httpClientAdapter = _SequenceAdapter((
          final options,
          final _,
          final cancelFuture,
        ) async {
          if (cancelFuture != null) {}
          requestCount += 1;
          seenAuthorizationHeaders.add(
            options.headers['Authorization'] as String?,
          );
          if (requestCount == 1) {
            return ResponseBody.fromString(
              jsonEncode(<String, Object?>{'error': 'unauthorized'}),
              401,
              headers: <String, List<String>>{
                Headers.contentTypeHeader: <String>[Headers.jsonContentType],
              },
            );
          }
          return ResponseBody.fromString(
            jsonEncode(<String, Object?>{'error': 'temporary'}),
            503,
            headers: <String, List<String>>{
              Headers.contentTypeHeader: <String>[Headers.jsonContentType],
            },
          );
        });

        final Response<dynamic> response = await dio.get<dynamic>(
          'https://example.com/protected',
        );

        // Auth replay is allowed once, but must not multiply attempts by also
        // entering RetryInterceptor.
        expect(response.statusCode, 503);
        expect(requestCount, 2);
        expect(networkStatusService.statusChecks, 2);
        expect(telemetryEventCount, greaterThanOrEqualTo(1));
        expect(seenAuthorizationHeaders, <String?>[
          'Bearer token-user-1-initial',
          'Bearer token-user-1-refreshed',
        ]);
        verify(() => user1.getIdToken(true)).called(1);
      },
    );

    test('blocks auth retry when retry transport is offline', () async {
      networkStatusService = _TestNetworkStatusService(
        statuses: <NetworkStatus>[NetworkStatus.online, NetworkStatus.offline],
      );
      when(() => auth.currentUser).thenReturn(user1);

      int user1TokenResultCalls = 0;
      when(() => user1.getIdTokenResult()).thenAnswer((_) async {
        user1TokenResultCalls += 1;
        return user1TokenResultCalls == 1
            ? user1InitialResult
            : user1RefreshedResult;
      });
      when(() => user1.getIdToken(true)).thenAnswer((_) async => 'forced-1');

      int requestCount = 0;
      dio = buildDio();
      dio.httpClientAdapter = _SequenceAdapter((
        final options,
        final _,
        final cancelFuture,
      ) async {
        if (cancelFuture != null) {}
        requestCount += 1;
        return ResponseBody.fromString(
          jsonEncode(<String, Object?>{'error': 'unauthorized'}),
          401,
          headers: <String, List<String>>{
            Headers.contentTypeHeader: <String>[Headers.jsonContentType],
          },
        );
      });

      await expectLater(
        dio.get<dynamic>('https://example.com/protected'),
        throwsA(
          isA<DioException>().having(
            (final DioException error) => error.type,
            'type',
            DioExceptionType.connectionError,
          ),
        ),
      );

      expect(requestCount, 1);
      expect(networkStatusService.statusChecks, 2);
      verify(() => user1.getIdToken(true)).called(1);
    });
  });
}
