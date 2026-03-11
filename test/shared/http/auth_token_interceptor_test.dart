import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/shared/http/auth_token_manager.dart';
import 'package:flutter_bloc_app/shared/http/interceptors/auth_token_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockUser extends Mock implements User {}

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockIdTokenResult extends Mock implements IdTokenResult {}

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

    setUp(() {
      auth = _MockFirebaseAuth();
      user1 = _MockUser();
      user2 = _MockUser();
      user1InitialResult = _MockIdTokenResult();
      user1RefreshedResult = _MockIdTokenResult();
      user2TokenResult = _MockIdTokenResult();

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
        dio = Dio(BaseOptions(validateStatus: (_) => true));
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
        dio.interceptors.add(
          AuthTokenInterceptor(
            authTokenManager: AuthTokenManager(firebaseAuth: auth),
            dio: dio,
            firebaseAuth: auth,
          ),
        );

        final Response<dynamic> response = await dio.get<dynamic>(
          'https://example.com/protected',
        );

        expect(response.statusCode, 200);
        expect(seenAuthorizationHeaders, <String?>[
          'Bearer token-user-1-initial',
          'Bearer token-user-1-refreshed',
        ]);
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
        dio = Dio(BaseOptions(validateStatus: (_) => true));
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
        dio.interceptors.add(
          AuthTokenInterceptor(
            authTokenManager: AuthTokenManager(firebaseAuth: auth),
            dio: dio,
            firebaseAuth: auth,
          ),
        );

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
        verifyNever(() => user1.getIdToken(true));
      },
    );

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
        dio = Dio(BaseOptions(validateStatus: (_) => true));
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
        dio.interceptors.add(
          AuthTokenInterceptor(
            authTokenManager: AuthTokenManager(firebaseAuth: auth),
            dio: dio,
            firebaseAuth: auth,
          ),
        );

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
        verify(() => user1.getIdToken(true)).called(1);
      },
    );
  });
}
