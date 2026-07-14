# Repomix profiles

Curated, token-bounded context packs for cold-start agents. Outputs are
gitignored under `.repomix/`.

## Commands

```bash
bash tool/repomix_pack.sh onboarding
bash tool/repomix_pack.sh feature --feature counter
bash tool/check_repomix_contract.sh
```

Uses `npx --yes repomix@1.16.1` (no root npm dependency). Bump the pin in its
own PR when upgrading Repomix.

## Profiles

| Profile | Config | Budget (D3) | Includes |
| --- | --- | --- | --- |
| onboarding | `tool/repomix/onboarding.config.json` | ≤120k tokens | Maps, pubspecs, app shell, package barrels, feature catalog |
| feature | `tool/repomix/feature.config.json` + `--feature` | ≤60k tokens | One feature tree, tests, router, composition |

## Exclusions

`.repomixignore`, gitignore, and Repomix default patterns exclude:

- `.env*`, secrets
- `*.freezed.dart`, `*.g.dart`, `*.gr.dart`
- `.dart_tool/`, `build/`, coverage
- historical `ai/reports/FINAL_OPTIMIZATION_REPORT.md`

## Agent notes

- Pack **paths**, not the whole repo, by default.
- Pair with [`llms.txt`](../../llms.txt) via `instructionFilePath`.
- Treat output as read-only evidence; behavior canon stays in `docs/`.
