# CustomPainter & RenderObject Guide

Practical notes on drawing bespoke visuals with `CustomPainter` and `RenderObject` while keeping our Clean Architecture + BLoC setup intact and code tidy.

## Overview

Flutter provides two primary mechanisms for custom rendering:

1. **`CustomPainter`**: A delegate that paints custom graphics within a `CustomPaint` widget. Best for visual effects where layout is handled by parent widgets.

2. **`RenderObject`**: The low-level rendering primitive that controls both layout and painting. Use when you need custom layout algorithms, hit-testing, or fine-grained performance control.

Both approaches integrate seamlessly with BLoC/Cubit state management and respect our Clean Architecture boundaries.

## When to Choose Each

### Use `CustomPainter` when

- Drawing data-driven visuals (rings, charts, badges, progress indicators)
- Layout is simple or handled by parent widgets
- You need to paint within existing widget constraints
- Performance is adequate with standard widget tree
- Examples: `WhiteboardPainter` (stroke rendering), progress rings, custom badges

### Use `RenderObjectWidget` when

- You need custom layout algorithms (beyond `Row`/`Column`/`Stack`)
- Custom hit-testing behavior is required
- Fine-grained paint optimizations are critical
- Stock widgets cannot provide the needed efficiency
- Examples: `MarkdownRenderObject` (text layout), segmented bars, rulers, physics-driven effects

### When NOT to use either

- Standard widgets (`Container`, `Row`, `Column`, `Stack`) can achieve the goal
- Simple styling can be done with `BoxDecoration` or `ShapeDecoration`
- Composition of existing widgets solves the problem
- Performance is not a concern and standard widgets are sufficient

**Performance tip**: Always wrap expensive painters/widgets in `RepaintBoundary` and feed them with `BlocSelector` to avoid redundant rebuilds.

## How Clean Architecture and BLoC Are Used

This section explains how CustomPainter and RenderObject integrate with our Clean Architecture and BLoC/Cubit state management, ensuring rendering code remains testable, maintainable, and follows SOLID principles.

### Architecture Layers and Data Flow

The rendering layer (CustomPainter/RenderObject) sits at the **Presentation** level, but data flows through all layers:

```text
┌─────────────────────────────────────────────────────────────┐
│ Domain Layer (Flutter-agnostic)                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ CounterRepository (abstract contract)                   │ │
│ │   - load(): Future<CounterSnapshot>                      │ │
│ │   - save(CounterSnapshot): Future<void>                 │ │
│ │   - watch(): Stream<CounterSnapshot>                     │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                          ▲
                          │ implements
┌─────────────────────────────────────────────────────────────┐
│ Data Layer (Platform-specific implementations)              │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ HiveCounterRepository implements CounterRepository     │ │
│ │ OfflineFirstCounterRepository wraps Hive + Remote      │ │
│ │ (Registered via injector.dart → get_it)                  │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                          ▲
                          │ depends on (injected)
┌─────────────────────────────────────────────────────────────┐
│ Presentation Layer - Business Logic                         │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ CounterCubit extends Cubit<CounterState>               │ │
│ │   - Consumes CounterRepository (domain contract)        │ │
│ │   - Enforces business rules (auto-decrement, min=0)    │ │
│ │   - Emits immutable CounterState                        │ │
│ │   - Handles persistence, timers, error states           │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                          ▲
                          │ reads state via BlocSelector
┌─────────────────────────────────────────────────────────────┐
│ Presentation Layer - Rendering                               │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Widget → BlocSelector → CustomPainter/RenderObject     │ │
│ │   - Widgets read state, derive visual values          │ │
│ │   - Pass only derived data to painters/render objects │ │
│ │   - No direct repository access in rendering code      │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Key Principles

1. **Separation of Concerns**: Each layer has a single responsibility
   - **Domain**: Business contracts (no Flutter dependencies)
   - **Data**: Platform-specific implementations (Hive, REST, etc.)
   - **Presentation (Cubit)**: Business logic orchestration
   - **Presentation (Widgets/Painters)**: Visual representation only

2. **Dependency Inversion**: Rendering code depends on abstractions (Cubit state), not concrete implementations (repositories)

3. **Testability**: Painters and render objects can be tested with mock states without touching repositories

4. **Maintainability**: Changing data sources (Hive → REST) doesn't affect rendering code

### Complete Data Flow Example

Here's how data flows from domain to rendering:

```dart
// 1. Domain Contract (lib/features/counter/domain/counter_repository.dart)
abstract class CounterRepository {
  Future<CounterSnapshot> load();
  Future<void> save(CounterSnapshot snapshot);
  Stream<CounterSnapshot> watch();
}

