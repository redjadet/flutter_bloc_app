# 2026-07-17 — Memory quality Wave A

Shipped progressive memory gate:

- Native `memory_lint` plugin (four syntax-only rules) + `tool/run_memory_lint.sh`
- Tagged `leak_tracker` suite via `leakSafeTestWidgets` (`memory_leak` tag)
- Checklist enforces both gates; untagged tests remain globally ignored
- Docs hub under `docs/performance/memory_*.md` + PR template section

Boundary: no global leak flip, no DCM, no broad ownership rewrite.
