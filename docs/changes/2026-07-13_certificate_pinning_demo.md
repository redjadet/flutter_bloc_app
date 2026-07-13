# Certificate pinning demo infrastructure

## Why

Need a production-style certificate pinning architecture (real + mock) that
runs in local/CI without live production certificates, stays **disabled by
default**, and is easy to enable with real SHA-256 pins later.

## What changed

- `packages/networking`: pinning config, sealed failures, Real/Mock validators,
  Dio `validateCertificate` apply helper (IO only; web stub).
- Default pin material is **SPKI** (`CertificatePinHashKind.spki`); leaf DER
  remains via `CERT_PINNING_HASH_KIND=leaf`.
- App DI: `CertificatePinningConfig.fromBootstrap()` (default `disabled`),
  wire into main `Dio` via `register_http_services`.
- Feature `certificate_pinning_demo`: developer screen for mode/scenario/probe
  (gated from prod/release).
- l10n: certificate pinning demo keys in `app_en.arb` + synced placeholders in
  `app_{de,es,fr,tr,ar}.arb`.
- Docs: `docs/security/certificate_pinning.md`, feature doc, checklist links.
- Tests: SPKI fixture matrix, config fail-fast, cubit, retry/security regressions.

## Proof

```bash
# from repo root
/Users/ilkersevim/Flutter_SDK/flutter/bin/flutter test \
  packages/networking/test/certificate_pinning/
cd apps/mobile && flutter gen-l10n && flutter test \
  test/features/certificate_pinning_demo/ \
  test/shared/http/certificate_pinning_ \
  test/app/config/certificate_pinning_
./tool/analyze.sh
./bin/router_feature_validate
```
