# Plans (historical and in-flight)

This directory contains design notes and execution plans.

## How to use these documents

- Prefer the **current source-of-truth docs** under `docs/` for day-to-day work
  (onboarding, architecture, validation, testing, security, deployment).
- Treat plans as **working documents**: they can be superseded by implemented
  code, ADRs, or newer docs.
- When a plan results in a repo-wide decision, record it as an ADR under
  `docs/adr/` or update the owning source-of-truth doc.

## Index

- [`2026-04-27_ai_agent_code_quality_hardening_plan.md`](2026-04-27_ai_agent_code_quality_hardening_plan.md): Cursor-ready plan for hardening AI-agent guidance,
  validation helpers, and confirmed AI-generated-code risk patterns.
- [`future_architecture_code_quality_improvement_plan.md`](future_architecture_code_quality_improvement_plan.md): staged roadmap and
  decision gates for ongoing quality/architecture work.
- [`settings_diagnostics_decouple_plan.md`](settings_diagnostics_decouple_plan.md): completed slice (kept for context).
- [`2026-03-13-structured-error-taxonomy-design.md`](2026-03-13-structured-error-taxonomy-design.md): design notes for typed error
  taxonomy work.
- [`dio_retrofit_integration_plan.md`](dio_retrofit_integration_plan.md): integration plan for Dio/Retrofit patterns.
- [`supabase_proxy_huggingface_chat_plan.md`](supabase_proxy_huggingface_chat_plan.md): Action plan for Supabase Edge → Hugging Face chat proxy (offline-first contract: [`offline_first/chat.md`](../offline_first/chat.md)).
- [`supabase_proxy_huggingface_chat_plan_codex_review.md`](supabase_proxy_huggingface_chat_plan_codex_review.md): Archival verbatim Codex (**gpt-5.4**) operability review of that plan.
- [`render_fastapi_chat_demo_plan.md`](render_fastapi_chat_demo_plan.md): FastAPI on Render as **AI orchestration** demo wired into existing Flutter chat (Render → FastAPI pipeline, fallthrough to Supabase/HF, security/Dio/testing contract).
