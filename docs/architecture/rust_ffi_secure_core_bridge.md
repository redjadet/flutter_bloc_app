# Rust FFI secure core bridge (first-of-kind)

Owner package: [`packages/secure_core_bridge/`](../../packages/secure_core_bridge/).
Consumer demo: [`secure_messaging_demo`](../features/secure_messaging_demo.md).

## Why this pattern

Prove Flutter ↔ Rust crypto without `flutter_rust_bridge`, without embedding
Rust into app `CMake`/`Xcode` (contrast `native_platform_showcase` C/C++ FFI).

## Package rules

1. **Workspace DAG leaf** — no path deps on other `packages/*`. Allowlisted in
   `tool/check_package_dependency_dag.sh` as `"secure_core_bridge": frozenset()`.
2. **Build** — `hook/build.dart` + `native_toolchain_rust`; crate path
   `rust/secure_core`.
3. **Pin** — `rust-toolchain.toml` **1.98.1**; commit `Cargo.lock`.
4. **ABI** — C header `include/secure_core.h`; Dart `@Native` bindings under
   `lib/src/ffi/`; IO vs web stub split.
5. **Ownership** — native buffer out; Dart copies then `secure_core_buffer_free`
   in `finally`. Both temporary Dart malloc input and Rust-owned output are
   zeroed before free. Dart VM strings/copies remain an explicit limitation.
6. **Failure containment** — release builds retain unwind semantics; every C
   export catches Rust panics and maps them to `INTERNAL`.
7. **Key seam** — Rust `KeyOperationsProvider` exposes `seal`/`open`, not raw
   key material. Future keystore/TPM/HSM adapters can perform non-exportable key
   operations without changing Flutter domain or presentation layers.
8. **Bounds** — plaintext and envelopes are capped before unsafe slice creation;
   envelope parsing enforces version, nonce, tag, and maximum length.
9. **Linux** — enabled for Ubuntu CI / host `dart test` only — never document as
   product desktop support.
10. **Gate** — `tool/check_secure_core.sh` checks generated bindings, Cargo
    fmt/check/clippy/test, and a real Dart → Rust host round trip. CI
    `install-rust: 'true'` on checklist + macOS integration jobs.

## Boundary

Only byte buffers, lengths, integer status values, a Boolean health result, and
the version string cross C ABI. AES keys, nonces as separate API concepts,
cipher objects, and Rust errors never cross into Flutter domain/presentation.

The current self-test exercises encrypt/decrypt readiness; it is not a formal
known-answer test or proof of platform key-store health.

## Execution model

Demo calls are synchronous FFI on Flutter isolate, bounded to 64 KiB, and kept
small for proof-of-boundary work. Do not reuse that execution model for file,
audio, video, database, or session-establishment workloads. Those require an
isolate/worker or asynchronous native API plus cancellation, backpressure, and
latency instrumentation while preserving the same domain repository contract.

## Do not

- Fall back to app-level Rust embedding when hooks fail — fix the package hook.
- Leak raw Rust strings or status codes into presentation; map in the app data layer.
- Claim production messaging / enclave security from this demo.

## Related

- Tech stack: [`../tech_stack.md`](../tech_stack.md) § Native secure core
- Integration journey: [`../engineering/integration_journey_map.md`](../engineering/integration_journey_map.md)
- Gold layout contrast: [`reference_features.md`](reference_features.md) (`native_platform_showcase`)
