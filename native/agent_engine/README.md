# Agent engine (demo stub)

Out-of-process **JSON-RPC** agent engine used by `agent_comms_demo`.

Untrusted agent work (orchestration, PTY, git, sandbox, model I/O) belongs
**here**, not inside the Flutter UI process. Flutter speaks JSON-RPC over stdio
(or TCP localhost). `flutter_rust_bridge` is reserved for trusted in-process
helpers — see `docs/architecture/agent_communication_layer.md`.

## Build

```bash
cd native/agent_engine
cargo build --release
# binary: target/release/agent_engine
```

## Protocol (newline-delimited JSON-RPC 2.0)

| Method | Purpose |
| --- | --- |
| `ping` | Liveness → `{ ok, engine, version, pid }` |
| `agent/streamDemo` | Emits a few `agent/event` notifications then a result |

Notifications: `{"jsonrpc":"2.0","method":"agent/event","params":{...}}`

## Extension points (stubs only)

- PTY / terminal
- Git & filesystem
- Sandbox & permissions
- Model API client / local models
- External tools

Do not implement full sandbox in this demo.
