# Human–AI collaboration map

**Audience:** Visitors, new developers, and reviewers who need human-in-the-loop
(HITL) ownership without reading the entire agent harness.  
**Date:** 2026-09-25  
**Pillars:** README [Four pillars](../../README.md#four-pillars).

This is an **index**, not a parallel rule book. Prefer the linked owners.

## First path (≤5 minutes)

1. [`AGENTS.md`](../../AGENTS.md) — project entry map  
2. This page — decision ownership  
3. [`../agent_kb/agent_safety_contracts.md`](../agent_kb/agent_safety_contracts.md) — safety contracts  
4. [`aidlc_workflow.md`](aidlc_workflow.md) — approve / continue  
5. [`../agent_kb/legibility_and_finish_gate.md`](../agent_kb/legibility_and_finish_gate.md) — proof + closeout  
6. [`../engineering/critical_human_skills.md`](../engineering/critical_human_skills.md) — request card + work loop  
7. [`sanitized_aidlc_safety_report_sample.md`](sanitized_aidlc_safety_report_sample.md) — sample closeout report shape (fiction)  

Memory (≤2 clicks from README via this map):

- [`../../tasks/lessons.md`](../../tasks/lessons.md)  
- [`../agent_kb/operator_preferences_durable.md`](../agent_kb/operator_preferences_durable.md)  

## Decision type → owner → agent may / must-not → proof

| Decision type | Human owner | Agent may | Agent must not alone | Proof artifact |
| --- | --- | --- | --- | --- |
| Product scope / non-goals | Human | Propose options | Expand Archive without an approved swap; invent out-of-scope paths | ADR / change note / [`authority_scope_register.md`](../authority_scope_register.md) |
| Architecture fork (Riverpod, new sync engine, …) | Human | Spike notes inside write-set | Merge irreversible architecture | ADR + review |
| Feature implementation (reversible) | Human approves intent | Implement inside agreed write-set | Broaden scope silently | Focused tests + finish gate |
| Secrets / provider keys | Human | Point at docs | Put keys in Flutter artifacts / commit | [`security_and_secrets.md`](../security_and_secrets.md) |
| Release / store publish / production deploy | Human | Prepare dry-run evidence | Ship or rotate production secrets | Deployment + dry-run workflow |
| Production auth / IAM design | Human | Document options | Ship role/claims without spike | [Spike note](../changes/2026-09-24_role_claims_iam_defer.md) / ADR |
| Destructive / external side effects | Human same-turn approval | List targets + rollback (SAFETY-02) | Run unapproved | Session log / SAFETY-REPORT |
| Git push / PR when policy requires human | Human | Draft locally | Push/PR against policy | Branch + PR template |
| Validation lane choice | Shared | Run narrowest lane | Claim full green without commands | Checklist / scorecard output |
| Pattern Yellow → Green | Human prioritizes | Document intentional Yellow; fix when tasked | Claim all-Green gold path falsely | [`senior_patterns_review_2026-06.md`](../audits/senior_patterns_review_2026-06.md) |

## Security / human-only invariants

| Invariant | Human-only? | Notes |
| --- | --- | --- |
| Release / store publishing | Yes | Dry-run ≠ publish |
| Production deploy / Render dual-target decisions | Yes | Follow Render chat ops ([`render_chat_ops.md`](../integrations/render_chat_ops.md)); human approves prod secrets/deploys |
| Secret rotation & provider API keys | Yes | Never in client artifacts |
| Architecture forks with high blast radius | Yes | ADR required |
| Production auth / role-claims IAM | Yes | Defer — [spike note](../changes/2026-09-24_role_claims_iam_defer.md) |
| Accepting residual security risk | Yes | SAFETY contracts |

## Composition / DI rule (restated)

- Register and resolve at the **composition root** (`apps/mobile/lib/app/composition/`).
- Router / route factories receive injected deps — **do not call `getIt` inside router files or feature presentation pages**.
- See [`../new_developer_guide.md`](../new_developer_guide.md) and root [`CONTRACTS.md`](../../CONTRACTS.md).

## Related owners

| Doc | Role |
| --- | --- |
| [`best_areas_for_ai_agents.md`](best_areas_for_ai_agents.md) | Task-fit boundaries |
| [`../ai_code_review_protocol.md`](../ai_code_review_protocol.md) | Automated-change review |
| [`../review/code_review_playbook.md`](../review/code_review_playbook.md) | Human review |
| [`harness_scorecard.md`](harness_scorecard.md) | Agent harness scorecard (≠ Engineering) |
| [`../engineering/engineering_quality_scorecard.md`](../engineering/engineering_quality_scorecard.md) | App/portfolio engineering scorecard |

---

**Footnote — claim evidence:** dated ledger
[`../changes/2026-09-24_authority_phase_0_evidence_baseline.md`](../changes/2026-09-24_authority_phase_0_evidence_baseline.md)
(last SHA refresh: [`../changes/2026-09-25_claim_ledger_sha_refresh.md`](../changes/2026-09-25_claim_ledger_sha_refresh.md)).
