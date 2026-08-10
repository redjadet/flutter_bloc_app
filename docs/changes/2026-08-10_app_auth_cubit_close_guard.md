# AppAuthCubit close subscription regression

## Feature: AUTH-CUBIT-02 (auth/sync lifecycle remeasure)

### Problem

No AppAuthCubit-level regression proved that `close()` cancels both the auth
and session-invalidation subscriptions. The shared mixin tests its generic
contract, but this owner must still register both streams and delegate to
`super.close()`.

### Scope

- In: cubit unit test proving both subscriptions cancel and public calls no-op
  after close
- Out: product code

### Tests

- [x] `cancels auth and invalidation subscriptions on close`

### Proof command

```bash
(cd apps/mobile && flutter test test/app/presentation/cubit/app_auth_cubit_test.dart)
```
