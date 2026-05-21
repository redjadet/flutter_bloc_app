# Changes (historical notes)

This directory contains point-in-time notes that explain **why** a change was
made (or what a specific refactor intended to achieve). These are not intended
to be the “current how-to”; prefer the source-of-truth docs under `docs/` for
that.

## Index

- [`2026-05-21_agent_automated_delivery_loop.md`](2026-05-21_agent_automated_delivery_loop.md): `/commit-push-pr` canon; checklist + integration proof; post-merge `main` sync.
- **2026-05-21 (doc):** Agent doc dedup — ladder canon [`ai/context_loading.md`](../ai/context_loading.md); `PLAN.md`/`quick_reference`/`KB`/`review_protocol` trimmed; harness/commands single-owner.
- [`2026-05-21_arch_001_002_case_study_decouple.md`](2026-05-21_arch_001_002_case_study_decouple.md): ARCH-001 shared media/auth ports; ARCH-002 cubit mixin split; merged PR #240.
- [`2026-05-21_firebase_secret_history_scrub.md`](2026-05-21_firebase_secret_history_scrub.md): Firebase secret-scanning remediation, `.envrc` + placeholder Dart workflow, `git filter-repo` history scrub, doc updates.
- [`2026-05-20_checklist_quality_gates.md`](2026-05-20_checklist_quality_gates.md): four quality-theme checklist gates (MVP), `CHECK_SCRIPT_THEMES`, path-triggered router validate; deferred backlog in [`plans/checklist_quality_gates_deferred.md`](../plans/checklist_quality_gates_deferred.md).
- [`2026-05-17_global_agent_skills_install_trim.md`](2026-05-17_global_agent_skills_install_trim.md): repo scripts to install/update/dedupe global vendor skills (`~/.agents/skills` vs synced `~/.cursor/skills`); skill inventory/budget includes `agentsSkills`.
- [`2026-05-14_json_utf8_bytes_decode_and_hf_bytes.md`](2026-05-14_json_utf8_bytes_decode_and_hf_bytes.md): UTF-8 bytes JSON helpers (`decodeJsonMapFromBytes` / fused `utf8`+`json` converter), Hugging Face client `ResponseType.bytes`, tests; pointers to future Retrofit-bytes and optional FFI/SIMD JSON evaluation.
- [`2026-05-12_modular_architecture_plan_implementation.md`](2026-05-12_modular_architecture_plan_implementation.md): modular metrics script, generalized modularity gate, shared↔feature decoupling (`AppMemoryService`), DI group `part` split, tests + feasibility docs.
- [`2026-05-12_senior_quality_hotspots_audit.md`](2026-05-12_senior_quality_hotspots_audit.md): hotspot churn audit outcome, SAFE vs backlog split, and where the full write-up lives (`docs/audits/`).
- [`2026-05-05_codex_context_navigation_ladder.md`](2026-05-05_codex_context_navigation_ladder.md): Codex context-navigation ladder for
  durable memory, structural graph use, and targeted raw-file reads.
- [`2026-05-04_hive_schema_migrations_full_migrate_todo_counter.md`](2026-05-04_hive_schema_migrations_full_migrate_todo_counter.md): manifest-driven
  Hive schema migrations; full migrate for todo + counter; pending-sync section
  is historical-only (superseded by shipped May 5 pending-sync migration docs).
- [`2026-04-02_case_study_supabase_private_storage_plan.md`](2026-04-02_case_study_supabase_private_storage_plan.md): optional Supabase private
  storage, RLS, and submit flow for the dentist **Case Study Demo** feature.
- [`2026-04-01_dentist_case_study_demo_plan.md`](2026-04-01_dentist_case_study_demo_plan.md): **Case Study Demo** feature scope, routes, auth,
  Hive persistence, and tests (implements [`docs/case_studies/dentists.md`](../case_studies/dentists.md)).
- [`2026-03-24_agent_output_optimization_purpose.md`](2026-03-24_agent_output_optimization_purpose.md): motivation/constraints for
  agent-output optimization work.
- [`2026-02-23_code_quality_plan.md`](2026-02-23_code_quality_plan.md): historical plan document (superseded by
  current docs + implemented changes).
- [`2026-02-23_code_improvements.md`](2026-02-23_code_improvements.md): summary of improvements landed in that
  timeframe.