// 2. Data Implementation (lib/features/counter/data/hive_counter_repository.dart)
class HiveCounterRepository implements CounterRepository {
  @override
  Future<CounterSnapshot> load() async {
    // Hive-specific implementation
    final box = await HiveService.instance.openBox<CounterSnapshot>('counter');
    return box.get('current') ?? CounterSnapshot(count: 0);
  }
  // ... other methods
}

// 3. Dependency Injection (lib/core/di/injector.dart)
void configureDependencies() {
  getIt.registerLazySingleton<CounterRepository>(
    () => HiveCounterRepository(),
  );
  getIt.registerFactory<CounterCubit>(
    () => CounterCubit(repository: getIt<CounterRepository>()),
  );
}

// 4. Presentation - Cubit (lib/features/counter/presentation/counter_cubit.dart)
class CounterCubit extends Cubit<CounterState> {
  CounterCubit({required CounterRepository repository})
      : _repository = repository,
        super(const CounterState(count: 0));

  final CounterRepository _repository; // Depends on domain contract

  Future<void> increment() async {
    final nextState = state.copyWith(count: state.count + 1);
    emit(nextState);
    await _repository.save(CounterSnapshot(count: nextState.count));
  }
}

// 5. Presentation - Widget with CustomPainter
class CounterRing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ✅ GOOD: Widget reads state via BlocSelector, derives visual value
    return BlocSelector<CounterCubit, CounterState, int>(
      selector: (state) => state.count, // Select only what's needed
      builder: (context, count) {
        // Derive visual value from state
        final progress = (count / maxCount).clamp(0, 1);

        // Pass derived value to painter (no repository access)
        return CustomPaint(
          painter: CounterRingPainter(progress: progress),
        );
      },
    );
  }
}

// 6. CustomPainter receives only derived visual data
class CounterRingPainter extends CustomPainter {
  final double progress; // Pure visual value, no business logic

  @override
  void paint(Canvas canvas, Size size) {
    // Paint based on progress value only
    // No access to CounterRepository, CounterCubit, or business logic
  }
}
```

### Anti-Patterns: What NOT to Do

```dart
// ❌ BAD: Painter accessing repository directly
class BadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Violates Clean Architecture - rendering layer touching data layer
    final repository = getIt<CounterRepository>();
    final snapshot = await repository.load(); // Don't do this!
    final count = snapshot.count;
    // ... paint
  }
}

// ❌ BAD: Painter accessing cubit directly
class BadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Violates separation - painter shouldn't know about state management
    final cubit = context.read<CounterCubit>();
    final count = cubit.state.count; // Don't do this!
    // ... paint
  }
}

