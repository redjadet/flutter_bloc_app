# Validation scripts — performance lists

Router: [`../validation_scripts.md`](../validation_scripts.md).

## Performance Optimization

### `check_missing_const.sh`

**Purpose**: Identifies potential missing `const` constructors in `StatelessWidget` (heuristic check).

**What it checks**:

- `StatelessWidget` classes with constructors that could be `const`
- Heuristic-based (may have false positives/negatives)

**Why it matters**:

- `const` constructors reduce widget rebuilds
- Improves performance by reusing widget instances
- Best practice for widgets that don't depend on runtime data

**Example violation**:

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({super.key}); // Could be const but isn't
  // ...
}
```

**Note**: This is **heuristic check** (warns but doesn't fail checklist). Review manually for optimization opportunities.

**Suppression**: Add `// check-ignore: reason` on same line or line above

---

### `check_perf_shrinkwrap_lists.sh`

**Purpose**: Flags `shrinkWrap: true` on presentation lists (potential perf issue).

**What it checks**:

- `shrinkWrap: true` in presentation widgets

**Why it matters**:

- `shrinkWrap` forces additional layout passes and can be expensive on large lists
- Often avoidable with constrained layouts or builders

**Example violation**:

```dart
ListView(shrinkWrap: true, children: items) // ❌ Potential perf hit
```

**Correct pattern**:

```dart
ListView.builder(itemCount: items.length, itemBuilder: ...) // ✅
```

**Suppression**: Add `// check-ignore: reason` on same line or line above

---

### `check_perf_nonbuilder_lists.sh`

**Purpose**: Flags likely dynamic `ListView`/`GridView` `children:` construction in presentation (eager build).

**What it checks**:

- `ListView`/`GridView` with dynamic `children:` sources such as `.map(...)`,
  `List.generate(...)`, or collection `for`

**Why it matters**:

- Eager list builds can be slow for large/dynamic data sets
- Builder variants are more efficient
- Small static/prebuilt section lists may use `children:` when stable widget
  identity matters.

**Example violation**:

```dart
ListView(children: rows.map(buildRow).toList()) // ❌ Eager dynamic build
```

**Correct pattern**:

```dart
ListView.builder(itemCount: items.length, itemBuilder: ...) // ✅
ListView(children: staticSections) // ✅ small prebuilt/static sections
```

**Suppression**: Add `// check-ignore: reason` on same line or line above

---

### `check_perf_missing_repaint_boundary.sh`

**Purpose**: Flags heavy widgets without `RepaintBoundary` in presentation (heuristic).

**What it checks**:

- Uses of `CustomPaint`, `ShaderMask`, `BackdropFilter`, `ImageFiltered`, `ClipPath` without `RepaintBoundary` in same file

**Why it matters**:

- Heavy paint/filter widgets can trigger costly repaints
- `RepaintBoundary` can isolate expensive subtrees

**Example violation**:

```dart
CustomPaint(painter: painter) // ❌ No RepaintBoundary in file
```

**Correct pattern**:

```dart
RepaintBoundary(child: CustomPaint(painter: painter)) // ✅
```

**Suppression**: Add `// check-ignore: reason` on same line or line above

---
