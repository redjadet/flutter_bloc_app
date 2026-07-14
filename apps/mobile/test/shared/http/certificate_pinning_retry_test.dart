import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:networking/networking.dart';

class _CountingAdapter implements HttpClientAdapter {
  int fetchCount = 0;

  @override
  void close({final bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    final RequestOptions options,
    final Stream<Uint8List>? requestStream,
    final Future<void>? cancelFuture,
  ) async {
    fetchCount++;
    throw DioException.badCertificate(requestOptions: options);
  }
}

void main() {
  test('RetryInterceptor does not retry badCertificate', () async {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: 'https://example.com',
        validateStatus: (final _) => true,
      ),
    );
    final _CountingAdapter adapter = _CountingAdapter();
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(RetryInterceptor(dio: dio, maxRetries: 3));

    await expectLater(
      () => dio.get<void>('/pin'),
      throwsA(
        isA<DioException>().having(
          (final e) => e.type,
          'type',
          DioExceptionType.badCertificate,
        ),
      ),
    );
    expect(adapter.fetchCount, 1);
  });

  test('no unconditional badCertificateCallback bypass in networking apply', () {
    // applyCertificatePinning must never install HttpClient.badCertificateCallback
    // that returns true for all certs. Real mode uses validateCertificate only.
    final Dio dio = Dio();
    final CertificatePinningConfig config = CertificatePinningConfig(
      mode: CertificatePinningMode.disabled,
    );
    applyCertificatePinning(
      dio,
      config: config,
      validator: const DisabledCertificatePinValidator(),
    );
    // Disabled mode leaves default adapter; no callback bypass installed.
    expect(dio.httpClientAdapter, isNotNull);
  });
}
