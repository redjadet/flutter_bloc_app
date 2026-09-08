# Rust FFI secure core bridge (first-of-kind)

Owner package: [`packages/secure_core_bridge/`](../../packages/secure_core_bridge/).
Consumer demo: [`secure_messaging_demo`](../features/secure_messaging_demo.md).

## Why this pattern

Prove Flutter ↔ Rust crypto without `flutter_rust_bridge`, without embedding
Rust into app `CMake`/`Xcode` (contrast `native_platform_showcase` C/C++ FFI).

## Why Flutter + Rust can be a strong combination

The useful split is responsibility, not a blanket claim that Dart is slow:

- **Flutter owns product experience.** One shared app layer supplies UI,
  navigation, state management, accessibility, localization, and adaptive
  behavior across the supported product targets.
- **Rust owns a narrow native core.** Ownership and borrowing provide memory
  safety guarantees without a garbage collector. Rust also supplies native
  libraries and explicit control over byte buffers, allocation, and cleanup.
- **A C ABI keeps the seam small.** Dart's supported `dart:ffi` path calls native
  C APIs directly. Rust exports that stable ABI while its internal types stay
  private and replaceable.
- **Dart build hooks package the native asset.** The SDK invokes package-local
  hooks during build/test and bundles their output. This avoids separate Rust
  wiring in every app-level Gradle, CMake, CocoaPods, or Xcode project.
- **Each side stays testable at its own boundary.** Cargo tests cover native
  rules; Dart package tests exercise the real ABI; Flutter tests cover domain,
  Cubit, and UI behavior.

Rust is not the default answer for expensive Dart work. Flutter officially
recommends helper isolates when a large computation would block the main
isolate. Choose Rust only when profiling plus native-library reuse, memory
control, cross-language reuse, or a security boundary justifies FFI and build
cost.

## Why this project uses Rust

This repository needs a reviewable, end-to-end example of Flutter calling a
real Rust core. Secure messaging supplies a concrete boundary where byte
ownership, authenticated-encryption errors, key isolation, and cleanup can be
made explicit.

Project-specific value:

1. The AES key stays behind `KeyOperationsProvider`; raw key material never
   enters Dart, domain, Cubit, or widgets.
2. One Rust implementation serves Android, iOS, and macOS instead of duplicating
   crypto behavior in Kotlin and Swift.
3. Clean Architecture ports keep Flutter business and presentation code
   independent of FFI. A future keystore, Secure Enclave, TPM, or HSM adapter can
   replace the demo provider without changing the Cubit contract.
4. A five-symbol C ABI is small enough to audit manually. Checked-in generated
   Dart bindings and `tool/check_secure_core.sh` detect interface drift.
5. A pinned Rust toolchain, committed lockfile, package build hook, and native
   round-trip tests make the integration reproducible and visible in CI.

This is architecture proof, not performance proof. No benchmark currently shows
Rust outperforming a Dart implementation in this repository. Current calls are
synchronous and intentionally capped at 64 KiB; heavier work must use a helper
isolate/worker or an asynchronous native API.

## Alternatives and selection boundary

| Option | Use when | Decision here |
| --- | --- | --- |
| Dart on main isolate | Work fits frame budget and native reuse is unnecessary | Keep normal app/domain work in Dart; not sufficient for the native-core proof |
| Dart helper isolate | CPU-heavy logic is already Dart and message-copy cost is acceptable | Preferred before adding Rust only for performance |
| Swift/Kotlin host code | Behavior is OS-specific or requires platform SDK APIs | Existing `native_platform_showcase` covers this path; duplicating crypto per host was rejected |
| `flutter_rust_bridge` | API needs rich generated types, streams, callbacks, or async Rust ergonomics | Not selected: this demo has a deliberately tiny byte-buffer/status ABI |
| Manual `dart:ffi` + C ABI | Boundary is small, stable, and benefits from explicit ownership review | Selected |
| Remote service/HSM | Secrets and policy must live outside the device | Production option, outside this offline demo |

Revisit `flutter_rust_bridge` or another generator if the native API grows
beyond a small, reviewable C surface. Its official documentation supports async
Rust, generated Dart futures, streams, rich type translation, and several
zero-copy cases, but those benefits add an abstraction and generated-code
surface this demo does not need.

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
- Move ordinary UI, routing, state management, or network orchestration into Rust.
- Claim Rust removes all memory risk; `unsafe` FFI, ABI ownership, dependencies,
  and protocol design still require review and tests.
- Claim zero-copy: Dart currently copies Rust-owned output into `Uint8List` before
  freeing the native buffer.
- Claim production messaging / enclave security from this demo.

## Research basis

The motivating [Medium article](https://medium.com/@flutter-app/why-flutter-rust-might-be-the-most-underrated-combo-in-mobile-development-d4dd61154299)
correctly highlights UI jank risk from heavy main-isolate work and Rust's
ownership-based memory safety, but its broad performance language is not project
evidence. This decision uses primary documentation and repository proof:

- [Flutter: multi-platform apps from one codebase](https://flutter.dev/)
- [Flutter: concurrency and isolates](https://docs.flutter.dev/perf/isolates)
- [Dart: build hooks and native assets](https://dart.dev/tools/hooks)
- [Dart: C interop with `dart:ffi`](https://dart.dev/interop/c-interop)
- [Rust Book: ownership](https://doc.rust-lang.org/book/ch04-00-understanding-ownership.html)
- [Rust Reference: panic behavior at FFI boundaries](https://doc.rust-lang.org/stable/reference/panic.html)
- [`flutter_rust_bridge` v2 documentation](https://cjycode.com/flutter_rust_bridge/)

## Related

- Tech stack: [`../tech_stack.md`](../tech_stack.md) § Native secure core
- Integration journey: [`../engineering/integration_journey_map.md`](../engineering/integration_journey_map.md)
- Gold layout contrast: [`reference_features.md`](reference_features.md) (`native_platform_showcase`)
