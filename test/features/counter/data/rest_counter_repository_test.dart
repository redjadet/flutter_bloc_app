import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/features/counter/data/rest_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_error.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_test/flutter_test.dart';

Dio createCounterMockDio({
  String? getBody,
  int getStatus = 200,
  String? postBody,
  int postStatus = 204,
  CounterTestRequests? requests,
}) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.method == 'GET') {
          handler.resolve(
            Response<String>(
              requestOptions: options,
              data: getBody ?? '{}',
              statusCode: getStatus,
            ),
          );
        } else if (options.method == 'POST') {
          final Map<String, String> headers = <String, String>{};
          options.headers.forEach((final k, final v) {
            if (v != null) headers[k] = v.toString();
          });
          requests?.record(
            options.method,
            options.uri.toString(),
            options.data is String ? options.data as String? : null,
            headers,
          );
          handler.resolve(
            Response<String>(
              requestOptions: options,
              data: postBody ?? '',
              statusCode: postStatus,
            ),
          );
        } else {
          handler.resolve(
            Response<String>(
              requestOptions: options,
              data: '',
              statusCode: 400,
            ),
          );
        }
      },
    ),
  );
  return dio;
}

void main() {
  group('RestCounterRepository.constructor', () {
    test('throws ArgumentError for invalid or unsupported baseUrl', () {
      expect(
        () => RestCounterRepository(baseUrl: 'not-a-uri'),
        throwsArgumentError,
      );
      expect(
        () => RestCounterRepository(baseUrl: 'https://'),
        throwsArgumentError,
      );
      expect(
        () => RestCounterRepository(baseUrl: 'ws://api.example.com'),
        throwsArgumentError,
      );
    });

    test(
      'normalizes base path without trailing slash before resolve',
      () async {
        final Dio client = createCounterMockDio(
          getBody: jsonEncode(<String, dynamic>{'id': 'u1', 'count': 1}),
          getStatus: 200,
        );
        final RestCounterRepository repository = RestCounterRepository(
          baseUrl: 'https://api.example.com/v1',
          client: client,
        );

        await AppLogger.silenceAsync(repository.load);
      },
    );
  });

  group('RestCounterRepository.load', () {
    test('parses successful payloads', () async {
      final DateTime now = DateTime.fromMillisecondsSinceEpoch(1710000000000);
      final Dio client = createCounterMockDio(
        getBody: jsonEncode(<String, dynamic>{
          'id': 'user-123',
          'count': 7,
          'last_changed': now.millisecondsSinceEpoch,
        }),
        getStatus: 200,
      );
      final RestCounterRepository repository = RestCounterRepository(
        baseUrl: 'https://api.example.com/',
        client: client,
      );

      await AppLogger.silenceAsync(() async {
        final CounterSnapshot snapshot = await repository.load();

        expect(snapshot.userId, 'user-123');
        expect(snapshot.count, 7);
        expect(snapshot.lastChanged, isNotNull);
        expect(
          snapshot.lastChanged!.millisecondsSinceEpoch,
          now.millisecondsSinceEpoch,
        );
      });
    });

    test('parses count and last_changed when sent as strings', () async {
      final Dio client = createCounterMockDio(
        getBody: jsonEncode(<String, dynamic>{
          'userId': 'u2',
          'count': ' 12 ',
          'last_changed': ' 1710000000000 ',
        }),
        getStatus: 200,
      );
      final RestCounterRepository repository = RestCounterRepository(
        baseUrl: 'https://api.example.com/',
        client: client,
      );

      await AppLogger.silenceAsync(() async {
        final CounterSnapshot snapshot = await repository.load();
        expect(snapshot.userId, 'u2');
        expect(snapshot.count, 12);
        expect(snapshot.lastChanged, isNotNull);
        expect(snapshot.lastChanged!.millisecondsSinceEpoch, 1710000000000);
      });
    });

    test('throws CounterError on HTTP failure', () async {
      final Dio client = createCounterMockDio(getBody: 'nope', getStatus: 500);
      final RestCounterRepository repository = RestCounterRepository(
        baseUrl: 'https://api.example.com/',
        client: client,
      );

      await expectLater(
        AppLogger.silenceAsync(repository.load),
        throwsA(
          isA<CounterError>().having(
            (CounterError error) => error.type,
            'type',
            CounterErrorType.loadError,
          ),
        ),
      );
    });

    test('throws CounterError on malformed payload', () async {
      final Dio client = createCounterMockDio(getBody: '[]', getStatus: 200);
      final RestCounterRepository repository = RestCounterRepository(
        baseUrl: 'https://api.example.com/',
        client: client,
      );

      await expectLater(
        AppLogger.silenceAsync(repository.load),
        throwsA(isA<CounterError>()),
      );
    });

    test('falls back to default userId for non-string id fields', () async {
      final Dio client = createCounterMockDio(
        getBody: jsonEncode(<String, dynamic>{
          'userId': 42,
          'id': <String, dynamic>{'nested': true},
          'count': 3,
        }),
        getStatus: 200,
      );
      final RestCounterRepository repository = RestCounterRepository(
        baseUrl: 'https://api.example.com/',
        client: client,
      );

      await AppLogger.silenceAsync(() async {
        final CounterSnapshot snapshot = await repository.load();
        expect(snapshot.userId, 'rest');
        expect(snapshot.count, 3);
      });
    });
  });

  group('RestCounterRepository.save', () {
    test('posts JSON payload and emits saved snapshot', () async {
      final CounterTestRequests requests = CounterTestRequests();
      final Dio client = createCounterMockDio(
        getBody: jsonEncode(<String, dynamic>{
          'id': 'user-abc',
          'count': 5,
          'last_changed': 99,
        }),
        getStatus: 200,
        postStatus: 204,
        requests: requests,
      );
      final RestCounterRepository repository = RestCounterRepository(
        baseUrl: 'https://api.example.com/',
        client: client,
      );

      await AppLogger.silenceAsync(() async {
        final List<CounterSnapshot> emitted = <CounterSnapshot>[];
        final StreamSubscription<CounterSnapshot> subscription = repository
            .watch()
            .listen(emitted.add);
        await pumpEventQueue();

        final CounterSnapshot snapshot = CounterSnapshot(
          count: 3,
          lastChanged: DateTime.fromMillisecondsSinceEpoch(42),
        );
        await repository.save(snapshot);
        await pumpEventQueue();

        await subscription.cancel();

        expect(requests.lastMethod, 'POST');
        final String? contentType = requests.lastHeaders?['Content-Type'];
        expect(contentType, isNotNull);
        expect(contentType, startsWith('application/json'));
        final Map<String, dynamic> body = jsonDecode(requests.lastBody ?? '{}');
        expect(body['count'], 3);
        expect(body['last_changed'], 42);
        expect(body['userId'], 'rest');

        expect(emitted.length, 2);
        final CounterSnapshot initialRemote = emitted.first;
        expect(initialRemote.count, 5);
        expect(initialRemote.userId, 'user-abc');

        final CounterSnapshot saved = emitted.last;
        expect(saved.count, 3);
        expect(saved.userId, 'rest');
      });
    });

    test('provides cached snapshot to new watch subscribers', () async {
      final Dio client = createCounterMockDio(
        getBody: jsonEncode(<String, dynamic>{'id': 'user-xyz', 'count': 11}),
        getStatus: 200,
      );
      final RestCounterRepository repository = RestCounterRepository(
        baseUrl: 'https://api.example.com/',
        client: client,
      );

      await AppLogger.silenceAsync(() async {
        final List<CounterSnapshot> first = <CounterSnapshot>[];
        final StreamSubscription<CounterSnapshot> a = repository.watch().listen(
          first.add,
        );
        await pumpEventQueue();
        await a.cancel();

        expect(first.last.count, 11);

        final List<CounterSnapshot> second = <CounterSnapshot>[];
        final StreamSubscription<CounterSnapshot> b = repository.watch().listen(
          second.add,
        );
        await pumpEventQueue();
        await b.cancel();

        expect(second.first.count, 11);
        expect(second.first.userId, 'user-xyz');
      });
    });

    test('preserves provided userId when saving snapshots', () async {
      final CounterTestRequests requests = CounterTestRequests();
      final Dio client = createCounterMockDio(
        postStatus: 200,
        requests: requests,
      );
      final RestCounterRepository repository = RestCounterRepository(
        baseUrl: 'https://api.example.com/',
        client: client,
      );

      await AppLogger.silenceAsync(() async {
        final CounterSnapshot snapshot = CounterSnapshot(
          userId: 'custom-user',
          count: 8,
          lastChanged: DateTime.fromMillisecondsSinceEpoch(314),
        );
        await repository.save(snapshot);

        final Map<String, dynamic> body = jsonDecode(requests.lastBody ?? '{}');
        expect(body['userId'], 'custom-user');
        expect(body['count'], 8);
        expect(body['last_changed'], 314);
      });
    });
  });

  test('throws CounterError.save when backend rejects write', () async {
    final Dio client = createCounterMockDio(
      getBody: jsonEncode(<String, dynamic>{
        'id': 'user-seed',
        'count': 2,
        'last_changed': 5,
      }),
      getStatus: 200,
      postBody: 'nope',
      postStatus: 500,
    );
    final RestCounterRepository repository = RestCounterRepository(
      baseUrl: 'https://api.example.com/',
      client: client,
    );
    final List<CounterSnapshot> emitted = <CounterSnapshot>[];
    final StreamSubscription<CounterSnapshot> sub = repository.watch().listen(
      emitted.add,
    );
    await pumpEventQueue();
    expect(emitted, isNotEmpty);
    final int initialLength = emitted.length;

    await expectLater(
      AppLogger.silenceAsync(() => repository.save(CounterSnapshot(count: 1))),
      throwsA(
        isA<CounterError>().having(
          (CounterError error) => error.type,
          'type',
          CounterErrorType.saveError,
        ),
      ),
    );
    await pumpEventQueue();
    expect(emitted.length, initialLength);
    await sub.cancel();
  });

  test('watch receives error when initial load fails', () async {
    await AppLogger.silenceAsync(() async {
      final Dio client = createCounterMockDio(getBody: 'bad', getStatus: 500);
      final RestCounterRepository repository = RestCounterRepository(
        baseUrl: 'https://api.example.com/',
        client: client,
      );

      final List<Object?> errors = <Object?>[];
      final StreamSubscription<CounterSnapshot> sub = repository.watch().listen(
        (_) {},
        onError: errors.add,
      );
      await pumpEventQueue();
      expect(errors, isNotEmpty);
      expect(errors.first, isA<CounterError>());
      await sub.cancel();
    });
  });

  group('Common Bugs Prevention', () {
    test(
      'does not throw when addError is called after controller is closed',
      () async {
        await AppLogger.silenceAsync(() async {
          final Dio client = createCounterMockDio(
            getBody: 'bad',
            getStatus: 500,
          );
          final RestCounterRepository repository = RestCounterRepository(
            baseUrl: 'https://api.example.com/',
            client: client,
          );

          final StreamSubscription<CounterSnapshot> sub = repository
              .watch()
              .listen((_) {}, onError: (_) {});

          await repository.dispose();

          await pumpEventQueue();

          expect(repository, isNotNull);
          await sub.cancel();
        });
      },
    );

    test(
      'does not throw when add is called after controller is closed',
      () async {
        await AppLogger.silenceAsync(() async {
          final Dio client = createCounterMockDio(
            getBody: jsonEncode(<String, dynamic>{'id': 'user-1', 'count': 5}),
            getStatus: 200,
          );
          final RestCounterRepository repository = RestCounterRepository(
            baseUrl: 'https://api.example.com/',
            client: client,
          );

          final StreamSubscription<CounterSnapshot> sub = repository
              .watch()
              .listen((_) {});

          await pumpEventQueue();

          await repository.dispose();

          await expectLater(
            repository.save(CounterSnapshot(count: 10)),
            completes,
          );

          await sub.cancel();
        });
      },
    );
  });
}

class CounterTestRequests {
  String? lastMethod;
  String? lastUrl;
  Map<String, String>? lastHeaders;
  String? lastBody;

  void record(
    final String method,
    final String url,
    final String? body, [
    final Map<String, String>? headers,
  ]) {
    lastMethod = method;
    lastUrl = url;
    lastBody = body;
    lastHeaders = headers;
  }
}
