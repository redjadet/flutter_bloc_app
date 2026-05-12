# dependency_validator — feasibility (2026-05-12)

## Spike

- `flutter pub add --dev dependency_validator` (5.0.5)
- `dart run dependency_validator` → **exit 1** with broad findings

## Blockers to CI adoption

1. **Used outside `lib/` but not dev_dependencies** — flags `analyzer`, `build`, `mockito`, `test`, `yaml`, Firebase platform packages, etc. Fixing would require large pubspec churn and may fight Flutter’s recommended dependency layout.
2. **“May be unused” false positives** — e.g. `cupertino_icons` (assets), `json_annotation` (annotations + codegen), `firebase_analytics` (side-effect registration). Needs a long ignore list.
3. **Direct pin noise** — reports `freezed` pin as informational; acceptable for this repo.

## Decision

**Defer** wiring `dependency_validator` into `./bin/checklist`. Revisit if pubspec is split (e.g. melos packages) or if a narrow custom script is preferred (e.g. only “unused dependencies” with an explicit allowlist).

## Manual command (optional)

After re-adding the dev dependency locally:

```bash
dart run dependency_validator
```

Do not fail CI on this output until ignores are curated and stable.
