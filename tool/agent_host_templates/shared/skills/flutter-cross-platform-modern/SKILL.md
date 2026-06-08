---
name: flutter-cross-platform-modern
description: Use automatically for Flutter work involving Android, iOS, Web, Desktop, responsive/adaptive UI, platform behavior, routing/deep links, theming, accessibility, performance, or cross-target tests.
---

# Flutter cross-platform (modern)

Use when Flutter task mentions cross-platform, web, desktop, responsive/adaptive UI, platform-specific behavior, routing/deep links, theming, accessibility, performance, or tests across targets.

## Supported platforms (this repo)

First-class targets — consider **all four** when editing shared presentation,
platform adapters, plugins, or bootstrap (not only the device under debug):

| Target | Form factor | Probe focus |
| --- | --- | --- |
| **iOS / Android (mobile)** | Phone width &lt; 800 px | SafeArea/insets, keyboard overlap, touch targets, text scale, orientation overflows |
| **Tablet** | 800–1199 px | Multi-column / side-by-side where width allows; not a stretched phone layout |
| **Web** | Browser viewport | Deep links, browser back/forward, auth/route gates, web-safe imports, pointer hover/focus |
| **Desktop (macOS)** | ≥ 1200 px and **narrow windows** | Keyboard traversal, focus visibility, scroll behavior, mouse affordances |

Canon: [`tech_stack.md`](../../../../../docs/tech_stack.md) § Supported platforms;
[`design_system.md`](../../../../../docs/design_system.md) § Cross-platform form factors.
Risk: `RISK-PLATFORM-SCOPE` in [`ai_failure_risks.md`](../../../../../docs/ai/ai_failure_risks.md).

## Canon

- Start with local `AGENTS.md` and local project docs when present.
- In `flutter_bloc_app`, use `AGENTS.md` + `docs/ai/context_loading.md`.
- Constraints: `docs/agent_project_context.md` Feature Constraint Packet when present.
- Commands: `docs/agents_quick_reference.md`; routing detail: `docs/engineering/validation_routing_fast_vs_full.md`.
- UI/design: `DESIGN.md` + `docs/design_system.md`; widget sizing: `docs/testing/widget_test_playbook.md`.

## Guardrails

- No `dart:io` in Presentation. If platform IO is needed, isolate it behind a data/shared adapter; in `flutter_bloc_app`, checklist owns `check_sync_io_in_presentation.sh`.
- Avoid direct `Platform.isX` in UI. Prefer project platform adapters such as `PlatformAdaptive`, responsive extensions, injected capabilities, or web-safe `kIsWeb`/`defaultTargetPlatform` gates when existing patterns require them.
- Prefer adaptive layout and shared responsive helpers over forked widget trees. Keep app-code/UI edits on real workflow/demo surfaces, not marketing shells.
- **Responsive layout:** avoid fixed width/height on reflowable UI; use `context.responsive*` / `UI` tokens first; add `LayoutBuilder` for parent-constraint branches and `MediaQuery` for viewport/keyboard/text-scale — [`design_system.md`](../../../../../docs/design_system.md) § Responsive layout; [`ui_ux_responsive_review.md`](../../../../../docs/ui_ux_responsive_review.md) § Agent rules.
- Keep navigation ownership explicit: GoRouter/AppRoutes and presentation route decisions stay visible; Cubit side effects must not hide navigation.
- For platform plugins, verify `pubspec.lock`, package platform support, and current API before recommending or adding dependencies.

## Platform probes

Use the [Supported platforms](#supported-platforms-this-repo) table above. Additional shared checks:

- Shared UI: no text/control overlap at compact/mobile/tablet/desktop widths; widget tests at mobile + wide width when layout branches; use layout-sensitive widget tests only when layout is part of the contract.

## Cross-platform widgets (summary)

- Shared widgets/pages: **mobile, tablet, web, desktop (macOS)** — not debug-host-only.
- Tablet: use breakpoints (800–1199), not phone-only stacks on wide width.
- Web/desktop: web-safe imports, focus/keyboard; prove narrow desktop window.
- Canon: [`design_system.md`](../../../../../docs/design_system.md) § Cross-platform form factors.

## Proof

- Docs/tooling only: `./bin/checklist-fast` when repo provides it.
- Routing/auth/deep links touched: `./bin/router_feature_validate` when repo provides it.
- UI/theme/Mix touched: `./tool/check_design_md.sh` if `DESIGN.md` changed; `./tool/run_mix_lint.sh` if Mix styles/tokens changed; focused widget proof for layout-sensitive surfaces.
- Web/bootstrap/import-risk touched: `./bin/integration_preflight` or focused test named by owner docs.
- Broad/high-risk: `./bin/checklist` when repo provides it.

If a controllable Flutter debug session exists and app-code/UI changed, hot reload before claiming verified (hot restart if reload cannot apply).
