# Feature: Agent Communication Layer demo

Date: 2026-10-23

## Problem

Need an in-repo, reviewable proof that a Flutter client can talk to an
**out-of-process** agent engine over JSON-RPC, with `flutter_rust_bridge`
reserved for trusted in-process helpers — matching the Codex desktop ↔ App
Server separation pattern.

## Scope

- **In:** architecture doc + mermaid, change note, feature guide, Rust Tokio
  JSON-RPC stub (`native/agent_engine`), Dart stdio client + Cubit + demo page,
  Dart subprocess fallback, route (dev-gated), targeted tests
- **Out:** full PTY/Git/sandbox, FRB codegen, Example-page button (keeps main
  product flows clean), production agent product

## Layers touched

- [x] domain
- [x] data
- [x] presentation
- [x] routes (demo-only)
- [x] native engine + docs

## Contracts

- Domain: `AgentEngineSession` (`connect` / `ping` / `streamDemo` / `disconnect`)
- Transport: newline-delimited JSON-RPC 2.0 over child stdio
- Failures: sealed `AgentCommsFailure` mapped in data layer
- Trusted helper: `TrustedNativeHelper` port (FRB extension point; no FRB codegen)

## Decisions

| Decision | Choice |
| --- | --- |
| Agent path | Separate process + JSON-RPC (not in-process FRB) |
| Engine | Real Rust + Tokio when `cargo` builds; Dart stub fallback |
| FRB | Documented + empty port only |
| Navigation | `/agent-comms-demo` only — no Example wiring |

## Paths

| Piece | Path |
| --- | --- |
| Architecture | [`../architecture/agent_communication_layer.md`](../architecture/agent_communication_layer.md) |
| Feature | `apps/mobile/lib/features/agent_comms_demo/` |
| Rust engine | `native/agent_engine/` |
| Dart stub | `tool/agent_engine_dart_stub/` |
| Feature guide | [`../features/agent_comms_demo.md`](../features/agent_comms_demo.md) |

## Tests / proof

| Lane | Command |
| --- | --- |
| Unit / cubit | `cd apps/mobile && flutter test test/features/agent_comms_demo` |
| Analyze | `flutter analyze` (workspace / app) |
| Engine smoke | `cd native/agent_engine && cargo build && printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"ping","params":{}}' \| ./target/debug/agent_engine` |