// ❌ BAD: Widget not using BlocSelector
class BadWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Rebuilds on ANY state change, even unrelated ones
    return BlocBuilder<CounterCubit, CounterState>(
      builder: (context, state) {
        return CustomPaint(
          painter: CounterRingPainter(progress: state.count / 20),
        );
      },
    );
  }
}
```

### Best Practices: What TO Do

```dart
// ✅ GOOD: Widget derives value, passes to painter
class GoodWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Only rebuilds when count changes (not on status/error changes)
    return BlocSelector<CounterCubit, CounterState, int>(
      selector: (state) => state.count,
      builder: (context, count) {
        // Derive visual value in widget layer
        final progress = (count / maxCount).clamp(0, 1);

        // Wrap in RepaintBoundary for performance
        return RepaintBoundary(
          child: CustomPaint(
            painter: CounterRingPainter(
              progress: progress, // Pure visual data
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      },
    );
  }
}

// ✅ GOOD: Painter is pure, receives only visual data
class GoodPainter extends CustomPainter {
  final double progress;
  final Color activeColor;

  GoodPainter({required this.progress, required this.activeColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Pure painting logic, no business logic, no dependencies
    // Can be tested with simple values
  }

  @override
  bool shouldRepaint(GoodPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.activeColor != activeColor;
  }
}
```

### Benefits of This Architecture

1. **Testability**: Painters can be tested with simple values, no need to mock repositories
2. **Flexibility**: Can swap Hive → REST → GraphQL without touching rendering code
3. **Performance**: `BlocSelector` prevents unnecessary rebuilds
4. **Maintainability**: Clear boundaries make code easier to understand and modify
5. **Reusability**: Painters can be reused with different data sources

## CustomPainter Example: Counter Progress Ring

This example demonstrates a complete CustomPainter implementation that follows Clean Architecture principles. The painter receives only derived visual data from the widget, which reads state from `CounterCubit`.

```dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

/// Widget that displays a circular progress ring based on counter state.
///
/// Uses [BlocSelector] to only rebuild when the count changes, and wraps
/// the painter in [RepaintBoundary] to isolate repaints.
class CounterRing extends StatelessWidget {
  const CounterRing({super.key, this.maxCount = 20});

  final int maxCount;

  @override
  Widget build(final BuildContext context) {
    return BlocSelector<CounterCubit, CounterState, int>(
      selector: (final state) => state.count,
      builder: (final context, final count) {
        // Derive progress value from count (0.0 to 1.0)
        final double progress = (count / maxCount).clamp(0, 1);
        final double diameter = context.responsiveIconSize * 3;

        return RepaintBoundary(
          child: CustomPaint(
            painter: CounterRingPainter(
              progress: progress,
              activeColor: Theme.of(context).colorScheme.primary,
              trackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            size: Size.square(diameter),
          ),
        );
      },
    );
  }
}

/// Custom painter that draws a circular progress ring.
///
/// The ring consists of:
/// - A full circle track (background)
/// - An arc representing progress (0° to 360°)
///
/// Always implement [shouldRepaint] to avoid unnecessary repaints.
class CounterRingPainter extends CustomPainter {
  CounterRingPainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
  });

  final double progress;
  final Color activeColor;
  final Color trackColor;

  @override
  void paint(final Canvas canvas, final Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.width / 2;

    // Configure paint for the track (background circle)
    final Paint trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = size.width * 0.08
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Configure paint for the active progress arc
    final Paint activePaint = Paint()
      ..color = activeColor
      ..strokeWidth = trackPaint.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw full background circle
    canvas.drawCircle(center, radius, trackPaint);

    // Draw progress arc starting from top (-π/2) and sweeping clockwise
    final double sweep = math.pi * 2 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start at top (12 o'clock)
      sweep,        // Sweep angle based on progress
      false,        // Not filled (stroke only)
      activePaint,
    );
  }

  @override
  bool shouldRepaint(final CustomPainter oldDelegate) {
    // Always repaint if delegate type changes
    if (oldDelegate is! CounterRingPainter) return true;

    // Only repaint if visual properties actually changed
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor;
  }
}
```

### CustomPainter Architecture Flow

1. **Domain**: `CounterRepository` contract defines `load()`, `save()`, `watch()`
2. **Data**: `HiveCounterRepository` implements the contract (registered via `injector.dart`)
3. **Cubit**: `CounterCubit` consumes repository, manages state, emits `CounterState`
4. **Widget**: `CounterRing` uses `BlocSelector` to read only `count` from state
5. **Derivation**: Widget calculates `progress = (count / maxCount).clamp(0, 1)`
6. **Painter**: `CounterRingPainter` receives pure visual data (`progress`, colors)
7. **Rendering**: Painter draws based on visual values only, no business logic

### CustomPainter Key Points

- **Separation of concerns**: The cubit handles loading/saving counter data through the domain repository; the painter only receives the derived `progress` value. No repository access in rendering code.
- **Performance**: `BlocSelector` avoids repainting when unrelated state fields (like `status` or `error`) change. `RepaintBoundary` isolates expensive paint operations from parent rebuilds.
- **Responsive design**: Sizing uses `context.responsiveIconSize` to adapt to different screen sizes, following our responsive design patterns.
- **Efficient repainting**: `shouldRepaint` checks for actual visual changes before triggering a repaint, preventing unnecessary work.
- **Testability**: Painter can be tested with simple `progress` values without mocking repositories or cubits.

### Common CustomPainter Patterns

1. **Reusing Paint objects**: For static paint properties, consider creating `Paint` objects as instance variables to avoid allocation overhead.
2. **Path caching**: For complex paths that don't change, cache `Path` objects and reuse them.
3. **Partial repaints**: Use `Canvas.clipRect()` to limit painting to visible areas when possible.

## RenderObject Example: Segmented Counter Bar

This example demonstrates a complete RenderObject implementation that follows Clean Architecture principles. The render object handles both layout and painting, receiving only visual data derived from BLoC state.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

/// Widget that displays a horizontal segmented bar.
///
/// Each segment represents a unit of progress. Active segments are fully
/// opaque, inactive segments are semi-transparent.
class SegmentedCounterBar extends LeafRenderObjectWidget {
  const SegmentedCounterBar({
    super.key,
    required this.activeSegments,
    required this.totalSegments,
    required this.color,
  });

  final int activeSegments;
  final int totalSegments;
  final Color color;

  @override
  RenderObject createRenderObject(final BuildContext context) {
    return _SegmentedCounterBarRenderObject(
      activeSegments: activeSegments,
      totalSegments: totalSegments,
      color: color,
      thickness: context.responsiveIconSize * 0.15,
      gap: context.responsiveGapXS,
    );
  }

  @override
  void updateRenderObject(
    final BuildContext context,
    final _SegmentedCounterBarRenderObject renderObject,
  ) {
    // Update all properties that might have changed
    renderObject
      ..activeSegments = activeSegments
      ..totalSegments = totalSegments
      ..color = color
      ..thickness = context.responsiveIconSize * 0.15
      ..gap = context.responsiveGapXS;
  }
}

/// Render object that handles layout and painting of segmented bar.
///
/// This render object:
/// - Calculates segment widths based on available space and gaps
/// - Paints active segments with full opacity, inactive with reduced opacity
/// - Handles hit testing for potential interaction
class _SegmentedCounterBarRenderObject extends RenderBox {
  _SegmentedCounterBarRenderObject({
    required int activeSegments,
    required int totalSegments,
    required Color color,
    required double thickness,
    required double gap,
  })  : _activeSegments = activeSegments,
        _totalSegments = totalSegments,
        _color = color,
        _thickness = thickness,
        _gap = gap;

  int _activeSegments;
  int _totalSegments;
  Color _color;
  double _thickness;
  double _gap;

  set activeSegments(final int value) {
    if (_activeSegments == value) return;
    _activeSegments = value;
    // Only paint changes, layout stays the same
    markNeedsPaint();
  }

  set totalSegments(final int value) {
    if (_totalSegments == value) return;
    _totalSegments = value;
    // Segment count affects layout (width calculation)
    markNeedsLayout();
  }

  set color(final Color value) {
    if (_color == value) return;
    _color = value;
    // Color change only affects paint
    markNeedsPaint();
  }

  set thickness(final double value) {
    if (_thickness == value) return;
    _thickness = value;
    // Thickness affects height, so layout is needed
    markNeedsLayout();
  }

  set gap(final double value) {
    if (_gap == value) return;
    _gap = value;
    // Gap affects segment width calculation, so layout is needed
    markNeedsLayout();
  }

  @override
  void performLayout() {
    // Use available width if constrained, otherwise default to 240
    final double width = constraints.maxWidth.isFinite
        ? constraints.maxWidth
        : constraints.constrainWidth(240);

    // Height is determined by thickness
    size = Size(width, _thickness);
  }

  @override
  void paint(final PaintingContext context, final Offset offset) {
    // Guard against invalid state
    if (_totalSegments <= 0) return;

    final Canvas canvas = context.canvas;

    // Calculate segment width: total width minus gaps, divided by segments
    final double availableWidth = size.width - _gap * (_totalSegments - 1);
    final double segmentWidth = availableWidth / _totalSegments;

    // Create paint object once and reuse
    final Paint paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw each segment
    for (int i = 0; i < _totalSegments; i++) {
      final double dx = offset.dx + i * (segmentWidth + _gap);
      final RRect rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(dx, offset.dy, segmentWidth, _thickness),
        Radius.circular(_thickness / 2), // Fully rounded segments
      );

      // Active segments are opaque, inactive are semi-transparent
      paint.color = i < _activeSegments
          ? _color
          : _color.withOpacity(0.2);

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool hitTestSelf(final Offset position) {
    // Accept all hits within bounds (could be extended for segment-specific hits)
    return true;
  }

  @override
  bool get sizedByParent => false;

  @override
  double computeMinIntrinsicWidth(final double height) {
    // Minimum width: all segments at minimum size plus gaps
    return _totalSegments * 4 + _gap * (_totalSegments - 1);
  }

  @override
  double computeMaxIntrinsicWidth(final double height) {
    // Same as min for this simple layout
    return computeMinIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicHeight(final double width) {
    return _thickness;
  }

  @override
  double computeMaxIntrinsicHeight(final double width) {
    return _thickness;
  }
}
```

### Usage Example with Complete Architecture Flow

```dart
// Complete example showing data flow from Cubit to RenderObject
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Step 1: BlocSelector reads only 'count' from CounterState
          // This widget rebuilds ONLY when count changes, not on status/error changes
          BlocSelector<CounterCubit, CounterState, int>(
            selector: (state) => state.count,
            builder: (context, count) {
              // Step 2: Widget derives visual values from state
              // No business logic here - just data transformation for rendering
              final activeSegments = count.clamp(0, 20);

              // Step 3: Pass derived values to RenderObject widget
              // RenderObject receives pure visual data (activeSegments, color)
              return RepaintBoundary(
                child: SegmentedCounterBar(
                  activeSegments: activeSegments, // Derived from state
                  totalSegments: 20,             // Visual constant
                  color: Theme.of(context).colorScheme.primary, // Theme value
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// The RenderObject widget creates the render object
class SegmentedCounterBar extends LeafRenderObjectWidget {
  // ... (as shown in full example above)
}

// The RenderObject handles layout and painting
class _SegmentedCounterBarRenderObject extends RenderBox {
  // Receives: activeSegments, totalSegments, color
  // No access to: CounterRepository, CounterCubit, CounterState
  // Pure rendering logic based on visual parameters
}
```

### RenderObject Architecture Flow

1. **State Source**: `CounterCubit` emits `CounterState` with `count` property
2. **Selective Reading**: `BlocSelector` extracts only `count`, ignoring other state fields
3. **Data Derivation**: Widget calculates `activeSegments = count.clamp(0, 20)`
4. **Visual Parameters**: Widget passes visual-only data to `SegmentedCounterBar`
5. **Layout Calculation**: RenderObject's `performLayout()` calculates size from constraints
6. **Painting**: RenderObject's `paint()` draws segments based on visual parameters
7. **No Dependencies**: RenderObject has zero knowledge of repositories, cubits, or business logic

### RenderObject Key Points

- **Clean separation**: RenderObject receives only visual parameters; no business logic or data layer access
- **Layout control**: `performLayout()` calculates size based on constraints and segment count, giving full control over dimensions
- **Efficient updates**: Setters call `markNeedsLayout()` or `markNeedsPaint()` only when needed, preventing unnecessary work
- **Hit testing**: `hitTestSelf()` can be extended for segment-specific interactions (e.g., tap to set value)
- **Intrinsic dimensions**: Implement `compute*Intrinsic*` methods for proper layout in flex widgets (`Row`, `Column`, etc.)
- **Performance**: Wrap in `RepaintBoundary` when used in scrolling content to isolate repaints
- **Testability**: RenderObject can be tested with simple visual parameters without mocking state management

### Common RenderObject Patterns

1. **Layout vs Paint**: Only call `markNeedsLayout()` when size/position changes; use `markNeedsPaint()` for visual-only changes
2. **Constraint handling**: Always check `constraints.maxWidth.isFinite` and `constraints.maxHeight.isFinite` for unbounded cases
3. **Resource cleanup**: Override `dispose()` to clean up any cached objects (e.g., `TextPainter`, `Picture` objects)
4. **Hit testing**: Override `hitTestSelf()` for custom interaction areas, or `hitTestChildren()` for child hit testing

## Complete Usage Showcase

Here's a complete example showing both CustomPainter and RenderObject working together in a single page, demonstrating proper Clean Architecture integration:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

/// Example page showcasing CustomPainter and RenderObject usage
/// with proper Clean Architecture and BLoC integration.
class CounterVisualizationPage extends StatelessWidget {
  const CounterVisualizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter Visualization')),
      body: Padding(
        padding: context.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Example 1: CustomPainter - Progress Ring
            _buildProgressRing(context),

            SizedBox(height: context.responsiveGapL),

            // Example 2: RenderObject - Segmented Bar
            _buildSegmentedBar(context),

            SizedBox(height: context.responsiveGapL),

            // Example 3: Controls that update state
            _buildControls(context),
          ],
        ),
      ),
    );
  }

  /// CustomPainter example: Circular progress ring
  Widget _buildProgressRing(BuildContext context) {
    return BlocSelector<CounterCubit, CounterState, int>(
      selector: (state) => state.count,
      builder: (context, count) {
        // Derive visual value from state
        final progress = (count / 20.0).clamp(0.0, 1.0);

        return RepaintBoundary(
          child: Center(
            child: Column(
              children: [
                CustomPaint(
                  painter: CounterRingPainter(
                    progress: progress,
                    activeColor: Theme.of(context).colorScheme.primary,
                    trackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  size: Size.square(context.responsiveIconSize * 3),
                ),
                SizedBox(height: context.responsiveGapS),
                Text(
                  'Count: $count',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// RenderObject example: Segmented progress bar
  Widget _buildSegmentedBar(BuildContext context) {
    return BlocSelector<CounterCubit, CounterState, int>(
      selector: (state) => state.count,
      builder: (context, count) {
        // Derive visual value from state
        final activeSegments = count.clamp(0, 20);

        return RepaintBoundary(
          child: SegmentedCounterBar(
            activeSegments: activeSegments,
            totalSegments: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }

  /// Controls that update state through Cubit
  Widget _buildControls(BuildContext context) {
    return BlocBuilder<CounterCubit, CounterState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PlatformAdaptive.filledButton(
              context: context,
              onPressed: () => context.read<CounterCubit>().increment(),
              child: const Text('Increment'),
            ),
            SizedBox(width: context.responsiveGapM),
            PlatformAdaptive.filledButton(
              context: context,
              onPressed: state.count > 0
                  ? () => context.read<CounterCubit>().decrement()
                  : null,
              child: const Text('Decrement'),
            ),
          ],
        );
      },
    );
  }
}
```

### What This Example Demonstrates

1. **Multiple rendering approaches**: Shows both CustomPainter and RenderObject in the same page
2. **Selective state reading**: Uses `BlocSelector` to read only `count`, preventing rebuilds on status/error changes
3. **Data derivation**: Widgets derive visual values (`progress`, `activeSegments`) from state
4. **Performance optimization**: Both rendering components wrapped in `RepaintBoundary`
5. **Clean separation**: Rendering code has no knowledge of repositories or business logic
6. **Responsive design**: Uses responsive extensions for consistent sizing
7. **State updates**: Controls update state through Cubit, triggering automatic visual updates

## Testing Strategies

### CustomPainter Testing

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/counter/presentation/widgets/counter_ring.dart';

void main() {
  group('CounterRingPainter', () {
    testWidgets('paints correct progress for given count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CounterRing(maxCount: 20),
          ),
        ),
      );

      // Verify widget is rendered
      expect(find.byType(CounterRing), findsOneWidget);

      // Test with golden file for visual regression
      await expectLater(
        find.byType(CounterRing),
        matchesGoldenFile('counter_ring_progress.png'),
      );
    });

    testWidgets('shouldRepaint returns true when progress changes', (tester) async {
      final painter1 = CounterRingPainter(
        progress: 0.5,
        activeColor: Colors.blue,
        trackColor: Colors.grey,
      );

      final painter2 = CounterRingPainter(
        progress: 0.6, // Different progress
        activeColor: Colors.blue,
        trackColor: Colors.grey,
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });
  });
}
```

### RenderObject Testing

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/counter/presentation/widgets/segmented_counter_bar.dart';

void main() {
  group('SegmentedCounterBar', () {
    testWidgets('calculates correct size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: SegmentedCounterBar(
                activeSegments: 5,
                totalSegments: 10,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      final RenderBox renderBox = tester.renderObject(
        find.byType(SegmentedCounterBar),
      );

      expect(renderBox.size.width, 200);
      expect(renderBox.size.height, greaterThan(0));
    });

    testWidgets('handles zero segments gracefully', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SegmentedCounterBar(
              activeSegments: 0,
              totalSegments: 0, // Edge case
              color: Colors.blue,
            ),
          ),
        ),
      );

      // Should not throw, should render empty
      expect(find.byType(SegmentedCounterBar), findsOneWidget);
    });

    testWidgets('hit test works correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SegmentedCounterBar(
              activeSegments: 3,
              totalSegments: 5,
              color: Colors.blue,
            ),
          ),
        ),
      );

      final RenderBox renderBox = tester.renderObject(
        find.byType(SegmentedCounterBar),
      );

      // Test hit at center
      final bool hit = renderBox.hitTestSelf(
        Offset(renderBox.size.width / 2, renderBox.size.height / 2),
      );

      expect(hit, isTrue);
    });
  });
}
```

### Testing Best Practices

- **Test painters/render objects in isolation**: Since they receive only visual data, test them with simple values without mocking repositories or cubits
- **Test widget integration**: Use `BlocProvider` with a test cubit to verify the complete data flow
- **Deterministic inputs**: Always use fixed values (no random colors, timestamps, etc.) for reproducible tests
- **Golden tests**: Use `matchesGoldenFile` for visual regression testing; update with `flutter test --update-goldens`
- **Edge cases**: Test zero/null states, extreme values, and boundary conditions
- **Layout verification**: Use `tester.getSize()` and `tester.renderObject()` to verify layout calculations
- **Performance**: Test that `shouldRepaint` returns `false` when properties haven't changed
- **Architecture compliance**: Verify that painters/render objects don't access repositories or cubits directly
- **Coverage**: Run `./bin/checklist` after integrating to keep formatting, analysis, and coverage healthy

### Testing with Clean Architecture

```dart
// ✅ GOOD: Test painter with simple values (no dependencies)
test('CounterRingPainter paints correctly', () {
  final painter = CounterRingPainter(
    progress: 0.5,
    activeColor: Colors.blue,
    trackColor: Colors.grey,
  );

  // Test painting logic directly
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  painter.paint(canvas, const Size(100, 100));

  // Verify painting occurred
  expect(recorder.endRecording(), isNotNull);
});

