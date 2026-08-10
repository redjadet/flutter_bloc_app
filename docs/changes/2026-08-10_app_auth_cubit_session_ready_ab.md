# AppAuthCubit SignOutAware A→B session-ready regression

## Feature: AUTH-CUBIT-01 (auth/sync lifecycle remeasure)

### Problem

`AppAuthCubit` unit tests mocked a raw auth stream and never proved the
production DI path (`SignOutAwareAuthRepository` + session-ready coordinator)
holds UX on account A while A→B local cleanup is in flight.

### Scope

- In: integration-style cubit test only
- Out: product code changes (existing contract already correct)

### Tests

- [x] `does not emit account B until session-ready cleanup finishes`

### Proof command

```bash
(cd apps/mobile && flutter test test/app/presentation/cubit/app_auth_cubit_test.dart)
```
