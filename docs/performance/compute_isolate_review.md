# Compute / isolate — current contract

Offload CPU-heavy work with `compute()` via
[`package:ilkersevim_json_isolate`](https://pub.dev/packages/ilkersevim_json_isolate).

## Rules

| Do | Don’t |
| --- | --- |
| JSON decode/encode above ~8KB via `decodeJsonMap` / `decodeJsonList` / `encodeJsonIsolate` | Raw `jsonDecode`/`jsonEncode` on large payloads |
| Prefer **bytes** APIs (`decodeJsonMapFromBytes` / `decodeJsonListFromBytes`) when Dio returns `ResponseType.bytes` | Allocate a full body `String` then decode |
| Use isolates for crypto / heavy transforms that jank UI | Isolate for &lt;50ms work or Flutter API access |

## Guards

- `tool/check_raw_json_decode.sh`
- `tool/check_compute_lifecycle.sh`
- `tool/check_compute_domain_layer.sh`

## Related

- [`reliability_error_handling_performance.md`](../reliability_error_handling_performance.md)
- [`SHARED_UTILITIES.md`](../engineering/SHARED_UTILITIES.md)
- Change notes: [`2026-05-14_json_utf8_bytes_decode_and_hf_bytes.md`](../changes/2026-05-14_json_utf8_bytes_decode_and_hf_bytes.md),
  [`2026-07-22_json_isolate_public_package.md`](../changes/2026-07-22_json_isolate_public_package.md),
  [`2026-07-22_retire_json_isolate_shim.md`](../changes/2026-07-22_retire_json_isolate_shim.md)
- Profiling (optional): [`startup_time_profiling.md`](startup_time_profiling.md), [`bundle_size_monitoring.md`](bundle_size_monitoring.md)
