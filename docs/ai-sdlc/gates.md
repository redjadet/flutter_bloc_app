# Deterministic gates (hooks → existing CI)

Industry playbooks often attach **hooks** that block unsafe agent actions or
require approval. This repo maps that idea to **scripts + required CI checks** —
not vendor-specific hook JSON for Claude Code.

Agents prove “done” with the commands below. Prefer the narrowest honest lane
([`../engineering/validation_routing_fast_vs_full.md`](../engineering/validation_routing_fast_vs_full.md)).

## Local commands that prove done

| Gate | When | Command | Owner |
| --- | --- | --- | --- |
| Preflight | Non-trivial start | `./bin/agent-maintain preflight --intent "<goal>"` | Host maintenance |
| Docs gardening | Markdown / guidance changed | `bash tool/check_docs_gardening.sh` (optionally `--paths …`) | Doc rot |
| Agent knowledge map | [`AGENTS.md`](../../AGENTS.md) / agent docs | `./tool/check_agent_knowledge_base.sh` | Harness |
| Format | Any `.dart` changed | `./bin/format` or `./bin/format --changed` | Pre-complete |
| Analyze | Dart / Flutter behavior | `./tool/analyze.sh` or `flutter analyze` | Pre-complete |
| Focused tests | Behavior change | `cd apps/mobile && flutter test <paths>` | Pre-complete |
| Offline merge invariants | Sync / Hive merge | `bash tool/check_offline_first_remote_merge.sh` | Offline-first |
| Clean architecture imports | Layer moves | `bash tool/check_clean_architecture_imports.sh` | Architecture |
| Feature brief linked | New/changed feature under `lib/features/` | `bash tool/check_feature_brief_linked.sh` | Feature contract |
| AIDLC schemas | Active lifecycle run | `bash tool/check_aidlc_artifacts.sh` | AIDLC |
| Integration early | Router/bootstrap/native-adjacent | `./bin/integration_preflight` | Integration |
| Fast sweep | Docs/tooling-only or narrow | `./bin/checklist-fast` | Validation |
| Full merge gate | Broad / pre-ship | `./bin/checklist` | Validation |
| Closeout | Before claim done | `./bin/agent-maintain closeout` | Host maintenance |

Pre-complete gate owner:
[`../agent_kb/legibility_and_finish_gate.md`](../agent_kb/legibility_and_finish_gate.md#agent-pre-complete-gate-mandatory-before-done).

Command index: [`../agents_quick_reference.md`](../agents_quick_reference.md).

## Required CI checks (merge gate)

Policy owner: [`../engineering/ci_automation.md`](../engineering/ci_automation.md).
Live branch protection is source of truth; recheck before merge.

| Check context | What it runs | Agent takeaway |
| --- | --- | --- |
| `CI / build` | `./bin/checklist` (analyze, static checks, tests/coverage when code changes) | Local `./bin/checklist` (or honest docs-only `checklist-fast` + gardening) before push |
| `CI / integration-preflight` | `./bin/integration_preflight` on code-relevant PRs | Run preflight locally when touching bootstrap/router/web smoke surfaces |
| `Dependency Review / dependency-review` | Dependency review action | Do not invent lockfile churn |
| `OSV-Scanner PR Scan` / `scan-pr / osv-scan` | Lockfile vuln scan | Same |

Documentation-only PRs still report required jobs; Flutter install/coverage may
be skipped per checklist scope (`tool/checklist_scope.sh`). Keep CI green —
prefer docs-only diffs for this kit.

## Feedback into the loop

When a gate fails or a bug escapes:

1. Fix the change.
2. If the failure class is reusable, update an owner doc, skill under
   [`skills/`](skills/README.md), or add/strengthen a `tool/check_*.sh` gate
   ([`../ai/ai_failure_risks.md`](../ai/ai_failure_risks.md) Update Rule).
3. Record a lesson in [`../../tasks/lessons.md`](../../tasks/lessons.md) or
   durable prefs when verified.
4. Optionally open a new [`templates/intent.md`](templates/intent.md) for
   follow-up work.

## Explicitly not used as gates

- Claude Code / Anthropic hook JSON
- “The model said it looks fine” without a command
- Skipped required CI checks
