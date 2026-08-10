# AppAuthCubit late-event-after-close regression

## Feature: AUTH-CUBIT-02 (auth/sync lifecycle remeasure)

### Problem

No regression proved that late `authStateChanges` or session-invalidation
events after `AppAuthCubit.close()` leave state unchanged (guards exist;
proof did not).

### Scope

- In: cubit unit test only
- Out: product code

### Tests

- [x] `ignores late auth and invalidation events after close`

### Proof command

```bash
(cd apps/mobile && flutter test test/app/presentation/cubit/app_auth_cubit_test.dart)
```
