# Feature: Native Security Showcase

**Date:** 2026-07-15

Implements the full one-shot plan
[`.cursor/plans/native_security_showcase.plan.md`](../../.cursor/plans/native_security_showcase.plan.md)
(Tasks 1–7: Dart + Android/iOS native hosts + integration + gates).

## Problem

`/native-platform-showcase` explains generic Dart↔native interop but has no coverage
of platform security primitives (hardware-backed crypto, secure storage, App Check
attestation, biometric gating, TLS pin policy) — a common interview/learning gap and
a template for how to expose native security features to Dart **without leaking key
material**.

## Scope

- In: Domain enums/models/ports, `NativeSecurityChannelReplyMapper`,
  `MethodChannelNativeSecurityShowcaseService`, `FirebaseAppCheckAttestationServiceImpl`,
  `CertificatePinPolicySummaryMapper`, `NativeSecurityShowcaseCubit` + state, the
  five-card `NativeSecurityShowcaseSection` widget nested under the existing showcase
  route, DI registration, EN+TR (+ synced fallback) l10n, README update,
  unit/cubit/widget/mapper tests, Android/iOS MethodChannel handlers, integration
  scenario extension, delivery gates.
- Out (Follow-up only per plan): physical-device biometric/hardware-backed crypto
  proof, Firebase console App Check registration / enforcement changes, production
  `SecretStorage` / TLS enforcement changes.

## Layers Touched

- [x] domain (`NativeSecurityStatus`, `NativeSecurityOperation`,
  `NativeSecurityOperationResult`, `NativeSecurityShowcaseService` port,
  `AppCheckAttestationResult`, `FirebaseAppCheckAttestationService` port,
  `CertificatePinPolicySummary`, three use cases)
- [x] data (`NativeSecurityChannelReplyMapper`,
  `MethodChannelNativeSecurityShowcaseService`, `FirebaseAppCheckAttestationServiceImpl`,
  `CertificatePinPolicySummaryMapper`)
- [x] presentation (`NativeSecurityShowcaseCubit` + `NativeSecurityShowcaseState`,
  section + card widgets)
- [x] DI (`registerNativePlatformShowcaseServices` — security ports/use cases appended)
- [x] routes (`createNativePlatformShowcaseRoute` → `MultiBlocProvider` nesting
  `NativeSecurityShowcaseCubit` alongside the parent showcase cubit; **no new route**)
- [x] l10n (`app_en.arb` / `app_tr.arb` + fallback keys in other ARBs)
- [x] native Android (`MainActivity` → `FlutterFragmentActivity`,
  `NativeSecurityShowcaseHandler.kt`, `androidx.biometric:biometric:1.1.0`)
- [x] native iOS (`NativeSecurityShowcaseHandler.swift`, `AppDelegate` registration,
  Face ID usage string, Xcode project entry)
- [x] integration (`flow_scenarios_secondary.dart` five-card + non-secret scan;
  web bootstrap smoke scrolls to security section)

## Architecture

```text
NativeSecurityShowcaseCubit
        ↓ RunNativeSecurityOperationUseCase   ↓ ProbeAppCheckAttestationUseCase
        ↓ LoadCertificatePinPolicySummaryUseCase
NativeSecurityShowcaseService (port)   FirebaseAppCheckAttestationService (port)
        ↓                                       ↓
MethodChannelNativeSecurityShowcaseService   FirebaseAppCheckAttestationServiceImpl
        ↓                                       ↓
MethodChannel `native_security_showcase`     FirebaseAppCheck.instance.getToken(false)
        ↓
Android Keystore / iOS Secure Enclave + Keychain + LocalAuthentication

CertificatePinPolicySummaryMapper.fromConfig(CertificatePinningConfig) → CertificatePinPolicySummary
```

`LoadCertificatePinPolicySummaryUseCase` depends on a `CertificatePinPolicySummaryBuilder`
typedef (a plain function), not the concrete mapper. The composition root injects
`CertificatePinPolicySummaryMapper.fromConfig`; the use case accepts the pure-Dart
`CertificatePinningConfig` model.

| Concern | Owner |
| --- | --- |
| Route + cubit nesting | `apps/mobile/lib/app/router/routes_demos.part.dart` |
| DI | `apps/mobile/lib/app/composition/features/register_native_platform_showcase_services.dart` |
| Section UI | `presentation/widgets/native_security_*.dart` |
| Android host | `NativeSecurityShowcaseHandler.kt` |
| iOS host | `NativeSecurityShowcaseHandler.swift` |

