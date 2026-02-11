# Dispersion Analyzer (Flutter) — Proposal Summary

**Deliverable:** Flutter mobile app (iOS + Android) that analyzes shot dispersion from target photos using the Mann-Whitney U-test. Concept similar to Ballistic-X, scoped for a fast, local-first MVP.

---

## What You Get

- **Create groups:** Camera/gallery image → calibrate with a known reference length → set aim point (origin) → mark shot points on the image → save (distance, hole diameter, name). One dataset per saved group.
- **Combine datasets:** Merge two or more datasets into a derived dataset with provenance kept.
- **Compare:** Select Dataset A and B → set alpha and “exclude outliers” → run Mann-Whitney → see U, z, p-value, significance, effect size, and a dispersion graph (both datasets + outlier styling).
- **Storage:** All data on-device; no backend or accounts in MVP.

---

## Technical Approach

- **Stack:** Flutter, layered architecture (Domain / Data / Presentation), Cubit state management, pure Dart for statistics and coordinate math (easy to unit-test and align with your Excel).
- **Calibration:** Two endpoints (pixels) + known length (mm) → scale (mm/pixel). Aim point = origin; tap positions become mm offsets and radial distance.
- **Statistics:** Mann-Whitney on radial distances; non-parametric, tie handling, continuity correction; small-sample caution when n &lt; 20.
- **Data:** DispersionPoint (x/y/radial mm, outlier flags), Group (image, calibration, aim, points), Dataset (group refs or derived sources), ComparisonResult (U, p-value, etc.).

---

## Scope

**In scope:** Manual point marking, local storage, Mann-Whitney comparison, dispersion graph, dataset combine, outlier handling (IQR + manual override).

**Out of scope for MVP:** Automatic hole detection, backend/cloud sync, user accounts, full export suite (PDF/Excel) unless added as a separate milestone.

---

## Risks and How We Address Them

- **Calibration accuracy** — Results depend on correct reference length and endpoints; we can add a “test values” flow to validate with a known image early.
- **Statistical parity with Excel** — I will validate U and p-value against one or two of your reference datasets before closing Milestone 4.
- **Point-marking on small screens** — We’ll test on real devices; zoom or confirm-step can be added if needed.

**Recommendation:** Agree on one reference comparison (e.g. one Excel sheet + expected U/p-value) before Milestone 1 sign-off so the statistical engine is locked early.

---

## Summary

- **Complexity:** Medium; main risk is statistical correctness and calibration input quality.
- **Timeline:** A focused MVP is realistic with clear scope and milestone-based delivery.

I’ll deliver a working, testable build at each milestone and keep the structure ready for future extensions (e.g. export, sync) without rewriting the core.
