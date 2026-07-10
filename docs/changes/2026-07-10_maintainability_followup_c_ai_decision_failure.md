# Maintainability follow-up C — ai_decision typed failure

**Date:** 2026-07-10  
**Seam:** Rank 6 / ai_decision P6

## Change

Add `AiDecisionFailure` (freezed sealed). Replace `String? errorMessage` on state with `AiDecisionFailure? failure`. Cubit maps via `NetworkErrorMapper.getErrorMessage`. Page shows `failure.displayMessage`.

## Proof

```bash
flutter test test/features/ai_decision_demo/
```
