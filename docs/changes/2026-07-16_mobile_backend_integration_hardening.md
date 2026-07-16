# Change note — Mobile–Backend Integration Hardening (2026-07-16)

## Why

Malformed API payloads leaked raw `TypeError` from AI Decision / GraphQL DTOs, and three data constructors could silently create ad-hoc `Dio()` clients that bypass shared auth/retry/pinning. Contract guidance was fragmented across owner docs.

## What

- Defensive JSON readers + `FormatException` for AI Decision and GraphQL country DTOs; GraphQL data failures map to `GraphqlDemoErrorType.data`.
- Required injected `Dio` on `RestCounterRepository`, `CountriesGraphqlRepository`, `HuggingFaceApiClient`.
- CI guard `tool/check_adhoc_dio_construction.sh` wired into `./bin/checklist`.
- Canonical docs: `docs/backend/API_CONTRACT_GUIDE.md`, `docs/architecture/MOBILE_BACKEND_BOUNDARIES.md`, `docs/contributing/PR_REVIEW_CHECKLIST.md` (+ hub links).
- Baseline/final audits under `docs/audits/`.

## Proof

- Audits: [`mobile_backend_integration_hardening_baseline_2026-07-16.md`](../audits/mobile_backend_integration_hardening_baseline_2026-07-16.md), [`mobile_backend_integration_hardening_final_2026-07-16.md`](../audits/mobile_backend_integration_hardening_final_2026-07-16.md)
- Focused tests: AI Decision + GraphQL data suites, Dio injection call sites, shared HTTP regressions (127 passed)
- Guards: `check_adhoc_dio_construction.sh`, Clean Architecture imports, analyze
- Delivery: `./bin/checklist` (Task 8)

## Out of scope

Pagination implementation, product analytics events, live backend validation, broad demo DTO rewrite.
