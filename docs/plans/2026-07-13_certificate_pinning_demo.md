# Feature: certificate_pinning_demo

## Problem

Demonstrate production-style TLS certificate pinning (real + mock) without a
live production certificate, while keeping local/CI runs safe with pinning
**disabled by default**.

## Scope

- In: networking-layer validator abstraction, real SHA-256 leaf DER pinning,
  deterministic mock scenarios, Dio `validateCertificate` wiring, DI, developer
  demo screen (gated from prod/release), docs, unit/cubit/security tests
- Out: SPKI pinning, pinning on named Dio clients (`renderChatDio`), WebSocket
  pinning, Android `network_security_config` pinning, real prod cert material

## Layers touched

- [x] domain
- [x] data
- [x] presentation
- [x] DI
- [x] routes / l10n

## Contracts

- Repository: `SecureProbeRepository` — trigger probe, map to demo failure
- State: Freezed `initial | validating | success | failure` + mode/scenario/logs
- Config: `CertificatePinningConfig` default mode `disabled`

## Tests (executable contract — RED first)

### Behaviour (widget and/or cubit)

- [ ] Scenario: trigger probe with valid mock scenario → success state
- [ ] Scenario: invalid pin scenario → safe failure (no raw pin/cert in UI)
- [ ] Files: `apps/mobile/test/features/certificate_pinning_demo/`

### State (widget — seed cubit/state)

- [ ] Scenario: validating / success / failure render without overflow
- [ ] Files: `apps/mobile/test/features/certificate_pinning_demo/presentation/`

### Unit (domain / data)

- [ ] Scenario: primary/backup match, mismatch, unsupported host, timeout, config fail-fast, default disabled
- [ ] Files: `packages/networking/test/certificate_pinning/`

### Integration

- [ ] Omit — single-screen developer demo; no journey map row

### Proof command

- [ ] `dart test` in `packages/networking` for pinning tests
- [ ] `flutter test test/features/certificate_pinning_demo/ test/shared/http/certificate_pinning_ test/app/config/`
- [ ] `./bin/router_feature_validate`

## Docs

- [x] `docs/security/certificate_pinning.md`
- [x] `docs/features/certificate_pinning_demo.md`
- [x] `docs/changes/2026-07-13_certificate_pinning_demo.md`

## Risks

- Leaf-cert fingerprint breaks on cert renewals (mitigate with multi-pin rotation)
- Web cannot enforce Dio leaf pinning
- Default disabled means platform trust only until `CERT_PINNING_MODE=real`
