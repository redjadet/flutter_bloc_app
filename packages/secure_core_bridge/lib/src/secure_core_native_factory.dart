import 'package:secure_core_bridge/src/ffi/ffi_stub.dart'
    if (dart.library.ffi) 'package:secure_core_bridge/src/ffi/ffi_io.dart';
import 'package:secure_core_bridge/src/native_api.dart';

/// Creates the platform-appropriate native API (IO FFI or web stub).
SecureCoreNativeApi createSecureCoreNativeApi() =>
    createPlatformSecureCoreNativeApi();
