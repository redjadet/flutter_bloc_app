# Dio + Retrofit — current contract

**Status:** Chart, Counter, GraphQL Retrofit pilots **done**. Hugging Face
optional / keep as-is unless product asks.

## Rules

- Single app `Dio` via `createAppDio()` + interceptors.
- Retrofit clients registered in **feature DI**, not presentation.
- Domain interfaces unchanged; repositories own parsing / error mapping.
- Shared Dio uses `validateStatus: (_) => true` so status-based mapping stays
  in repositories.
- Keep `NetworkGuard` for manual Dio flows; do not force all Retrofit through
  it.

## Owners

- [`tech_stack.md`](../tech_stack.md)
- [`reliability_error_handling_performance.md`](../reliability_error_handling_performance.md)
- [`architecture_details.md`](../architecture_details.md)
