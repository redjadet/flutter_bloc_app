# AI-native SDLC kit (tool-agnostic)

Translate industry **AI-native / agentic SDLC** ideas into artifacts this repo
already runs with coding agents. **No vendor-locked agent config.**

Primary hosts: coding agents that read [`AGENTS.md`](../../AGENTS.md) and repo skills (this
portfolio validates those hosts in [`../agent_host_notes.md`](../agent_host_notes.md)).
Machine-checked lifecycle remains [`../ai/aidlc_workflow.md`](../ai/aidlc_workflow.md).

## Artifact loop

```text
intent.md  →  spec.md  →  plan.md  →  code + tests  →  REVIEW.md  →  PR / CI
     ↑                                                              |
     └──────── feedback (lessons, gates, incident → new intent) ────┘
```

| Stage | Commit | Next stage starts by |
| --- | --- | --- |
| Plan | [`templates/intent.md`](templates/intent.md) | Human accepts intent |
| Design | [`templates/spec.md`](templates/spec.md) | Approved intent + institutional skills |
| Build prep | [`templates/plan.md`](templates/plan.md) | Approved spec |
| Build / test | Diff + focused `flutter test` | Plan write-set |
| Review | [`templates/REVIEW.md`](templates/REVIEW.md) | Diff ready for PR |
| Ship proof | CI required checks | See [`gates.md`](gates.md) |

Live feature folders: [`features/README.md`](features/README.md).  
Institutional skills: [`skills/README.md`](skills/README.md).  
Deterministic gates (hooks → CI): [`gates.md`](gates.md).

## Concept map (industry → this repo)

| Industry idea | Repo artifact | Notes |
| --- | --- | --- |
| Agent instruction file (vendor CLAUDE-style) | Root [`AGENTS.md`](../../AGENTS.md) | ≤50 lines; tool-agnostic; no vendor host sections |
| Always-on thin rules | Host templates under `tool/agent_host_templates/` + synced project rules | Edit templates, then `./bin/agent-maintain after-host-edit` |
| Intent → spec → plan → review | This kit’s templates + live `features/<slug>/` | Complements AIDLC; does not replace schemas |
| Brownfield lifecycle gates | [`../ai/aidlc_workflow.md`](../ai/aidlc_workflow.md) + [`../engineering/aidlc_artifact_contract.md`](../engineering/aidlc_artifact_contract.md) | `approve` / `continue` still control T1/T2 |
| Feature brief / tests contract | [`../engineering/FEATURE_TEMPLATE.md`](../engineering/FEATURE_TEMPLATE.md) | Spec should cite or embed Tests rows |
| Institutional skills | [`skills/`](skills/README.md) (docs) + shared host skills | Policy in owner docs; skills point agents there |
| Deterministic hooks | Scripts + GitHub Actions — [`gates.md`](gates.md) | Not vendor hook JSON |
| Agentic PR review | [`../ai_code_review_protocol.md`](../ai_code_review_protocol.md) + human review | Cross-host review only when user asks |
| Feedback loop | [`../../tasks/lessons.md`](../../tasks/lessons.md), [`../agent_kb/operator_preferences_durable.md`](../agent_kb/operator_preferences_durable.md), [`../ai/ai_failure_risks.md`](../ai/ai_failure_risks.md), [`../changes/`](../changes/README.md) | Bugs become durable gates/docs |

## Depth chooser

| Depth | When | Artifacts |
| --- | --- | --- |
| T0 | Trivial one-liner (≥95%) | None |
| Lite | Local non-trivial | Fill intent (short) + plan in tracker; skip full folder |
| Full feature | Offline sync, channels, new Cubit surface, cross-feature | `docs/ai-sdlc/features/<slug>/` intent→spec→plan→REVIEW **and** AIDLC when T1/T2 |

## Claude / Anthropic-only items skipped

Hard ban for this portfolio (do **not** add):

- Vendor CLAUDE instruction file at repo root, `.claude/`, Claude Code project settings
- Anthropic-only GitHub Actions, review bots, or API-keyed PR reviewers
- Claude Code hooks JSON / slash-command plugin packs as the gate system
- Skills or prompts that require an Anthropic API key to run

Use this kit + existing CI instead.

## Related owners

- Entry: [`AGENTS.md`](../../AGENTS.md)
- AIDLC: [`../ai/aidlc_workflow.md`](../ai/aidlc_workflow.md)
- Validation: [`../agents_quick_reference.md`](../agents_quick_reference.md)
- HITL map: [`../ai/human_ai_collaboration.md`](../ai/human_ai_collaboration.md)
- Interview narrative: [`../interview_showcase.md`](../interview_showcase.md) (pillar 4)