// ✅ GOOD: Test widget integration with test cubit
testWidgets('CounterRing updates when cubit state changes', (tester) async {
  final cubit = CounterCubit(
    repository: MockCounterRepository(),
  );

  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider.value(
        value: cubit,
        child: const CounterRing(),
      ),
    ),
  );

  // Verify initial state
  expect(find.byType(CounterRing), findsOneWidget);

  // Update state through cubit
  await cubit.increment();
  await tester.pump();

  // Verify visual update (could use golden test here)
  expect(find.byType(CounterRing), findsOneWidget);

  await cubit.close();
});
```

## Performance Considerations

### Optimization Techniques

1. **RepaintBoundary isolation**: Wrap expensive painters in `RepaintBoundary` to prevent parent repaints

   ```dart
   RepaintBoundary(
     child: CustomPaint(painter: ExpensivePainter(...)),
   )
   ```

2. **BlocSelector precision**: Select only the data needed for painting

   ```dart
   BlocSelector<CounterCubit, CounterState, int>(
     selector: (state) => state.count, // Only count, not entire state
     builder: (context, count) => ...,
   )
   ```

3. **shouldRepaint optimization**: Always implement `shouldRepaint` to avoid unnecessary repaints

   ```dart
   @override
   bool shouldRepaint(CustomPainter oldDelegate) {
     if (oldDelegate is! MyPainter) return true;
     return oldDelegate.progress != progress; // Only repaint if changed
   }
   ```

4. **Paint object reuse**: Reuse `Paint` objects when properties don't change frequently

   ```dart
   final Paint _paint = Paint()..style = PaintingStyle.stroke;
   // Reuse _paint instead of creating new instances
   ```

5. **Path caching**: Cache complex `Path` objects for static shapes

   ```dart
   Path? _cachedPath;
   Path get path => _cachedPath ??= _buildPath();
   ```

6. **Layout optimization**: In RenderObject, only call `markNeedsLayout()` when size actually changes

   ```dart
   set value(int newValue) {
     if (_value == newValue) return; // Early return
     _value = newValue;
     markNeedsPaint(); // Not layout, if size doesn't change
   }
   ```

### Performance Profiling

Use Flutter DevTools to identify performance bottlenecks:

1. Enable performance overlay: `MaterialApp(showPerformanceOverlay: true)`
2. Use `PerformanceProfiler` widget (see `docs/CODE_QUALITY_ANALYSIS.md`)
3. Check repaint boundaries with "Show Repaint Rainbow" in DevTools
4. Monitor frame rendering times; target 16ms for 60fps

## Common Pitfalls and Anti-Patterns

### ❌ Don't: Access repositories directly from painters

```dart
// BAD: Painter accessing repository
class BadPainter extends CustomPainter {
  void paint(Canvas canvas, Size size) {
    final count = getIt<CounterRepository>().getCount(); // Violates architecture
  }
}
```

### ✅ Do: Pass data through widget tree

```dart
// GOOD: Data flows through widget tree
BlocSelector<CounterCubit, CounterState, int>(
  selector: (state) => state.count,
  builder: (context, count) => CustomPaint(
    painter: GoodPainter(count: count),
  ),
)
```

### ❌ Don't: Forget shouldRepaint

```dart
// BAD: Always repaints, even when unchanged
class BadPainter extends CustomPainter {
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true; // Always repaints!
}
```

### ✅ Do: Implement efficient shouldRepaint

```dart
// GOOD: Only repaints when needed
@override
bool shouldRepaint(CounterRingPainter oldDelegate) {
  return oldDelegate.progress != progress ||
         oldDelegate.activeColor != activeColor;
}
```

### ❌ Don't: Call markNeedsLayout for paint-only changes

```dart
// BAD: Unnecessary layout recalculation
set color(Color value) {
  _color = value;
  markNeedsLayout(); // Wrong! Color doesn't affect size
}
```

### ✅ Do: Use markNeedsPaint for visual-only changes

```dart
// GOOD: Only triggers repaint
set color(Color value) {
  if (_color == value) return;
  _color = value;
  markNeedsPaint(); // Correct! Only visual change
}
```

### ❌ Don't: Create Paint objects in paint() unnecessarily

```dart
// BAD: Allocates new Paint on every frame
void paint(Canvas canvas, Size size) {
  canvas.drawCircle(
    center,
    radius,
    Paint()..color = Colors.blue, // New object every frame
  );
}
```

### ✅ Do: Reuse Paint objects or create once

```dart
// GOOD: Reuse paint object
final Paint _paint = Paint()..color = Colors.blue;

