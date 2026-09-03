# 2026-09-02 — Full-app hardening W1 reliability wave

## Why

Several demo cubits still surfaced raw `error.toString()`, dropped stream errors,
or let stale async work win after navigation. W1 closes those reliability gaps
before broader perf and mapper sweeps.

## Change

- Harden Theme/Locale, IAP, Staff proof, IoT BLE, WebSocket, Scapes, and
  Realtime Market cubits (see audit table).
- Map stream/command failures through `NetworkErrorMapper` where applicable.
- Split `InAppPurchaseDemoCubit` stream lifecycle into a part file to satisfy
  `file_length_lint` (max 225 physical lines).
- Invalidate prior IAP purchase-stream generations before a repository switch
  or cubit close, so stale entitlement refreshes cannot update current state.
- Fix `awaitScrollTarget` perf helper to honor a shared timeout budget across
  scroll candidates.

## Proof

- Audit: docs/audits/2026-09-02_full_app_hardening_w1 (local audit, gitignored)
- `./bin/checklist`
- `CHECKLIST_INTEGRATION_DEVICE=<simulator> ./bin/integration_tests`
- Focused cubit tests listed in the audit verification block
