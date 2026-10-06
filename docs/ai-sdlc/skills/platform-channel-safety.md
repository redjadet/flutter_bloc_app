---
name: platform-channel-safety
description: Apply when adding or changing MethodChannel, EventChannel, FFI, PlatformView, or host-language interop.
---

# Skill: platform-channel-safety

**Owner:** [`docs/platforms/README.md`](../../platforms/README.md),
[`native_interop.md`](../../platforms/native_interop.md),
[`reviewer_guide.md`](../../platforms/reviewer_guide.md).

Gold feature:
`apps/mobile/lib/features/native_platform_showcase/`.

## Must

1. Keep bridge types/status codes explicit; map host errors to typed app results.
2. Stub or degrade on web/desktop when the capability is mobile-only — no uncaught platform exceptions in UI.
3. Put host-only code behind data/shared adapters; presentation stays Flutter-safe.
4. Document fidelity (live vs catalog) honestly for interview surfaces.
5. Cover unsupported-platform paths in tests.

## Must not

- Call channels from `build()` without lifecycle awareness.
- Assume iOS and Android share identical host behavior without checking matrices.
- Claim `super_demo_ios` or out-of-repo hosts as in-tree proof.

## Proof

```bash
cd apps/mobile && flutter test <native-or-stub-test-paths>
./tool/analyze.sh
# When bootstrap/web smoke relevant:
./bin/integration_preflight
```