void paint(Canvas canvas, Size size) {
  canvas.drawCircle(center, radius, _paint);
}
```

## Accessibility Considerations

Custom painters and render objects should support accessibility:

1. **Semantic labels**: Wrap in `Semantics` widget to provide screen reader information

   ```dart
   Semantics(
     label: 'Progress: ${(progress * 100).toInt()}%',
     child: CustomPaint(painter: ProgressPainter(progress: progress)),
   )
   ```

2. **Hit testing**: Ensure interactive custom render objects respond to touch events correctly

   ```dart
   @override
   bool hitTestSelf(Offset position) => true; // Or custom logic
   ```

3. **Focus management**: For interactive elements, implement focus handling

   ```dart
   Focus(
     child: CustomPaint(...),
     onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
   )
   ```

4. **Color contrast**: Ensure sufficient contrast for accessibility standards (WCAG AA: 4.5:1 for normal text)

## Real-World Examples in Codebase

The codebase includes production examples:

- **`WhiteboardPainter`** (`lib/features/example/presentation/widgets/whiteboard/whiteboard_painter.dart`): CustomPainter for stroke rendering with smooth bezier curves
- **`MarkdownRenderObject`** (`lib/features/example/presentation/widgets/markdown_editor/markdown_render_object.dart`): RenderObject for custom text layout with markdown syntax highlighting

Study these examples for patterns on:

- Efficient repaint logic
- Resource cleanup (`dispose()`)
- Constraint handling
- Text layout integration

## Quick Reference Checklist

### CustomPainter Checklist

- [ ] Implement `shouldRepaint()` to avoid unnecessary repaints
- [ ] Use `BlocSelector` to only rebuild when relevant state changes
- [ ] Wrap in `RepaintBoundary` for expensive paint operations
- [ ] Reuse `Paint` objects when properties don't change frequently
- [ ] Cache complex `Path` objects for static shapes
- [ ] Use responsive extensions (`context.responsiveIconSize`, etc.)
- [ ] Add widget/golden tests for visual regression
- [ ] Wrap in `Semantics` widget for accessibility

### RenderObject Checklist

- [ ] Implement `performLayout()` to calculate size from constraints
- [ ] Call `markNeedsLayout()` only when size/position changes
- [ ] Call `markNeedsPaint()` for visual-only changes
- [ ] Implement `hitTestSelf()` for custom interaction areas
- [ ] Override `compute*Intrinsic*` methods for flex layout support
- [ ] Handle unbounded constraints (`isFinite` checks)
- [ ] Clean up resources in `dispose()` (e.g., `TextPainter`, cached objects)
- [ ] Guard against edge cases (zero/null states, extreme values)
- [ ] Use `BlocSelector` to feed state changes
- [ ] Wrap in `RepaintBoundary` when used in scrolling content

### Common Methods Reference

#### CustomPainter

```dart
class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) { /* Draw here */ }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) { /* Return true if needs repaint */ }

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) => false; // Optional
}
```

#### RenderObject (RenderBox)

```dart
class MyRenderObject extends RenderBox {
  @override
  void performLayout() { /* Calculate size */ }

