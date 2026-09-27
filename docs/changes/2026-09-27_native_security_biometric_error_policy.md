# Native security biometric error-policy host tests

**Date:** 2026-09-27

## Why

After #917 extracted success-downgrade reply policy, biometric prompt /
LocalAuthentication error → status/reason mapping stayed private inside the
Android/iOS security handlers and untested. Denied vs unavailable vs failed
(cancel, lockout, not enrolled, unsupported) is core HITL teaching for the
native security showcase and belongs beside the other pure host policies.

## In

- Extract `NativeSecurityShowcaseBiometricErrorPolicy` (Kotlin + Swift)
- Wire handlers to the shared mappers
- Host unit tests (Android JUnit + iOS XCTest registered in pbxproj)
- Platform doc pointers (`android.md`, `ios.md`, `native_interop.md`)

## Proof

- `./gradlew :app:testDebugUnitTest --tests NativeSecurityShowcaseBiometricErrorPolicyTest`
- `./bin/integration_preflight`
- `CHECKLIST_RUN_COVERAGE=0 ./bin/checklist`
