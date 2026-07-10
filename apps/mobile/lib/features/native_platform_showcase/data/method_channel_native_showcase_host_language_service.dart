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

  @override
  Future<NativeInteropCallResult> triggerHaptic() async {
    final NativeInteropBridgeKind? kind = _mobileBridgeKindOrNull();
    if (kind == null) {
      return NativeInteropCallResult(
        kind: _unavailableBridgeKind(),
        status: NativeInteropStatus.unavailable,
        message: 'Haptic feedback runs on iOS and Android only.',
      );
    }
    return _invoke(method: 'triggerHaptic', kind: kind);
  }

  @override
  Future<NativeInteropCallResult> shareText(final String text) async {
    final String trimmed = text.trim();
    final NativeInteropBridgeKind kind =
        _mobileBridgeKindOrNull() ?? _unavailableBridgeKind();
    if (trimmed.isEmpty) {
      return NativeInteropCallResult(
        kind: kind,
        status: NativeInteropStatus.failed,
        message: 'Share text must not be empty.',
      );
    }
    if (_mobileBridgeKindOrNull() == null) {
      return NativeInteropCallResult(
        kind: kind,
        status: NativeInteropStatus.unavailable,
        message: 'System share runs on iOS and Android only.',
      );
    }
    return _invoke(
      method: 'shareText',
      kind: kind,
      arguments: <String, Object?>{'text': trimmed},
    );
  }

  static const Duration _invokeTimeout = Duration(seconds: 2);

  NativeInteropBridgeKind? _mobileBridgeKindOrNull() {
    if (kIsWeb) {
      return null;
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => NativeInteropBridgeKind.swift,
      TargetPlatform.android => NativeInteropBridgeKind.kotlin,
      _ => null,
    };
  }

  NativeInteropBridgeKind _unavailableBridgeKind() {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      return NativeInteropBridgeKind.swift;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return NativeInteropBridgeKind.kotlin;
    }
    return NativeInteropBridgeKind.swift;
  }

  Future<NativeInteropCallResult> _invoke({
    required final String method,
    required final NativeInteropBridgeKind kind,
    final Map<String, Object?>? arguments,
  }) async {
    try {
      final Object? response = await _channel
          .invokeMethod<Object?>(method, arguments)
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
