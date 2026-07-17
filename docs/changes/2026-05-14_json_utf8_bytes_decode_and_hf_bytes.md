# JSON: UTF-8 bytes decode path and Hugging Face `ResponseType.bytes` (2026-05-14)

## Why

External write-ups (for example Medium pieces citing Dart VM JSON work and experimental SIMD/FFI parsers) keep pressure on **avoiding unnecessary work when parsing HTTP JSON**. Two practical levers in this repo:

1. **Do not materialize the full response body as a Dart `String` before parsing** when the stack already has UTF-8 bytes (typical for Dio with `ResponseType.bytes`).
2. **Keep large parse work off the UI isolate** using the existing 8KB threshold and `compute()` where appropriate.

## What shipped

- **`apps/mobile/lib/shared/utils/isolate_json.dart`**
  - Added **`decodeJsonMapFromBytes`** / **`decodeJsonListFromBytes`**.
  - Implementation uses **`utf8.decoder.fuse(json.decoder)`** so bytes decode to a JSON object in one fused converter path (documented `dart:convert` pattern). The public **`JsonUtf8Decoder`** type referenced in some articles is **not** available as a stable public API in the SDK version pinned here; the fused converter is the supported equivalent for “bytes in, parsed object out.”
  - Same **`_kIsolateDecodeThreshold`** (8KB) as the string APIs: smaller payloads parse synchronously on the current isolate; larger ones use **`compute()`** with a **`Uint8List`** argument.
- **`apps/mobile/lib/features/chat/data/huggingface_api_client.dart`**
  - Success path uses **`ResponseType.bytes`** and **`decodeJsonMapFromBytes`** so large HF JSON is not first copied into a single **`String`** for parsing.
  - **`formatError`** accepts **`Response<dynamic>`** and reads **`String` or `List<int>`** error bodies (HTTP failure responses may still be bytes).
- **Tests:** `test/shared/utils/isolate_json_test.dart` (bytes APIs), Hugging Face client tests updated for byte responses.
- **Chart (CoinGecko / Retrofit):** `coingecko_api` uses **`ResponseType.bytes`**; `DirectChartRemoteRepository` and `HttpChartRepository` call **`decodeJsonMapFromBytes`**. Payloads are small (~7 points); main win is skipping Dio’s intermediate body **`String`**, not isolate offload.
- **GraphQL countries (raw HTTP):** `countries_graphql_api` returns **`HttpResponse<List<int>>`**; `CountriesGraphqlRepository` uses **`bytesResponseFromHttpResponse`** + **`decodeJsonMapFromBytes`**. AllCountries JSON is large enough to hit the 8KB isolate threshold in tests — **high-value** site.
- **`apps/mobile/lib/shared/http/retrofit_response_utils.dart`:** **`bytesResponseFromHttpResponse`** for byte Retrofit responses.
- **Skipped:** `SupabaseGraphqlDemoRepository` — Supabase client returns parsed objects, not a raw JSON string.
- **Codegen pins (2026-05-15):** `json_serializable: 6.11.3`, `json_annotation: ^4.9.0`, `dependency_overrides: analyzer: 8.4.1` so **`dart run build_runner build`** and **`dart run custom_lint`** both resolve (6.12+ needs analyzer ≥9; 6.13+ needs ≥10).

## Operational notes

- **Retrofit / remaining `String` APIs:** Any new large JSON Retrofit client should follow the chart/GraphQL pattern (`@DioResponseType(ResponseType.bytes)`, **`List<int>`**, **`decodeJsonMapFromBytes`**). Do not run narrow **`build_runner --build-filter`** without a full codegen pass afterward — it can delete unrelated **`*.freezed.dart`** / **`*.g.dart`** outputs.
- **Raw `jsonDecode`:** `tool/check_raw_json_decode.sh` remains the guard for avoiding accidental large synchronous parses outside the shared helpers; tiny payloads (JWT inspection, error snippets) may still use **`jsonDecode`** with an inline rationale where already documented in code.

## Possible future work (not committed)

Prioritize only after profiling shows JSON as a hotspot.

1. **Threshold tuning:** Make **`_kIsolateDecodeThreshold`** configurable per flavor or Remote Config for low-end devices (documented in the [performance compute/isolate review](../performance/compute_isolate_review.md)).
2. **Experimental FFI / SIMD JSON:** Evaluate third-party or research parsers (for example SIMD-backed native libraries) only with a clear **binary size, platform matrix, and CI** story; justify any new dependency per repo dependency-review rules. The Dart SDK issue **`dart-lang/sdk#55522`** tracks VM decoder improvements upstream.

## Where to read more

- [Performance compute/isolate review](../performance/compute_isolate_review.md) — current usage and future JSON notes.
- **[`SHARED_UTILITIES.md`](../SHARED_UTILITIES.md)** — `isolate_json` usage examples (string and bytes).
- **[`reliability_error_handling_performance.md`](../reliability_error_handling_performance.md)** — performance table row for large JSON.
