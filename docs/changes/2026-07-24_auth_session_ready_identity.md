# Auth session-ready identity

## Summary

Gate `AuthRepository.currentUser` on the session-ready identity so router checks
cannot admit account B while account A local state is clearing. Publish a safe
initial anonymous sign-in identity immediately; account switches and pending
cleanup remain gated.

## Regression

- Symptom: the web signed-in route redirected to auth before the provider auth
  stream published.
- Cause: explicit sign-in completed before the session-ready stream emitted.
- Guard: coordinator and repository unit tests plus the web bootstrap smoke
  test.

## Verification

- Focused auth unit tests.
- Web bootstrap smoke test on Chrome.
- Static analysis and regression guards.
