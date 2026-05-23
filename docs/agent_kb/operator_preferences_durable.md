# Operator Preferences (Durable)

Durable operator choices. Keep simple; link to owner; avoid duplicate prose.

## Agent Docs

- Keep root [`AGENTS.md`](../../AGENTS.md) a lean map: links only in `## Map`. Put behavior here or owning `docs/`. Never add long prose or `## Learned User Preferences` / `## Learned Workspace Facts`.
- Agent docs/templates: reduce context/token load only when signal exists and mechanical-check anchors survive. Classify edits via `docs/audits/dedup_matrix_*.md` (canonical / echo / stale).
- **Automatic memory upkeep (safe):** [`tool/agent_memory_auto_maintain.sh`](../../tool/agent_memory_auto_maintain.sh) — local `--if-changed` link normalize on agent-scope markdown (via [`check_agent_knowledge_base.sh`](../../tool/check_agent_knowledge_base.sh)); `--verify` after [`sync_agent_assets.sh`](../../tool/sync_agent_assets.sh) `--apply`; optional report-only `--codex-memory-health` / `AGENT_MEMORY_CODEX_HEALTH=1`. No compress/trim/host-memory mutation. Opt-out: `AGENT_MEMORY_AUTO_MAINTAIN=0`.
- Keep numbered **context ladder** only in [`docs/ai/context_loading.md`](../ai/context_loading.md). Keep validation choices in [`docs/agents_quick_reference.md`](../agents_quick_reference.md) § Validation Chooser.
- Optional compression: [`tool/agent_host_templates/cursor/skills/caveman-compress/SKILL.md`](../../tool/agent_host_templates/cursor/skills/caveman-compress/SKILL.md). Use only on proven redundant targets; preserve exact commands, paths, URLs, and guarded literals.
- Meaningful workflow/policy shift: update source docs first, then host templates only when cold-start behavior changes.
- Caveman terse mode: always-on via [`.cursor/rules/caveman.mdc`](../../.cursor/rules/caveman.mdc); user may disable with "stop caveman" / "normal mode".

## README

Keep root [`README.md`](../../README.md) a professional entrypoint: short pitch, grouped repo-backed badges, quick start, one doc table. Put **Scope** before **Screenshots**; screenshots last. Route detail to [`docs/README.md`](../README.md) and topic docs. No ADR tables, command essays, or duplicate deep dives in README body.

## Validation

- Fix failures in product code/DI/config first; do not "pass" checks by weakening scripts or validators. Change scripts only for demonstrated false positives.
- Treat analyzer warnings/info and lints as code fixes first: structure, l10n, mounted guards. Avoid broad ignore comments when proper fix fits.
- After `lib/` or mixed `lib/` + `docs/` delivery, run [`./bin/checklist`](../../bin/checklist) until green. [`./bin/checklist-fast`](../../bin/checklist-fast) is docs/tooling-only; see [`engineering/validation_routing_fast_vs_full.md`](../engineering/validation_routing_fast_vs_full.md).
- README or substantive `docs/**` edits: run `markdownlint-cli2` on touched paths until clean; see [`docs/agents_appendix.md`](../agents_appendix.md).
- Pre-commit review: on client-facing Dart delivery, run final diff review (`review-changes-improve`, `pre-delivery-flutter-review`) and close findings before commit/PR.

## Host Setup

- Machine-wide Cursor rules/commands/skills: `bash tool/setup_cursor_agent_environment.sh --apply` plus optional `--install`.
- Host drift: use `./tool/sync_agent_assets.sh --dry-run`, `./tool/sync_agent_assets.sh --apply`, dry-run clean, then `./tool/check_agent_asset_drift.sh`; no piecemeal `~/.cursor/` edits. Do not copy repo-managed skill names into workspace `.cursor/skills/` — `check_workspace_managed_skill_duplicates` fails drift when names overlap synced host skills.
- Global skill trim defaults to `--trim-mode balanced`; `--trim-mode full` archives more vendor trees under `~/.agents/skills/.archived/<timestamp>/` and is reversible. Use `full` only when operator explicitly asks.

## Durable Prefs

