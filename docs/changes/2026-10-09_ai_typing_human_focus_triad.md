# AI typing vs human focus triad (architecture, intent, edge cases)

**Date:** 2026-10-09  
**Scope:** Documentation only. No product or harness behavior change.

## Summary

Make “AI handles typing/syntax; humans focus on architecture, intent, and edge
cases” actionable in the existing human skills guide and AI-SDLC templates.
Humans retain understanding, acceptance, and risk ownership; agents contribute
design options, counterexamples, implementation, and verification. Expected
results come from accepted requirements/contracts rather than generated code.
Existing lifecycle, safety, and validation policies remain authoritative.

## What changed

| Doc | Change |
| --- | --- |
| [`engineering/critical_human_skills.md`](../engineering/critical_human_skills.md) | Human decisions vs agent contributions, independent expected results, request card, and offline-sync worked example |
| [`ai/human_ai_collaboration.md`](../ai/human_ai_collaboration.md) | First-path pointer targets the triad; ownership table covers edge-case behavior and acceptance |
| [`ai-sdlc/README.md`](../ai-sdlc/README.md) | Connect intent/spec/plan/review to human decisions and agent execution |
| [`intent.md`](../ai-sdlc/templates/intent.md) | Protected invariant, non-goals, source of expectations, and owned open questions |
| [`spec.md`](../ai-sdlc/templates/spec.md) | State/side-effect ownership; repeated, stale, interrupted, and recovery cases; case-to-proof mapping |
| [`REVIEW.md`](../ai-sdlc/templates/REVIEW.md) | Review contract-derived expectations and record human decisions, untested cases, and residual risk |
| [`changes/README.md`](README.md) | Index summary describes the practical ownership and template changes |
| [`engineering/README.md`](../engineering/README.md), [`docs/README.md`](../README.md) | Catalog blurbs mention the triad |

## Validation

Docs gardening checks Markdown file references and toolchain mentions;
knowledge-base checks verify owner contracts. Check edited local links and
heading anchors separately. Use the documentation lane in
[`validation routing`](../engineering/validation_routing_fast_vs_full.md) for
fresh checklist and agent closeout proof. Dart format/analyze and Flutter tests
are N/A for this documentation-only change; the worked example is not runtime
test evidence.

Local verification on 2026-10-09, against the working diff at base `a3894d11`:

| Check | Result |
| --- | --- |
| Scoped docs gardening (run by closeout) | Pass |
| `AGENT_MEMORY_AUTO_MAINTAIN=0 bash tool/check_agent_knowledge_base.sh` | Pass |
| `bash tool/check_ai_snapshot_freshness.sh --strict-head` | Pass |
| `bash tool/check_engineering_quality_scorecard_gate.sh --skip-coverage-proof` | Pass; documentation wiring only |
| `./bin/agent-maintain closeout` | Pass; reports existing managed-host asset drift |
| Local Markdown links/anchors in the eight edited documents | Pass; 424 checked |
| `git diff --check` | Pass |
| `./bin/checklist-fast --no-reuse` | Failed at the runtime-error self-test: cached Dart MCP executable missing |

The local Dart MCP installation references
`dart_mcp_server/hosted/1.2.0/bundle/bin/dart_mcp_server`, which is absent.
Restore that host tool before repeating the fast checklist. The scoped checks
above do not establish a complete checklist pass.

These refinements are carried into the combined README/documentation delivery;
see its [task tracker](../../tasks/codex/readme-human-ai-docs/todo.md) for fresh
validation and pull-request evidence.

## Out of scope

- No new index, parallel rule book, lifecycle gate, or host configuration
- No product or harness behavior changes
- No claim that humans stop reading code or that AI only types
