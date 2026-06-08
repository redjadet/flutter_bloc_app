import 'dart:ffi' as ffi;
import 'dart:io' show Platform;

import 'package:ffi/ffi.dart';

typedef _NativeShowcaseGreetingDart = ffi.Pointer<ffi.Char> Function();

typedef _NativeShowcaseAddDart = int Function(int left, int right);

final class NativeShowcaseFfiBindings {
  NativeShowcaseFfiBindings._({
    required this._greeting,
    required this._add,
  });

  factory NativeShowcaseFfiBindings.open() {
    final ffi.DynamicLibrary library = _openLibrary();
    return NativeShowcaseFfiBindings._(
      greeting: library
          .lookupFunction<
            ffi.Pointer<ffi.Char> Function(),
            _NativeShowcaseGreetingDart
          >(
            'native_showcase_greeting',
          ),
      add: library
          .lookupFunction<
            ffi.Int32 Function(ffi.Int32, ffi.Int32),
            _NativeShowcaseAddDart
          >(
            'native_showcase_add',
          ),
    );
  }

  final _NativeShowcaseGreetingDart _greeting;
  final _NativeShowcaseAddDart _add;

  String greeting() => _greeting().cast<Utf8>().toDartString();

  int add({required final int left, required final int right}) =>
      _add(left, right);

  static ffi.DynamicLibrary _openLibrary() {
    if (Platform.isAndroid) {
      return ffi.DynamicLibrary.open('libnative_showcase.so');
    }
    if (Platform.isIOS || Platform.isMacOS) {
      return ffi.DynamicLibrary.process();
    }
    if (Platform.isLinux || Platform.isWindows) {
      return ffi.DynamicLibrary.executable();
    }
    throw UnsupportedError('FFI is not supported on this platform.');
  }
}
