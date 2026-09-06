# Feature: Secure Messaging Demo (Rust core)

Date: 2026-09-06

## Problem

Need an in-repo, reviewable proof that Flutter Cubit → domain → data → FFI →
native crypto works end-to-end without claiming production messaging security.

## Scope

- **In:** `packages/secure_core_bridge` (Rust AES-256-GCM + Dart FFI hooks),
  `secure_messaging_demo` feature (domain/data/Cubit/page), DI/routes/Example/l10n,
  Cargo + package + app tests, macOS integration round trip, CI Rust 1.98.1 install,
  `tool/check_secure_core.sh` in checklist
- **Out:** keystore/enclave, protocol/session layer, fuzz/Miri, Linux/Windows product
  desktop support, Freezed (blocked by workspace analyzer override)

## Layers touched

- [x] domain
- [x] data
- [x] presentation
- [x] DI
- [x] routes / l10n
- [x] workspace package + CI tooling + docs

## Contracts

- Domain repository: `SecureCoreRepository` (`encrypt` / `decrypt` / `healthCheck` / `version`)
- Bridge API: `SecureCoreNativeApi` (bytes only)
- Failures (sealed): `invalidInput`, `malformedCiphertext`, `authenticationFailed`,
  `unsupportedVersion`, `unavailable`, `internal`, `mismatch` — mapped only in data layer
- State: hand-written sealed Cubit states (no Freezed)

## Decisions

| Decision | Choice |
| --- | --- |
| Integration | `dart:ffi` + package build hooks + `native_toolchain_rust` (not `flutter_rust_bridge`) |
| Linux (1A) | Host CI/unit tests only — no product desktop claim |
| Rust (2B) | Pin **1.98.1**; local verify-or-stop; CI installs on runners |
| Web | Conditional stub → unavailable UI |
| Product native | Android, iOS, macOS |

## Paths

| Piece | Path |
| --- | --- |
| Bridge | `packages/secure_core_bridge/` |
| Rust crate | `packages/secure_core_bridge/rust/secure_core/` |
| Feature | `apps/mobile/lib/features/secure_messaging_demo/` |
| Check | `tool/check_secure_core.sh` |
| Feature guide | [`../features/secure_messaging_demo.md`](../features/secure_messaging_demo.md) |
| Architecture | [`../architecture/rust_ffi_secure_core_bridge.md`](../architecture/rust_ffi_secure_core_bridge.md) |

## Tests / proof

| Lane | Command / artifact |
| --- | --- |
| Native gate | `bash tool/check_secure_core.sh` (binding freshness + fmt/check/clippy/test + real Dart → Rust tests) |
| Bridge | `dart test packages/secure_core_bridge` |
| App unit/widget | `cd apps/mobile && flutter test test/features/secure_messaging_demo/` |
| macOS integration | `flutter test integration_test/secure_messaging_demo_flow_test.dart -d macos` |
| Builds | `flutter build macos --debug`; APK + iOS simulator when SDKs present |
| Checklist | `CHECKLIST_ALLOW_REUSE=0 ./bin/checklist` |

## Risks / residuals

- First repo use of package build hooks / `native_toolchain_rust` — fix inside package
  hook, do not embed Rust into app CMake/Xcode like `native_showcase`.
- Demo key is process-ephemeral; UI warns users.
- Hand-written sealed states remain necessary: `build_runner` currently fails
  because workspace `analyzer: 10.0.2` is incompatible with `freezed: 4.0.1`.
  Fixing that repo-wide dependency graph is outside this focused feature.
- Temporary native buffers are zeroed before free; Dart VM strings/copies and
  process-static key teardown cannot be guaranteed wiped.
- Coverage badge may shift slightly when checklist regenerates summaries.
