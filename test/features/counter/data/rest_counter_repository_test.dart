import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/counter/data/rest_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:http/http.dart' as http;

void main() {
  group('RestCounterRepository.load', () {
    test('parses successful payloads', () async {
      final DateTime now = DateTime.fromMillisecondsSinceEpoch(1710000000000);
      final _FakeClient client = _FakeClient(
        getHandler: (http.BaseRequest request) {
          expect(request.url.toString(), 'https://api.example.com/counter');
          return http.Response(
            jsonEncode(<String, dynamic>{
              'id': 'user-123',
              'count': 7,
              'last_changed': now.millisecondsSinceEpoch,
            }),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        },
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

    test('returns empty snapshot on HTTP failure', () async {
      final _FakeClient client = _FakeClient(
        getHandler: (_) => http.Response('nope', 500),
      );
      final RestCounterRepository repository = RestCounterRepository(
        baseUrl: 'https://api.example.com/',
        client: client,
      );

      await AppLogger.silenceAsync(() async {
        final CounterSnapshot snapshot = await repository.load();

        expect(snapshot.count, 0);
        expect(snapshot.userId, 'rest');
      });
    });
  });

  group('RestCounterRepository.save', () {
    test('posts JSON payload and emits saved snapshot', () async {
      final _Requests requests = _Requests();
      final _FakeClient client = _FakeClient(
        getHandler: (_) => http.Response('null', 200),
        postHandler: (http.BaseRequest request, String body) {
          requests.record(request, body);
          return http.Response('', 204);
        },
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

        expect(requests.lastRequest?.method, 'POST');
        final String? contentType =
            requests.lastRequest?.headers['Content-Type'];
        expect(contentType, isNotNull);
        expect(contentType, startsWith('application/json'));
        final Map<String, dynamic> body = jsonDecode(requests.lastBody ?? '{}');
        expect(body['count'], 3);
        expect(body['last_changed'], 42);
        expect(body['userId'], isNull);

        expect(emitted.length, greaterThanOrEqualTo(2));
        final CounterSnapshot saved = emitted.last;
        expect(saved.count, 3);
        expect(saved.userId, 'rest');
      });
    });
  });
}

class _FakeClient extends http.BaseClient {
  _FakeClient({
    http.Response Function(http.BaseRequest request)? getHandler,
    http.Response Function(http.BaseRequest request, String body)? postHandler,
  }) : _getHandler = getHandler,
       _postHandler = postHandler;

  final http.Response Function(http.BaseRequest request)? _getHandler;
  final http.Response Function(http.BaseRequest request, String body)?
  _postHandler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request.method == 'GET') {
      final http.Response response =
          _getHandler?.call(request) ?? http.Response('not found', 404);
      return _asStreamed(response);
    }
    if (request.method == 'POST') {
      final Uint8List bytes = await request.finalize().toBytes();
      final String body = utf8.decode(bytes);
      final http.Response response =
          _postHandler?.call(request, body) ?? http.Response('', 204);
      return _asStreamed(response);
    }
    return _asStreamed(http.Response('unsupported', 400));
  }

  http.StreamedResponse _asStreamed(http.Response response) {
    return http.StreamedResponse(
      Stream<List<int>>.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      reasonPhrase: response.reasonPhrase,
    );
  }
}

class _Requests {
  http.BaseRequest? lastRequest;
  String? lastBody;

  void record(http.BaseRequest request, String body) {
    lastRequest = request;
    lastBody = body;
  }
}
