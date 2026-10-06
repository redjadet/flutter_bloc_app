# Institutional skills (docs)

Version-controlled institutional knowledge for agents. **Thin:** each skill
points at the owner doc and lists must-dos. Prefer editing the owner when policy
changes; update the skill the same turn.

These are **tool-agnostic markdown skills** (not Claude Code plugin packs). Host
skills under `tool/agent_host_templates/` remain the installable skill channel;
this folder is the readable institutional set for the AI-native SDLC loop.

| Skill | Load when | Owner doc |
| --- | --- | --- |
| [offline-first](offline-first.md) | Hive, sync, conflict, pending queue | [`offline_first`](../../offline_first/README.md) |
| [platform-channel-safety](platform-channel-safety.md) | MethodChannel, EventChannel, FFI, PlatformView | [`platforms`](../../platforms/README.md) |
| [cancellation-disposables](cancellation-disposables.md) | Cubit close, timers, subscriptions, late futures | [`cancellation_and_cache`](../../engineering/cancellation_and_cache.md) |
| [theme-tokens](theme-tokens.md) | Colors, spacing, typography, Mix styles | [`DESIGN.md`](../../../DESIGN.md), [`design_system`](../../design_system.md) |

Routing: [`skill_routing`](../../ai/skill_routing.md).  
Apply during [`spec template`](../templates/spec.md) /
[`plan template`](../templates/plan.md) / implementation, then verify via
[`gates`](../gates.md).
