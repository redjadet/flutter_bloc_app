# Maintainability follow-up wave — closeout

**Date:** 2026-07-10  
**Scope:** Docs + audit re-grade after follow-up PRs A–H on `main`.

## Outcome

- Program [`2026-07-10_maintainability_program.md`](../plans/2026-07-10_maintainability_program.md) marked **complete**.
- Ranks 6–7 closed; `staff_app_demo` Firestore maps stay **deferred** (separate program).
- [`senior_patterns_review_2026-06.md`](../audits/senior_patterns_review_2026-06.md) re-graded for `counter`, `chat`, `ai_decision_demo`, `scapes`.

## Soft-scan proof (post-merge `main`)

```bash
rg -n "getIt\.|GetIt\." apps/mobile/lib/features --glob '*.dart' -g '!*_test.dart'
# 0

rg -n "SecretConfig\.|FlavorManager\.|FirebaseBootstrapService\." \
  apps/mobile/lib/features --glob '**/presentation/**/*.dart'
# 0

rg -n "package:flutter_bloc_app/app/(config|bootstrap)/" \
  apps/mobile/lib/features --glob '**/presentation/**/*.dart'
# 0
```

## Landed seams (reference)

| PR | Seam |
| --- | --- |
| A | `showBackendDisabledBanner` bool |
| B | scapes `toggleFavorite` domain |
| C | `AiDecisionFailure` |
| D | sealed `ScapesState` |
| E | `ChatFailure` |
| F | chat conversation history domain |
| G | ai_decision typed Maps |
| H | sealed `CounterState` |