  @override
  void paint(PaintingContext context, Offset offset) { /* Draw here */ }

  @override
  bool hitTestSelf(Offset position) => true; // Or custom logic

  @override
  bool get sizedByParent => false; // Or true if size depends only on constraints

  @override
  double computeMinIntrinsicWidth(double height) { /* Return min width */ }

  @override
  void dispose() { /* Clean up resources */ }
}
```

## Summary

### When to Use Each

- **CustomPainter**: Use for custom drawing within standard widget layout. Simpler, but limited to painting. Best for charts, progress indicators, badges.
- **RenderObject**: Use for custom layout + painting. More complex, but provides full control. Best for custom layouts, advanced hit-testing, performance-critical rendering.

### Clean Architecture Integration

- **Data Flow**: Domain → Data → Presentation (Cubit) → Presentation (Widget) → Rendering (Painter/RenderObject)
- **Key Principle**: Rendering code receives only derived visual data; never accesses repositories or cubits directly
- **State Management**: Use `BlocSelector` to read only needed state fields, preventing unnecessary rebuilds
- **Separation**: Painters and render objects are pure rendering logic with zero business logic dependencies

### Performance Best Practices

- **RepaintBoundary**: Wrap expensive painters/widgets to isolate repaints
- **BlocSelector**: Select only the data needed for painting
- **shouldRepaint**: Always implement to avoid unnecessary repaints
- **markNeedsLayout vs markNeedsPaint**: Call the appropriate method based on what changed
- **Object reuse**: Reuse `Paint` and `Path` objects when possible

### Code Quality

- **Clean code**: Keep painters/render objects focused on rendering only
- **Testability**: Test with simple values, no need to mock repositories
- **Responsive**: Use responsive extensions for consistent sizing
- **Accessibility**: Wrap in `Semantics` widgets and ensure proper hit testing
- **Testing**: Write widget/golden tests with deterministic inputs, test edge cases

### Real-World Examples

Study the codebase examples:

- **`WhiteboardPainter`**: CustomPainter for stroke rendering
- **`MarkdownRenderObject`**: RenderObject for custom text layout

For more details, see the examples in the codebase and Flutter's official documentation on [CustomPainter](https://api.flutter.dev/flutter/rendering/CustomPainter-class.html) and [RenderObject](https://api.flutter.dev/flutter/rendering/RenderObject-class.html).
