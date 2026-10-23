# Agent Comms Demo

Developer demo for the [Agent Communication Layer](../architecture/agent_communication_layer.md).

## Open

Dev / non-prod only: navigate to `/agent-comms-demo` (route name
`agent-comms-demo`). Not linked from Example so main product flows stay clean.

## Actions

1. **Connect** — spawn Rust `agent_engine` (or Dart stub fallback)
2. **Ping** — JSON-RPC `ping`
3. **Stream demo** — `agent/streamDemo` + `agent/event` notifications
4. **Disconnect** — shutdown + kill child

## Env

| Variable | Effect |
| --- | --- |
| `AGENT_ENGINE_PATH` | Absolute path to the Rust (or compatible) binary |
| unset | Falls back to `dart run tool/agent_engine_dart_stub/bin/agent_engine_stub.dart` |
