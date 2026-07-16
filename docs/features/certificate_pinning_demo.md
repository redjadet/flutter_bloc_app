# Certificate pinning demo

Developer-only screen that exercises mock (and optional real) certificate pin
validation without requiring production certificates.

## Entry

- Route: `/certificate-pinning-demo` (`AppRoutes.certificatePinningDemo`)
- Example hub button (`ValueKey('example-certificate-pinning-demo-button')`)
- **Redirects** to counter when `kReleaseMode || Flavor.prod`

## Stack

- Domain: `SecureProbeRepository`, use cases, safe demo failures
- Data: `SecureProbeRepositoryImpl` (local mock probe when mode disabled/mock;
  Dio probe when mode `real` + probe URL)
- Presentation: `CertificatePinningDemoCubit` /
  `CertificatePinningDemoPage`
- DI: `register_certificate_pinning_demo_services.dart`

## Behaviour

- Shows active pinning mode (default **disabled**)
- Scenario picker drives `MockCertificateScenarioController`
- Probe → validating → success / safe failure
- Developer log ring buffer from `CertificatePinningLogger`
- Real pins default to **SPKI** SHA-256 (`CERT_PINNING_HASH_KIND=spki`)

Canonical policy: [`docs/security/certificate_pinning.md`](../security/certificate_pinning.md).

## Proof

```bash
cd packages/networking && flutter test test/certificate_pinning/
cd apps/mobile && flutter test \
  test/features/certificate_pinning_demo/ \
  test/app/config/certificate_pinning_ \
  test/shared/http/certificate_pinning_
./bin/router_feature_validate
```