- **Integration tests / simulators:** Prefer resolving the latest available iPhone Simulator runtime when repo scripts support it; avoid hard-coding a single OS version when a dynamic choice exists. On a clean iOS tree with Firebase SPM, run `cd ios && xcodebuild -resolvePackageDependencies -workspace Runner.xcworkspace -scheme Runner` before `./bin/integration_tests` when Crashlytics upload scripts fail for missing checkouts.
- **Upgrade lane proof:** After `./bin/upgrade_validate_all` or `/upgrade-pr-triage-validate`, cite explicit pass evidence for delivery checklist (step 3) and integration tests (step 4)—test counts and simulator id—not only overall exit 0.
- **`/commit-push-pr`:** [`changes/2026-05-21_agent_automated_delivery_loop.md`](../changes/2026-05-21_agent_automated_delivery_loop.md) (omit checklist coverage/README churn unless shipping coverage).
- **Feature-brief:** `lib/features/**` diff → `bash tool/check_feature_brief_linked.sh` or `SKIP_FEATURE_BRIEF=1`.
- **Tests as feature definition:** For non-trivial `lib/features/**` work, tests are the executable done contract—not post-implementation cleanup. Fill [`plans/FEATURE_TEMPLATE.md`](../plans/FEATURE_TEMPLATE.md) **Tests** before broad implementation; add RED/unit/widget tests in the **same change series** as feature code. Widget patterns: [`testing/widget_test_playbook.md`](../testing/widget_test_playbook.md). Policy: [`changes/2026-05-22_tests-as-feature-definition.md`](../changes/2026-05-22_tests-as-feature-definition.md).
- **Firebase local config:** Keep committed [`lib/firebase_options.dart`](../../lib/firebase_options.dart) placeholder-only; put real `FIREBASE_*` in gitignored `.envrc` after `flutterfire configure` (restore placeholder per [`firebase_setup.md`](../firebase_setup.md) step 3b). Secret scanning / history scrub: [`security_and_secrets.md`](../security_and_secrets.md), [`tool/firebase_secret_history_replacements.txt`](../../tool/firebase_secret_history_replacements.txt).
- **Continual learning:** index `.cursor/hooks/state/continual-learning-index.json` with `CONTINUAL_LEARNING_INDEX_PATH` + `CURSOR_AGENT_TRANSCRIPTS_ROOT`. Run `dart run tool/continual_learning_index_refresh.dart`; process only new/changed rows. Prefer `agents-memory-updater` for full flow; land durable prefs here or owning docs, never learned sections in [`AGENTS.md`](../../AGENTS.md). Optional: `dart run tool/continual_learning_summarize.dart`. `lastProcessedAt: null` after refresh means first-scan backlog.
- **Dependency automation:** bot bumps can outrun CI (Dart/Flutter SDK ranges, `eslint` / `typescript-eslint` peers). Merge only after coordinated `pubspec`/tooling/package fixes; do not merge when only CodeQL (or other non-build checks) is green — require dependency-updates / `./bin/checklist` path that runs `flutter pub get` first. Close or split Renovate groups that hit documented pins at top of [`pubspec.yaml`](../../pubspec.yaml), for example `genui` ^0.7, `google_sign_in_mocks` ^0.3, Firebase vs `firebase_auth_mocks`. Ruby/Fastlane `Gemfile` advisories: [`DEPENDENCY_UPDATES.md`](../DEPENDENCY_UPDATES.md). See [`agent_environment_setup.md`](../agent_environment_setup.md) and [`REPOSITORY_LIFECYCLE.md`](../REPOSITORY_LIFECYCLE.md).

## Repo Guardrails

- **`tool/delivery_checklist.sh`:** Every `CHECK_SCRIPTS` entry needs a matching `CHECK_MESSAGES` entry and `CHECK_SCRIPT_THEMES` entry (same length, currently 60) or delivery-checklist configuration validation fails in CI. `CHECKLIST_EXPLAIN_THEMES=1` prints `explain|theme|…` per script. Quality-theme MVP + deferred backlog: [`plans/checklist_quality_gates_baseline.md`](../plans/checklist_quality_gates_baseline.md), [`plans/checklist_quality_gates_deferred.md`](../plans/checklist_quality_gates_deferred.md).
- **Horizontal CTA / action bars:** `./bin/checklist` runs `tool/check_row_action_overflow.sh` (static PRIMARY_SCOPE heuristics) and `tool/check_action_bar_layout.sh` (widget tests). Prefer `ResponsiveDualCtaRow` / `ResponsiveActionOverflowBar` over raw multi-button `Row` — [`docs/design_system.md`](../design_system.md#horizontal-action-layout-overflow).
- **`tool/**/*.dart`:** Avoid synchronous `File.statSync` (and similar) across large file sets; `check_tool_dart_no_stat_sync.sh` enforces non-blocking patterns.
- **Ephemeral repo-root files:** Delete one-shot `tmp_*.json` at repo root (e.g. GitHub branch-protection API bodies); use `tmp/` for scratch (`tmp/*` gitignored).
- **`docs/audits/` git policy:** Keep tracked [`docs/audits/README.md`](../audits/README.md) and `dedup_matrix_*.md` (`check_agent_knowledge_base.sh` requires README). Use `.gitignore` re-includes for the README and dedup matrices; do not ignore the whole directory.

## Repo Fact

- `./bin/checklist-fast` runs report-only skill-budget pass when skill inventory file resolves (`docs/audits/skill_inventory_latest.json`, otherwise newest dated `docs/audits/skill_inventory_*.json`); implemented in `tool/check_skill_budgets.sh`. Inventory includes `~/.agents/skills` when present. Host setup orchestrator: `bash tool/setup_cursor_agent_environment.sh` (`--apply`, `--install`); Cursor `/setup-cursor-agent-environment`; skill `agents-global-skills-setup` (see [`agent_environment_setup.md`](../agent_environment_setup.md)).
