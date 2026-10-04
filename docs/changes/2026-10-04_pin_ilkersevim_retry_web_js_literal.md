# Change note: pin `ilkersevim_retry` 0.1.5 (web dart2js)

## Why

Tip `7c0f4b7e` (#977 bumped `ilkersevim_retry` to `^0.1.6`) fails web compile /
`./bin/integration_preflight` chrome bootstrap:

`Error: The integer literal 0x7FFFFFFFFFFFFFFF can't be represented exactly in JavaScript`
in `retry_policy.dart` (dart2js).

## What landed

- `apps/mobile` + `packages/networking`: pin `ilkersevim_retry: 0.1.5`
- `renovate.json`: hold `ilkersevim_retry` `<0.1.6` until upstream ships a
  JS-safe release

## Verification

```bash
INTEGRATION_PREFLIGHT_WEB_DEVICE=chrome ./bin/integration_preflight
cd apps/mobile && flutter build web --debug --no-tree-shake-icons --no-wasm-dry-run
```
