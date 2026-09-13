# Collapse graphql_demo + todo_list dual error channels toward AppError

Wave 3 error-model follow-up (P6 channel collapse).

## What landed

- `GraphqlDemoState` / `GraphqlBodyData`: drop `errorMessage` + `errorType`; keep `AppError? lastError`
- `graphql_demo_error_localizer.dart` maps `AppError` → existing graphqlSample* l10n
- `TodoListLifecycleData` carries `lastError`; UI uses `NetworkErrorMapper.getErrorMessage`
- `TodoListState.errorMessage` getter removed; `hasError` requires `lastError`

## Verification

```bash
cd apps/mobile && flutter test \
  test/features/graphql_demo/presentation/ \
  test/features/todo_list/presentation/cubit/todo_list_cubit_additional_test.dart
```
