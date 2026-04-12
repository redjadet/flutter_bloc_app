import 'package:dio/dio.dart';

/// Dedicated Dio for Render chat — no shared retry/auth interceptors.
Dio createRenderChatDio({required final String baseUrl}) {
  final String trimmed = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
  final String resolved = trimmed.isEmpty ? 'http://127.0.0.1' : trimmed;
  return Dio(
    BaseOptions(
      baseUrl: resolved,
      connectTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 120),
      followRedirects: false,
      validateStatus: (status) => status != null && status < 600,
      headers: const <String, dynamic>{
        Headers.contentTypeHeader: Headers.jsonContentType,
      },
    ),
  );
}