Canonical detail: [`apps/mobile/lib/features/native_platform_showcase/README.md`](../../apps/mobile/lib/features/native_platform_showcase/README.md#native-security-showcase-nested-no-new-route).

## Contracts

- Channel: `com.example.flutter_bloc_app/native_security_showcase` — methods
  `p256SignVerify`, `aesGcmRoundTrip`, `secureStorageLifecycle`,
  `biometricProtectedOperation`; replies are `Map` with `schemaVersion: 1` only.
- Client timeouts: **2s** crypto/storage; **60s** biometric (user-mediated prompt).
- Statuses: `success | unavailable | denied | failed`. Off Android/iOS the adapter
  short-circuits to `unavailable`/`mobile_only` before invoking the channel.
- Malformed/wrong-version/unknown-status replies map to `failed`/`malformed_reply`;
  only allowlisted keys are copied into `NativeSecurityOperationResult`.
- App Check: `getToken(false)` only; token discarded; never `forceRefresh: true`.
- Certificate card: counts/mode only; open mutable demo when
  `!kReleaseMode && !FlavorManager.I.isProd`.
- Biometric: Android `BIOMETRIC_STRONG` / crypto-object; iOS `.biometryCurrentSet`;
  no device-credential fallback.
- ValueKeys: section `native-security-showcase-section`; cards
  `native-security-card-{crypto,certificate,storage,app-check,biometric}`; buttons
  `native-security-run-{crypto,aes,storage,app-check,biometric}`,
  `native-security-open-certificate-demo`.

## Tests

### Behaviour

- [x] Channel reply mapper allowlist + schemaVersion reject
- [x] Mapper rejects unknown reasonCode; coerces/strips unknown platform/algorithm;
  never echoes secret-looking wire strings into Dart state
- [x] Mapper + native hosts downgrade success when `verified` /
  `wrote`/`readMatched`/`deleted` fail
- [x] MethodChannel adapter mobile-only / missing_plugin / timeout / PlatformException
- [x] Unrecognized `PlatformException.code` → locked `platform_error` (never raw)
- [x] UI reason labels never fall back to raw channel text
- [x] Biometric uses longer client timeout (60s); crypto/storage remain 2s
- [x] App Check token discard + status mapping
- [x] Shared `isBusy` gate across crypto/storage/biometric/App Check
- [x] Certificate pin summary counts (no raw pins or inferred rotation roles)
- [x] Cubit concurrency + per-card result isolation + no emit after close
- [x] Section widget five cards + non-secret UI
- [x] Page test provides nested security cubit
- [x] Integration secondary flow: five cards, crypto/AES/storage taps, secret-looking
  regex refuse
- [x] Web bootstrap smoke scrolls to security section before interop asserts

### Files

- `test/features/native_platform_showcase/data/native_security_channel_reply_mapper_test.dart`
- `test/features/native_platform_showcase/data/method_channel_native_security_showcase_service_test.dart`
- `test/features/native_platform_showcase/data/firebase_app_check_attestation_service_impl_test.dart`
- `test/features/native_platform_showcase/data/certificate_pin_policy_summary_mapper_test.dart`
- `test/features/native_platform_showcase/presentation/cubit/native_security_showcase_cubit_test.dart`
- `test/features/native_platform_showcase/presentation/widgets/native_security_showcase_section_test.dart`
- `test/features/native_platform_showcase/presentation/pages/native_platform_showcase_page_test.dart` (updated)
- `integration_test/flow_scenarios_secondary.dart` (extended)
- `test/integration_preflight/web_bootstrap_smoke_test.dart` (updated)

## Validation

```bash
cd apps/mobile && flutter test test/features/native_platform_showcase/
bash tool/check_clean_architecture_imports.sh
bash tool/check_feature_folder_contract.sh
bash tool/check_feature_modularity_leaks.sh
./tool/analyze.sh
./bin/router_feature_validate
./bin/checklist --no-reuse
CHECKLIST_INTEGRATION_DEVICE=<iphone-sim-udid> ./bin/integration_tests
flutter build apk --debug
flutter build ios --simulator --debug
```

Current validation status (2026-07-16):

- `git diff --check` passes.
- Focused Flutter tests need rerun after review fixes. The environment currently
  prevents Flutter from updating its SDK cache and later reported no free temporary
  disk space, so no green test/build count is claimed here.
- Native APK/iOS simulator builds and device integration proof remain pending.

## Known limitations / Follow-up

- Physical Android/iPhone biometric + hardware-backed crypto success proof —
  Follow-up only (simulator/emulator may return `unavailable` / software keystore).
- Firebase console App Check provider registration — Follow-up only; absent Firebase
  setup, null tokens, and native App Check wrapper setup errors map to
  `unavailable`/`not_configured_or_token_null` without exposing token/error text.
- No App Check enforcement, no Android network-security XML pinning, no production
  `SecretStorage` changes (locked out of scope).

## Links

- README: [`apps/mobile/lib/features/native_platform_showcase/README.md`](../../apps/mobile/lib/features/native_platform_showcase/README.md)
- Plan: [`.cursor/plans/native_security_showcase.plan.md`](../../.cursor/plans/native_security_showcase.plan.md) (gitignored host plan; not part of commit)
- Related feature brief: [`docs/changes/2026-06-08_native_platform_showcase_feature_brief.md`](2026-06-08_native_platform_showcase_feature_brief.md)
- Journey **J6**: [`docs/engineering/integration_journey_map.md`](../engineering/integration_journey_map.md)
