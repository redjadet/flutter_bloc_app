# Secure messaging demo (Flutter ↔ Rust)

Demo-only AES-256-GCM encrypt/decrypt round trip that proves Clean Architecture
wiring from Cubit through a domain repository into a workspace FFI package and
a pinned Rust crate.

## Entry

| Piece | Value |
| --- | --- |
| Route | `/secure-messaging-demo` (`AppRoutes.secureMessagingDemo`) |
| Example hub | `ValueKey('example-secure-messaging-demo-button')` |
| Feature module | `apps/mobile/lib/features/secure_messaging_demo/` |
| Bridge package | [`packages/secure_core_bridge/`](../../packages/secure_core_bridge/) |
| Change brief | [`../changes/2026-09-06_secure_messaging_demo_rust_core.md`](../changes/2026-09-06_secure_messaging_demo_rust_core.md) |
| Architecture note | [`../architecture/rust_ffi_secure_core_bridge.md`](../architecture/rust_ffi_secure_core_bridge.md) |

## Stack

```text
SecureMessagingDemoPage
  → SecureMessagingDemoCubit (sealed hand-written states)
  → SecureCoreRepository (domain, FFI-free)
  → FfiSecureCoreRepository (maps native exceptions → domain failures)
  → SecureCoreNativeApi (packages/secure_core_bridge)
  → Rust secure_core (AES-256-GCM, process-ephemeral key)
```

- **DI:** `register_secure_messaging_demo_services.dart` (from demo group)
- **Routes:** `routes_secure_messaging_demo.dart` + `DemoRouteFactory` field
- **l10n:** EN + TR authored; mirrored into de/es/fr/ar for key parity
- **States:** `initial | checkingHealth | ready | encrypting | encrypted | decrypting | success | failure | unavailable`

## Behaviour

- Health check + version on open
- Rejects empty/whitespace-only plaintext; preserves meaningful leading and
  trailing whitespace in the encrypted round trip
- Encrypt → base64 envelope shown; decrypt → recovered plaintext compared to retained input
- Request-generation guard + `_isRequestActive` (includes `isClosed`) after awaits
- Web: `unavailable` (stub; no fake success)
- Security banner: process-ephemeral key; ciphertext dies on restart

## Envelope (native)

`format-version | 12-byte nonce | ciphertext | 16-byte tag`
Max plaintext **64 KiB** UTF-8; maximum envelope **65,565 bytes**. Symbols:
`secure_core_encrypt|decrypt|health_check|version|buffer_free`.

## Platform policy

| Target | Support |
| --- | --- |
| Android / iOS / macOS | Product native (demo) |
| Web | Unsupported stub → unavailable UI |
| Linux | CI / host package + Cargo tests only — **not** product desktop |
| Windows | Deferred |

## Proof

```bash
# Rust
bash tool/check_secure_core.sh

# Bridge (real bindings → Rust on host)
dart test packages/secure_core_bridge

# Regenerate / verify C ABI bindings
dart run packages/secure_core_bridge/tool/generate_bindings.dart
dart run packages/secure_core_bridge/tool/generate_bindings.dart --check

# App feature
cd apps/mobile && flutter test test/features/secure_messaging_demo/

# macOS UI → Rust round trip
cd apps/mobile && flutter test integration_test/secure_messaging_demo_flow_test.dart -d macos
```

Selective CI map: `tool/integration_selective_map.json` → `secure_messaging_demo`.

## Explicit non-goals

Production keystore/enclave, sessions, messaging protocol, fuzz/Miri (optional later),
Linux/Windows product support.

## Security limitations

- Process-local demo key; no persistence, rotation, identity, provisioning, or
  hardware-backed storage.
- Rust output and Dart malloc input are zeroed before free. Dart VM strings and
  copied `Uint8List` values cannot be guaranteed wiped.
- Active process-static provider lives until OS process teardown; zeroization at
  shutdown is not guaranteed by this demo.
- Runtime health check is a round-trip self-test, not certification, protocol
  validation, or a formal known-answer test.
- Current synchronous FFI is limited to bounded 64 KiB demo messages. Future
  file/media/session work must move behind an isolate/worker or asynchronous
  native API to avoid UI-isolate blocking.
