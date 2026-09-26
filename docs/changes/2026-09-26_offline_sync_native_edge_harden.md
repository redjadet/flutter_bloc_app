# Offline/sync + native channel edge-case harden

**Date:** 2026-09-26

## Why

Soft-fail offline sync paths and native telemetry decoding still treated only
`Exception` / Dart `int` shapes. Non-Exception `Error`s and platform-channel
numeric doubles could tear down sync or drop telemetry silently.

## In

- Soft-fail `pullRemote` / merge / refresh paths catch `Object` (counter, todo,
  search, remote config, graphql cache fallback)
- Chat enqueue path: queue `Exception`s only; log + rethrow programming `Error`s
- Native telemetry EventChannel: handle `PlatformException`; coerce
  integer-valued `num` from platform payloads
- Focused regression tests for `StateError` / `PlatformException` / double ints

## Proof

- Focused unit tests listed in the harden progress note
- `./bin/format`; repo unit/widget scripts; iPhone integration via
  `./bin/integration_tests` or GHA `run_integration=true` when sandbox blocks
  xcodebuild
