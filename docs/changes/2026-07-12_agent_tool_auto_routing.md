# Agent tool auto-routing

## Problem

Preflight exposed validation commands but left tool selection to agent memory.
Runtime, package API, browser, external-service, UI, and router work could miss
the owning capability. Cursor hot-reload guidance also used pre-Melos globs and
loaded as an always-on rule.

## Decision

- Add a read-only intent/path router at `tool/agent_tool_router.sh`.
- Make session bootstrap and `agent-maintain preflight` emit deterministic
  `tool_route|...` recommendations from staged, unstaged, untracked, or explicit
  paths; provide `agent-maintain tools` for scope changes.
- Route by stable capabilities, not host-specific MCP display names.
- Scope auto-hot-reload guidance to current app/package Dart paths and stop
  loading it for unrelated tasks.
- Isolate harness `auto` smoke with plan-only mode so unrelated dirty scope
  cannot trigger coverage or host mutations during a command-contract fixture.
- Keep actions safe: inspection recommendations may be automatic; starting
  apps, installs, deploys, database writes, and external mutations remain
  explicit.

## Proof

CLI fixtures cover runtime, package, browser/UI, router, docs, shell, agent
harness, and untracked-path routing. Agent KB guards enforce current globs,
router wiring, capability wording, and owner links.
