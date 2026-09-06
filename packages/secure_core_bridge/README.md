# Secure Core Bridge

Demo-only Dart FFI package wrapping the Rust `secure_core` crate
(AES-256-GCM, process-ephemeral key).

Architecture owner doc:
[`docs/architecture/rust_ffi_secure_core_bridge.md`](../../docs/architecture/rust_ffi_secure_core_bridge.md).

## Scope

| Target | Role |
| --- | --- |
| Android / iOS / macOS | Product native via consuming Flutter app |
| Linux | Ubuntu CI / host `dart test` only — **not** product desktop |
| Web | Stub → `SecureCoreNativeFailureKind.unavailable` |

## Layout

```text
packages/secure_core_bridge/
  hook/build.dart              # native_toolchain_rust
  rust/secure_core/            # Cargo.toml, rust-toolchain.toml (1.98.1), Cargo.lock, src/
  include/secure_core.h        # C ABI
  lib/src/ffi/                 # generated_bindings, ffi_io, ffi_stub
  lib/src/native_api.dart      # SecureCoreNativeApi
  test/                        # real bindings → Rust on host
```

## C ABI

| Symbol | Role |
| --- | --- |
| `secure_core_encrypt` | plaintext → owned envelope buffer |
| `secure_core_decrypt` | envelope → owned plaintext buffer |
| `secure_core_health_check` | runtime encrypt/decrypt self-test |
| `secure_core_version` | version string |
| `secure_core_buffer_free` | free owned buffer (Dart `finally`) |

Envelope: `format-version | 12-byte nonce | ciphertext | 16-byte tag`.
Max plaintext **64 KiB** UTF-8; Dart and Rust reject oversized input before
native slice/allocation work.

## Local requirements

```bash
rustc --version   # must be 1.98.1
cargo --version
```

CI installs the same pin via `.github/actions/setup-flutter-workspace`
(`install-rust: true`).

## Tests

```bash
bash tool/check_secure_core.sh   # bindings check + Cargo checks + real Dart → Rust tests
dart test packages/secure_core_bridge
dart run packages/secure_core_bridge/tool/generate_bindings.dart
dart run packages/secure_core_bridge/tool/generate_bindings.dart --check
```

## Security notice

Demo only. AES key is random and process-local; it is never persisted or
returned to Dart. Provider instances zeroize on drop, but the active provider is
process-static and remains until the OS reclaims process memory. Dart `String`
and returned `Uint8List` copies cannot be guaranteed wiped. Ciphertext cannot be
decrypted after process restart. Not production messaging security.
