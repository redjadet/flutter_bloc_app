# Contributing

Contributions are welcome. The repo favors small, validated changes that keep
architecture boundaries, tests, and documentation aligned with behavior.

## Before opening a PR

1. Run the right validation scope for your change.
2. Add or extend tests when behavior changes.
3. Update the owning docs when setup, workflow, or feature behavior changes.
4. Keep changes inside the established `Domain -> Data -> Presentation`
   structure.

## Validation commands

| Command | When to use it |
| --- | --- |
| `./bin/checklist` | Default local quality gate before opening a PR. |
| `./bin/integration_tests` | When integration-covered flows changed or you need device-level confidence. |
| `dart run build_runner build --delete-conflicting-outputs` | When touching generated models, APIs, or annotations. |

For validator coverage and script behavior, see
[Validation Scripts](validation_scripts.md). For testing structure and suite
layout, see [Testing Overview](testing_overview.md).

## Documentation expectations

Update docs in the same change when you modify:

- Feature behavior or visible routes
- Setup or secrets requirements
- Validation or testing workflow
- Release or deployment steps
- Architecture or layering rules

Prefer updating one source-of-truth doc instead of copying the same explanation
into several files.

## Where to start

- [New Developer Guide](new_developer_guide.md)
- [Feature Overview](feature_overview.md)
- [Feature Delivery Guide](feature_implementation_guide.md)
- [Clean Architecture](clean_architecture.md)
- [Tech Stack](tech_stack.md)

## Pull request quality bar

- The diff should be understandable without hidden context.
- New abstractions should earn their keep; reuse existing shared code first.
- User-facing or cross-cutting changes should include doc updates.
- Validation should be run before requesting review.
