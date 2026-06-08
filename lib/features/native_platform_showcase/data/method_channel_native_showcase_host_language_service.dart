import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_bridge_kind.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_call_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_status.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_host_language_service.dart';

/// MethodChannel implementation of [NativeShowcaseHostLanguageService].
///
/// Transitional interop path: Swift (iOS/macOS) and Kotlin (Android) via
/// platform embedder. Replace with SwiftGen / JNI adapters without touching
/// domain or presentation.
class MethodChannelNativeShowcaseHostLanguageService
    implements NativeShowcaseHostLanguageService {
  const MethodChannelNativeShowcaseHostLanguageService({
    final MethodChannel? channel,
  }) : _channel =
           channel ??
           const MethodChannel('com.example.flutter_bloc_app/native_showcase');

  final MethodChannel _channel;

  @override
  Future<NativeInteropCallResult> invokeSwift() async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      return _invoke(
        method: 'invokeSwift',
        kind: NativeInteropBridgeKind.swift,
      );
    }
    return const NativeInteropCallResult(
      kind: NativeInteropBridgeKind.swift,
      status: NativeInteropStatus.unavailable,
      message: 'Swift bridge runs on iOS and macOS only.',
    );
  }

  @override
  Future<NativeInteropCallResult> invokeKotlin() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return _invoke(
        method: 'invokeKotlin',
        kind: NativeInteropBridgeKind.kotlin,
      );
    }
    return const NativeInteropCallResult(
      kind: NativeInteropBridgeKind.kotlin,
      status: NativeInteropStatus.unavailable,
      message: 'Kotlin bridge runs on Android only.',
    );
  }

  static const Duration _invokeTimeout = Duration(seconds: 2);

  Future<NativeInteropCallResult> _invoke({
    required final String method,
    required final NativeInteropBridgeKind kind,
  }) async {
    try {
      final Object? response = await _channel
          .invokeMethod<Object?>(method)
          .timeout(
            _invokeTimeout,
            onTimeout: () => throw MissingPluginException(
              'Native host handler did not respond in time.',
            ),
          );
      final String message = response?.toString() ?? '';
      if (message.isEmpty) {
        return NativeInteropCallResult(
          kind: kind,
          status: NativeInteropStatus.failed,
          message: 'Empty response from native host.',
        );
      }
      return NativeInteropCallResult(
        kind: kind,
        status: NativeInteropStatus.success,
        message: message,
      );
    } on MissingPluginException {
      return NativeInteropCallResult(
        kind: kind,
        status: NativeInteropStatus.unavailable,
        message: 'Native host handler is not registered.',
      );
    } on PlatformException catch (error) {
      return NativeInteropCallResult(
        kind: kind,
        status: NativeInteropStatus.failed,
        message: error.message ?? 'Platform channel failed.',
      );
    } on Object catch (error) {
      return NativeInteropCallResult(
        kind: kind,
        status: NativeInteropStatus.failed,
        message: error.toString(),
      );
    }
  }
}
