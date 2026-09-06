# Secure Messaging Demo

Flutter demo proving Cubit → domain repository → FFI bridge → Rust AES-GCM
round trip.

Canonical guide: [`docs/features/secure_messaging_demo.md`](../../../../../docs/features/secure_messaging_demo.md).
Change brief: [`docs/changes/2026-09-06_secure_messaging_demo_rust_core.md`](../../../../../docs/changes/2026-09-06_secure_messaging_demo_rust_core.md).

## Limitations (demo-only)

- Process-ephemeral AES key: ciphertext is undecryptable after app restart.
- Not a messaging protocol, identity system, or production crypto product.
- Web shows “native core unavailable” (no simulated success).
- Linux is CI/host test only — not a supported product desktop target.

## Entry

Example hub → **Secure messaging demo** (`/secure-messaging-demo`).

## Layout

```text
secure_messaging_demo/
  domain/          SecureCoreRepository, EncryptedPayload, SecureCoreFailure
  data/            FfiSecureCoreRepository
  presentation/    Cubit, page, body, preview
```

## Proof (focused)

```bash
cd apps/mobile
flutter test test/features/secure_messaging_demo/
flutter test integration_test/secure_messaging_demo_flow_test.dart -d macos
```
