# Compute/Isolate Usage Review

This document analyzes potential opportunities to use `compute()` and isolates to improve application responsiveness by offloading CPU-intensive work from the UI thread.

> **Related:** [Lazy Loading Analysis](../analysis/lazy_loading_late_review.md) | [Performance Profiling](STARTUP_TIME_PROFILING.md) | [Bundle Size Monitoring](BUNDLE_SIZE_MONITORING.md)

---

## Overview

**Current Status:** `compute()` is now used in production via `lib/shared/utils/isolate_json.dart` for JSON decoding in network repositories.

**Purpose:** Identify CPU-intensive operations that block the UI thread and recommend isolate-based solutions to improve responsiveness.

**When to Use Isolates:**

- ✅ JSON decoding of large payloads (>8KB threshold, automatic via `decodeJsonMap()`/`decodeJsonList()`)
- ✅ Parsing/transforming large lists (>1000 items)
- ✅ CPU-intensive computations (crypto, image processing)
- ✅ Heavy data transformations that cause UI jank

**When NOT to Use:**

- ❌ Small operations (<50ms) - overhead not worth it
- ❌ Operations requiring Flutter APIs (isolates can't access Flutter)
- ❌ Frequent, small operations - use caching instead

---

## Current Usage

- **Production code**: `lib/shared/utils/isolate_json.dart` provides `decodeJsonMap()`/`decodeJsonList()` and uses `compute()` for payloads >8KB (configurable threshold: `_kIsolateDecodeThreshold`)
- **Network repositories**: Chart, GraphQL, and Hugging Face responses now decode JSON via `decodeJsonMap()`
- **Local storage**: Chat history parsing now decodes JSON via `decodeJsonList()`
- **Demo/Testing**: Isolate samples in `lib/shared/utils/isolate_samples.dart` demonstrating Fibonacci calculations and parallel processing
- **Tests**: `test/isolate_samples_test.dart` validates isolate behavior

---

## Candidate Hotspots for Offloading

### Priority 1: JSON Decoding (High Impact)

These operations synchronously decode JSON on the UI thread. Large payloads can cause noticeable UI jank.

#### 1. Chart API Parsing

**Location:** `lib/features/chart/data/http_chart_repository.dart:89-112`

**Current Implementation (Updated):**

```dart
Future<List<ChartPoint>> _parseBody(final String body) async {
  final Map<String, dynamic> decoded = await decodeJsonMap(body);
  // ... filtering, mapping, sorting
}
```

**Impact:** Chart API responses can be 50-200KB with hundreds of data points

**Status:** ✅ Completed (decode offloaded via `decodeJsonMap()`)

**Implementation:**

- Uses `decodeJsonMap()` from `lib/shared/utils/isolate_json.dart`
- Automatically uses `compute()` for payloads >8KB (configurable threshold)
- JSON decoding happens in isolate, domain model creation on UI isolate

**Estimated Impact:** Prevents 50-200ms UI stalls on chart load

---

#### 2. GraphQL Response Parsing

**Location:** `lib/features/graphql_demo/data/countries_graphql_repository.dart:148`

**Current Implementation (Updated):**

```dart
Future<Map<String, dynamic>> _postQuery(...) async {
  final response = await _client.post(...);
  final Map<String, dynamic> decoded = await decodeJsonMap(response.body);
  // ... error handling, extraction
}
```

**Impact:** GraphQL responses for all countries can be 100-500KB

**Status:** ✅ Completed (decode offloaded via `decodeJsonMap()`)

**Estimated Impact:** Prevents 100-300ms UI stalls when loading countries

---

#### 3. Chat History Parsing

**Locations:**

- `lib/features/chat/data/chat_local_data_source.dart:53-71`
- `lib/features/chat/data/secure_chat_history_repository.dart:27`

**Current Implementation (Updated):**

```dart
Future<List<ChatConversation>> _parseStored(final dynamic raw) async {
  if (raw is String && raw.isNotEmpty) {
    final List<dynamic> decoded = await decodeJsonList(raw);
    return _parseIterable(decoded);
  }
  // ... handle Iterable case
}
```

**Impact:** Chat history can grow large (1000+ messages = 500KB+ JSON)

**Status:** ✅ Completed (decode offloaded via `decodeJsonList()` in local repositories)

**Estimated Impact:** Prevents 100-500ms UI stalls when loading chat history

---

#### 4. Hugging Face Response Parsing

**Location:** `lib/features/chat/data/huggingface_api_client.dart:80`

**Current Implementation (Updated):**

```dart
final Map<String, dynamic> decoded = await decodeJsonMap(response.body);
```

**Impact:** AI responses can be large with detailed metadata

**Status:** ✅ Completed (decode offloaded via `decodeJsonMap()`)

**Estimated Impact:** Prevents 20-100ms UI stalls per AI response

---

#### 5. Search Cache Parsing

**Location:** `lib/features/search/data/search_cache_repository.dart`

**Current Implementation:**

```dart
List<SearchResult> _parseStored(String stored) {
  final decoded = jsonDecode(stored);  // Blocks UI thread
  // ... mapping to SearchResult
}
```

**Impact:** Cached search results can be large (1000+ items)

**Recommendation:**

- Offload JSON decoding and normalization
- Return `List<Map<String, dynamic>>` to UI isolate
- Build `SearchResult` models on UI isolate

**Estimated Impact:** Prevents 50-200ms UI stalls when loading cached results

---

#### 6. Profile Cache Parsing & Size Estimation

**Location:** `lib/features/profile/data/profile_cache_repository.dart`

**Current Implementation:**

```dart
ProfileUser _parseProfile(Map<String, dynamic> raw) {
  // Synchronous parsing, size estimation
}

int _estimateSizeBytes(ProfileUser user) {
  return jsonEncode(user.toJson()).length;  // Blocks UI thread
}
```

**Impact:** Large profile galleries can cause significant parsing overhead

**Recommendation:**

- Offload `jsonEncode` for size estimation via `compute()`
- Consider isolating large list normalization
- Keep `ProfileUser` creation on UI isolate

**Estimated Impact:** Prevents 50-150ms UI stalls for large profiles

---

### Priority 2: Markdown Parsing (Medium Impact)

**Location:**

- `lib/features/example/presentation/widgets/markdown_editor/markdown_parser.dart`
- `lib/features/example/presentation/widgets/markdown_editor/markdown_render_object.dart`

**Current Implementation:**

- Parsing happens during layout via `_buildTextSpan()`
- No caching - parsed on every layout

**Impact:** Large markdown documents (>10KB) can cause layout jank

**Recommendations:**

1. **Immediate (Low Risk):** ✅ Completed - cache parsed output and only recompute when text/style changes
2. **Future (Higher Risk):** For very large documents (>50KB), move parsing to isolate:
   - Parse markdown in isolate to lightweight token representation
   - Return sendable data (list of token maps)
   - Build `TextSpan` tree on UI isolate

**Implementation Pattern for Caching:**

```dart
class MarkdownRenderObject {
  String? _lastParsedText;
  List<TextSpan>? _cachedSpans;

  List<TextSpan> _buildTextSpan(String text) {
    if (_lastParsedText == text && _cachedSpans != null) {
      return _cachedSpans!;
    }
    // Parse markdown...
    _lastParsedText = text;
    _cachedSpans = parsedSpans;
    return parsedSpans;
  }
}
```

**Estimated Impact:**

- Caching: Prevents 10-50ms layout stalls on rebuild
- Isolate parsing: Prevents 100-500ms stalls for large documents

---

## Constraints & Best Practices

### `compute()` Requirements

- **Top-level or static functions only** - Cannot be instance methods
- **Sendable data only** - Primitive types, `List`, `Map`, `TransferableTypedData`
- **No Flutter APIs** - Isolates can't access `dart:ui` or Flutter widgets
- **Domain layer restriction** - Keep domain Flutter-agnostic; `compute()` usage in data/presentation layers only

### Architecture Considerations

- **Domain models are not sendable** - Custom classes (e.g., `ChartPoint`, `GraphqlCountry`, `ChatConversation`) must be constructed on UI isolate
- **Shared helpers** - If needed, create pure Dart isolate helpers in `lib/shared/utils/` using `dart:isolate`
- **Avoid in lifecycle methods** - Never start isolates in `build()`, `performLayout()`, or synchronous callbacks
- **Schedule from repositories/cubits** - Trigger isolate work from async operations in repositories or cubit methods

### Error Handling

- Wrap `compute()` calls in try-catch
- Handle isolate failures gracefully (fallback to synchronous parsing)
- Log errors appropriately for debugging

### Performance Trade-offs

- **Overhead:** Isolate creation has ~5-20ms overhead
- **Memory:** Each isolate uses additional memory (~2-5MB)
- **Threshold:** `decodeJsonMap()`/`decodeJsonList()` use isolates for payloads >8KB (configurable via `_kIsolateDecodeThreshold`)
- **Only worth it for:** Operations taking >50ms or payloads >8KB

---

## Implementation Priority

### High Priority (Quick Wins)

1. **Chart API parsing** - ✅ Completed
2. **GraphQL response parsing** - ✅ Completed
3. **Chat history parsing** - ✅ Completed

### Medium Priority

1. **Search cache parsing** - Moderate impact (pending)
2. **Hugging Face response parsing** - ✅ Completed
3. **Profile cache parsing** - Moderate impact (pending)

### Low Priority (Optimization)

1. **Markdown parsing caching** - ✅ Completed
2. **Markdown isolate parsing** - Only for very large documents

---

## Implementation Checklist

**For JSON decoding (recommended approach):**

- [ ] Use `decodeJsonMap()` or `decodeJsonList()` from `lib/shared/utils/isolate_json.dart`
- [ ] Automatically uses `compute()` for payloads >8KB
- [ ] Map to domain models on UI isolate (domain models aren't sendable)
- [ ] Wrap in try-catch for error handling
- [ ] Add tests for parsing with large payloads
- [ ] Measure performance improvement (before/after)

**For custom isolate operations:**

- [ ] Create top-level/static function
- [ ] Function accepts sendable types (`String`, `List`, `Map`)
- [ ] Function returns sendable types
- [ ] Wrap `compute()` call in try-catch
- [ ] Handle errors gracefully (fallback to synchronous operation)
- [ ] Map to domain models on UI isolate
- [ ] Add tests for isolate operation
- [ ] Test error handling (isolate failures)
- [ ] Measure performance improvement (before/after)

---

## Testing Considerations

- **Unit tests:** Test decode functions in isolation
- **Integration tests:** Test repository methods with mocked `compute()`
- **Performance tests:** Measure parsing time before/after
- **Error tests:** Verify fallback behavior when isolates fail
- **Example:** See `test/isolate_samples_test.dart` for isolate testing patterns

---

## Related Documentation

- [Flutter `compute()` Documentation](https://api.flutter.dev/flutter/foundation/compute.html)
- [Dart Isolates Documentation](https://dart.dev/language/concurrency)
- [Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Lazy Loading Analysis](../analysis/lazy_loading_late_review.md) - Related performance optimizations
- [Startup Time Profiling](STARTUP_TIME_PROFILING.md) - Measuring performance improvements
- [Bundle Size Monitoring](BUNDLE_SIZE_MONITORING.md) - Monitoring app size

---

## Summary

**Status:** `compute()` now used for JSON decoding in network repositories; markdown parsing is cached. Additional opportunities remain in local cache parsing.

**Key Opportunities:**

- JSON decoding for large payloads (chart, GraphQL) now offloaded
- Hugging Face response decoding now offloaded
- Markdown parsing caching now in place
- Remaining: search/profile cache parsing

**Next Steps:**

1. Evaluate search/profile cache parsing for isolate offloading (currently pending)
2. Measure performance improvements from implemented optimizations
3. Consider markdown isolate parsing for very large documents (>50KB)
4. Use `decodeJsonMap()`/`decodeJsonList()` for any new large JSON payloads
5. Add tests for `isolate_json.dart` if not already present

**Expected Impact:** 50-500ms reduction in UI stalls, improved perceived performance, especially for features handling large datasets.
