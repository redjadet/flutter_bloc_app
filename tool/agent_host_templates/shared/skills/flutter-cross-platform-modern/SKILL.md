---
name: flutter-cross-platform-modern
description: Use automatically for Flutter work involving Android, iOS, Web, Desktop, responsive/adaptive UI, platform behavior, routing/deep links, theming, accessibility, performance, or cross-target tests.
---

# Flutter cross-platform (modern)

Use when Flutter task mentions cross-platform, web, desktop, responsive/adaptive UI, platform-specific behavior, routing/deep links, theming, accessibility, performance, or tests across targets.

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
- Keep navigation ownership explicit: GoRouter/AppRoutes and presentation route decisions stay visible; Cubit side effects must not hide navigation.
- For platform plugins, verify `pubspec.lock`, package platform support, and current API before recommending or adding dependencies.

## Platform probes

- Web: deep links, browser back/forward, auth/route gates, web-safe imports, pointer hover/focus when interactive.
- Desktop: keyboard traversal, focus visibility, scroll behavior, narrow window width, mouse affordances.
- Mobile: SafeArea/insets, keyboard overlap, touch target size, text scale, orientation-sensitive overflows.
- Shared UI: no text/control overlap at compact/mobile/tablet/desktop widths; use layout-sensitive widget tests only when layout is part of the contract.

## Proof

- Docs/tooling only: `./bin/checklist-fast` when repo provides it.
- Routing/auth/deep links touched: `./bin/router_feature_validate` when repo provides it.
- UI/theme/Mix touched: `./tool/check_design_md.sh` if `DESIGN.md` changed; `./tool/run_mix_lint.sh` if Mix styles/tokens changed; focused widget proof for layout-sensitive surfaces.
- Web/bootstrap/import-risk touched: `./bin/integration_preflight` or focused test named by owner docs.
- Broad/high-risk: `./bin/checklist` when repo provides it.

If a controllable Flutter debug session exists and app-code/UI changed, hot reload before claiming verified (hot restart if reload cannot apply).
