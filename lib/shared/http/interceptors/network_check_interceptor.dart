import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';

/// Rejects requests when the device is offline.
class NetworkCheckInterceptor extends Interceptor {
  NetworkCheckInterceptor(this._networkStatusService);

  final NetworkStatusService _networkStatusService;

  @override
  void onRequest(
    final RequestOptions options,
    final RequestInterceptorHandler handler,
  ) {
    unawaited(_checkAndNext(options, handler));
  }

  Future<void> _checkAndNext(
    final RequestOptions options,
    final RequestInterceptorHandler handler,
  ) async {
    try {
      final NetworkStatus status = await _networkStatusService
          .getCurrentStatus();
      if (status == NetworkStatus.offline) {
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            message: 'No network connection available',
          ),
        );
        return;
      }
      handler.next(options);
    } on Object catch (error, stackTrace) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
