# Dart 3.13 primary constructors — living docs

## Why

Language floor is Dart 3.13. Agents were still copying classic
`Foo({required this.id}); final String id;` from templates and older samples,
which duplicates fields.

## What

Living docs and copy-paste samples now use primary constructors when that
shortens the type:

```dart
class const Foo({required final String id});

class const Leaf({
  required final String title,
  super.key,
}) extends StatelessWidget;
```

Policy owner: [`docs/CODE_QUALITY.md`](../CODE_QUALITY.md). DTO policy:
[`docs/architecture/use_case_dto_policy.md`](../architecture/use_case_dto_policy.md).
Cubit scaffold: [`docs/bloc/cubit_file_template.md`](../bloc/cubit_file_template.md).

Leave generated `@freezed` types and Cubit/BLoC **state** factories alone.
Historical audits stay as written.

## Verification

- Docs-only: `./tool/check_docs_gardening.sh --paths` on touched docs
- Host skills: `./bin/agent-maintain after-host-edit` when templates change
