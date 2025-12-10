import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/features/deeplink/data/app_links_deep_link_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(AppLinksDeepLinkService.debugResetPluginAvailability);

  test('linkStream emits URIs provided by the API stream', () async {
    final StreamController<Uri?> controller = StreamController<Uri?>();
    final FakeAppLinksApi api = FakeAppLinksApi(uriStream: controller.stream);
    final AppLinksDeepLinkService service = AppLinksDeepLinkService(api: api);

    final Uri expected = Uri.parse('app://example/path');
    final Future<Uri> resultFuture = service.linkStream().first;
    controller.add(expected);

    expect(await resultFuture, expected);

    await controller.close();
  });

  test(
    'linkStream disables plugin usage after MissingPluginException from stream',
    () async {
      final StreamController<Uri?> controller = StreamController<Uri?>();
      final FakeAppLinksApi api = FakeAppLinksApi(uriStream: controller.stream);
      final AppLinksDeepLinkService service = AppLinksDeepLinkService(api: api);

      bool isDone = false;
      service.linkStream().listen(
        (_) {},
        onDone: () {
          isDone = true;
        },
      );

      controller.addError(MissingPluginException());
      await pumpEventQueue();

      expect(isDone, isTrue);
      expect(await service.linkStream().isEmpty, isTrue);

      await controller.close();
    },
  );

  test('getInitialLink delegates to the API', () async {
    final Uri initial = Uri.parse('app://initial');
    final FakeAppLinksApi api = FakeAppLinksApi(initialUri: initial);
    final AppLinksDeepLinkService service = AppLinksDeepLinkService(api: api);

    expect(await service.getInitialLink(), initial);
  });

  test(
    'getInitialLink caches MissingPluginException and returns null',
    () async {
      final FakeAppLinksApi api = FakeAppLinksApi(
        initialUriError: MissingPluginException(),
      );
      final AppLinksDeepLinkService service = AppLinksDeepLinkService(api: api);

      expect(await service.getInitialLink(), isNull);
      expect(await service.linkStream().isEmpty, isTrue);
    },
  );

  test(
    'linkStream closes controller when MissingPluginException is thrown during listen setup',
    () async {
      final FakeAppLinksApi api = FakeAppLinksApi(
        throwsOnListen: MissingPluginException(),
      );
      final AppLinksDeepLinkService service = AppLinksDeepLinkService(api: api);

      bool isDone = false;
      service.linkStream().listen(
        (_) {},
        onDone: () {
          isDone = true;
        },
      );

      await pumpEventQueue();

      expect(isDone, isTrue);
      expect(await service.linkStream().isEmpty, isTrue);
    },
  );
}

class FakeAppLinksApi implements AppLinksApi {
  FakeAppLinksApi({
    Stream<Uri?>? uriStream,
    this.initialUri,
    this.initialUriError,
    this.throwsOnListen,
  }) : _uriStream = uriStream ?? const Stream<Uri?>.empty();

  final Stream<Uri?> _uriStream;

  final Uri? initialUri;
  final Object? initialUriError;
  final Object? throwsOnListen;

  @override
  Stream<Uri?> get uriLinkStream {
    if (throwsOnListen != null) {
      throw throwsOnListen!;
    }
    return _uriStream;
  }

  @override
  Future<Uri?> getInitialUri() {
    if (initialUriError != null) {
      return Future<Uri?>.error(initialUriError!);
    }
    return Future<Uri?>.value(initialUri);
  }
}
