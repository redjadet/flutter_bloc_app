# gstack Integration

This document is the single source of truth for gstack usage in this repository.

## Scope

- Applies to Cursor Agent, Codex extension sessions, and other SKILL.md-compatible
  AI agents used in this workspace.
- Integration is additive. Existing repo routing, validation, and completion
  rules remain authoritative.
- gstack is a workflow router, not a blanket replacement for normal coding.
- Upstream gstack treats skills as named specialists and expects agents to pick
  the right specialist for the current stage of work.

## Runtime contract (all AI agents)

Every AI agent in this workspace must follow this contract:

1. **If user explicitly requests gstack** (command/workflow name), run that exact
   gstack skill first.
2. **If request is workflow-shaped**, auto-route to the closest gstack skill.
3. **If request is narrow implementation/local edit**, stay in normal repo
   workflow and do not force gstack.
4. **If multiple gstack skills could fit**, pick the earliest valid stage in:
   `/office-hours` -> `/plan-ceo-review` -> `/plan-eng-review` -> `/review` ->
   `/qa` -> `/ship`.

## Upstream ethos applied in this repo

Use these upstream ideas to decide when gstack should auto-route:

- **Specialists by stage:** upstream gstack skills index presents gstack as a
  toolbox of named specialist workflows. Auto-route by stage, not by loose
  keyword match.
- **Search before building:** upstream gstack ethos emphasizes searching and
  understanding the landscape before inventing a solution. Prefer gstack when
  the task needs solution selection, scope shaping, or architecture judgment.
- **Boil the lake when it matters:** that same ethos argues that AI makes
  completeness cheap. Prefer gstack when a complete plan review, QA pass, or
  release workflow is more valuable than a partial shortcut.
- **Preserve the stage ladder:** when several stages are relevant, start at the
  earliest stage that still matches the user's actual request.

## Local-only install shape

- Repo path: `.agents/skills/gstack`
- Required target: `/Users/ilkersevim/gstack`
- Expected setup: `.agents/skills/gstack` is a symlink to the required target.
- Keep this integration local-only in this workspace. Do not change ignore rules
  just to surface gstack artifacts in git.

## Existing-checkout-only policy

- Use the existing local checkout at `/Users/ilkersevim/gstack`.
- Do not clone, vendor, submodule, or introduce fallback checkouts for gstack.

## Auto-route decision procedure

For every AI agent in this repo:

1. Check whether the user explicitly invoked a gstack command or named a gstack
   workflow. If yes, use that exact skill.
2. Otherwise, classify the request by stage:
   - still deciding what to build
   - reviewing scope or product direction
   - locking architecture or test plan
   - reviewing a branch or diff
   - debugging root cause
   - testing in a browser or on staging
   - shipping, deploying, or verifying production
   - cleaning up docs, doing retro, security review, or asking for a second opinion
3. If one of those stages matches cleanly, use the corresponding gstack skill.
4. If the task is primarily local implementation work, a tiny edit, or simple
   repo-native validation, stay in the normal repo workflow.
5. If the task spans several stages, choose the earliest fitting stage rather
   than skipping forward to QA, ship, or post-ship work.

| Situation | Skill | Short sample |
| --- | --- | --- |
| Idea shaping before coding | `/office-hours` | "I want to build a daily briefing app." |
| Product scope and strategy review | `/plan-ceo-review` | "Review this plan and think bigger." |
| Architecture, tests, and edge cases before coding | `/plan-eng-review` | "Lock this plan before implementation." |
| UI/UX planning or visual audit | `/plan-design-review`, `/design-review` | "Audit this screen flow." |
| Pre-landing diff or PR review | `/review` | "Review this branch before merge." |
| Root-cause debugging | `/investigate` | "Why does auth redirect loop on cold start?" |
| Browser QA and staging checks | `/qa`, `/qa-only`, `/browse` | "QA the staging site before release." |
| Release and deploy workflow | `/ship`, `/land-and-deploy`, `/canary`, `/benchmark` | "Ship this branch and verify production." |
| Post-ship docs, retro, security, second opinion | `/document-release`, `/retro`, `/cso`, `/codex` | "Update docs for what just shipped." |

