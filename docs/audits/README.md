# Audits (historical snapshots)

This directory contains point-in-time reviews of the repository (architecture,
quality, lifecycle, performance). These documents are useful for context and
trend tracking, but they are **not** the day-to-day source of truth.

## How to use these documents

- Use audits to understand *why* a guideline exists or to compare “before vs
  after” when the repo evolves.
- If an audit discovers an invariant that should be enforced, prefer encoding
  it as:
  - a validation script under `tool/` (and document it in
    [`validation_scripts.md`](../validation_scripts.md)), or
  - an ADR under `docs/adr/`, or
  - a focused update to an existing source-of-truth doc.

## Index

- [`codebase_analysis_2026-03-17.md`](codebase_analysis_2026-03-17.md): repo-level architecture + maintainability
  assessment.
- [`baseline_inventory_2026-03-17.md`](baseline_inventory_2026-03-17.md): baseline inventory snapshot.
- [`code_quality_analysis_2026-02-23.md`](code_quality_analysis_2026-02-23.md): deep code-quality review snapshot.
- [`phase2_lifecycle_async_audit_2026-02-23.md`](phase2_lifecycle_async_audit_2026-02-23.md): lifecycle/async audit snapshot.
- [`shrinkwrap_slivers_audit.md`](shrinkwrap_slivers_audit.md): UI performance audit (shrinkwrap/slivers).
