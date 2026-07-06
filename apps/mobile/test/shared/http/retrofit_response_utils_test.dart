import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:networking/networking.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retrofit/retrofit.dart';

void main() {
  group('bytesResponseFromHttpResponse', () {
    test('maps UTF-8 byte body into Dio response', () {
      const String body = '{"ok":true}';
      final RequestOptions requestOptions = RequestOptions(path: '/');
      final Response<List<int>> inner = Response<List<int>>(
        data: utf8.encode(body),
        requestOptions: requestOptions,
        statusCode: 200,
      );
      final HttpResponse<List<int>> httpResponse = HttpResponse(
        inner.data!,
        inner,
      );

      final Response<List<int>> adapted = bytesResponseFromHttpResponse(
        httpResponse,
      );

      expect(adapted.statusCode, 200);
      expect(utf8.decode(adapted.data!), body);
    });
  });
}