## When not to auto-use gstack

- Tiny local code edits
- Single-file refactors
- Simple repo-native validation
- Quick repo-native Codex feedback on the current diff or branch-vs-base
  (`./tool/request_codex_feedback.sh`, or `/codex-feedback` in Cursor)
- Straightforward writing, rewriting, or translation tasks
- Narrow implementation work where the normal repo coding workflow is more direct
- Cases where the user already knows the exact code change and no staged
  workflow, review, or specialist judgment adds value

## Ambiguity rules

- If the request could be either planning or implementation, prefer the planning
  gstack skill only when the user is still making decisions.
- If the request is "fix this bug" with no clear workflow framing, use the normal
  repo debugging workflow first; switch to `/investigate` when root-cause
  analysis is the real task.
- If the request mixes review and QA, prefer `/review` for branch/diff-first work
  and `/qa` for browser/staging-first work.
- If more than one gstack skill could fit, choose the earliest stage in the
  workflow that still matches the user's actual ask.
- If the request mixes implementation with planning uncertainty, route to the
  planning skill first only when real decisions are still open.
- If the user wants a fast Codex second opinion on the current diff or against a
  named base branch, stay in repo-native flow and use
  `./tool/request_codex_feedback.sh` (or `/codex-feedback` in Cursor) unless
  they explicitly ask for gstack `/codex`. That helper now adds a lightweight
  stderr heartbeat in non-raw mode and skips Firebase MCP for the delegate run
  only, so Cursor does not mistake quiet Codex calls for a hang.
- Do not skip directly to `/ship` just because code is present; use `/review`
  or `/qa` first when those stages are still missing.

## Verification checklist

- `.agents/skills/gstack` resolves to `/Users/ilkersevim/gstack`.
- gstack skills are discoverable from `.agents/skills/gstack/.agents/skills`.
- Bundled gstack Codex skill path exists at
  [`.agents/skills/gstack/.agents/skills/gstack-codex/SKILL.md`](../../../../../gstack/.agents/skills/gstack-codex/SKILL.md).
- Cursor-to-Codex wrapper exists at
  `.cursor/skills/cursor-codex-delegate/scripts/delegate_to_codex.sh` (repo
  override) or `~/.cursor/skills/cursor-codex-delegate/scripts/delegate_to_codex.sh`
  (user-global install), or the local `codex` CLI is available for the repo
  helper fallback.
- Codex runtime includes corresponding `gstack-*` skills in `~/.codex/skills`.
- [`AGENTS.md`](../../AGENTS.md) points back to this document as the source of truth.

## Agent startup checks

Before first gstack auto-route in a session, confirm:

- repo symlink exists and resolves correctly
- required gstack skill exists for the selected stage
- if missing, do not guess; report blocker and continue with repo-native workflow

## Quick self-test

Run this from repo root to verify core integration quickly:

```bash
readlink .agents/skills/gstack
[ -f .agents/skills/gstack/.agents/skills/gstack-codex/SKILL.md ] && echo gstack-codex-skill-ok
{ [ -f .cursor/skills/cursor-codex-delegate/scripts/delegate_to_codex.sh ] || \
  [ -f "$HOME/.cursor/skills/cursor-codex-delegate/scripts/delegate_to_codex.sh" ] || \
  command -v codex >/dev/null; } && echo review-backend-ok
ls .agents/skills/gstack/.agents/skills | rg '^gstack-(office-hours|plan-ceo-review|plan-eng-review|review|qa|ship|codex)$'
ls ~/.codex/skills | rg '^gstack-(office-hours|plan-ceo-review|plan-eng-review|review|qa|ship|codex)$'
```

Expected output shape (example):

```text
/Users/ilkersevim/gstack
gstack-codex-skill-ok
review-backend-ok
gstack-office-hours
gstack-codex
```

## Rollback

Remove only local integration artifacts:

- `.agents/skills/gstack` symlink
- `.cursor/rules/gstack-integration.mdc`
- gstack section in [`AGENTS.md`](../../AGENTS.md)

Then re-run normal repo validation checks for docs/config-only changes.
