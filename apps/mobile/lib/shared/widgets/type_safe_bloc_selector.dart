import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';

part 'type_safe_bloc_selector_listener_consumer.part.dart';

/// A type-safe wrapper around `BlocSelector` that provides compile-time safety.
///
/// This widget ensures that:
/// - Generic types are checked at compile time
/// - State selectors are type-safe
/// - Only the selected state slice triggers rebuilds
///
/// **Usage Example:**
/// ```dart
/// TypeSafeBlocSelector<CounterCubit, CounterState, int>(
///   selector: (state) => state.count,
///   builder: (context, count) => Text('Count: $count'),
/// )
/// ```
class TypeSafeBlocSelector<C extends StateStreamableSource<S>, S, T>
    extends StatelessWidget {
  /// Creates a type-safe bloc selector.
  ///
  /// The [selector] function extracts a value of type [T] from the state [S].
  /// The [builder] function is called with the selected value and only rebuilds
  /// when the selected value changes.
  const TypeSafeBlocSelector({
    required this.selector,
    required this.builder,
    this.bloc,
    super.key,
  });

  /// Function that selects a value of type [T] from state [S].
  ///
  /// This function should return a value that can be compared for equality.
  /// The widget will only rebuild when the returned value changes.
  final T Function(S state) selector;

  /// Optional bloc instance. If omitted, looks up via [BlocProvider].
  final C? bloc;

  /// Builder function that receives the selected value.
  ///
  /// This function is called whenever the selected value changes.
  final Widget Function(BuildContext context, T value) builder;

  @override
  Widget build(final BuildContext context) => BlocSelector<C, S, T>(
    bloc: bloc,
    selector: selector,
    builder: builder,
  );
}

/// A type-safe wrapper around `BlocBuilder` that provides compile-time safety.
///
/// This widget ensures that:
/// - Generic types are checked at compile time
/// - State access is type-safe
///
/// **Usage Example:**
/// ```dart
/// TypeSafeBlocBuilder<CounterCubit, CounterState>(
///   builder: (context, state) => Text('Count: ${state.count}'),
/// )
/// ```
class TypeSafeBlocBuilder<C extends StateStreamableSource<S>, S>
    extends StatelessWidget {
  /// Creates a type-safe bloc builder.
  ///
  /// The [builder] function is called whenever the state changes.
  const TypeSafeBlocBuilder({
    required this.builder,
    this.bloc,
    this.buildWhen,
    super.key,
  });

  /// Builder function that receives the current state.
  ///
  /// This function is called whenever the state changes unless
  /// [buildWhen] returns false.
  final Widget Function(BuildContext context, S state) builder;

  /// Optional bloc instance. If omitted, looks up via [BlocProvider].
  final C? bloc;

  /// Optional function to determine whether to rebuild.
  ///
  /// If provided, the builder will only be called when this function returns true.
  final bool Function(S previous, S current)? buildWhen;

  @override
  Widget build(final BuildContext context) => BlocBuilder<C, S>(
    bloc: bloc,
    buildWhen: buildWhen,
    builder: builder,
  );
}
