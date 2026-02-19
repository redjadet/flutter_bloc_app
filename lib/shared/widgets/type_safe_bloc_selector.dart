import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// provider is transitive via flutter_bloc; SingleChildStatelessWidget required for MultiBlocListener
// ignore: depend_on_referenced_packages
import 'package:provider/single_child_widget.dart';

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
    super.key,
  });

  /// Function that selects a value of type [T] from state [S].
  ///
  /// This function should return a value that can be compared for equality.
  /// The widget will only rebuild when the returned value changes.
  final T Function(S state) selector;

  /// Builder function that receives the selected value.
  ///
  /// This function is called whenever the selected value changes.
  final Widget Function(BuildContext context, T value) builder;

  @override
  Widget build(final BuildContext context) => BlocSelector<C, S, T>(
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
    this.buildWhen,
    super.key,
  });

  /// Builder function that receives the current state.
  ///
  /// This function is called whenever the state changes (unless [buildWhen] returns false).
  final Widget Function(BuildContext context, S state) builder;

  /// Optional function to determine whether to rebuild.
  ///
  /// If provided, the builder will only be called when this function returns true.
  final bool Function(S previous, S current)? buildWhen;

  @override
  Widget build(final BuildContext context) => BlocBuilder<C, S>(
    buildWhen: buildWhen,
    builder: builder,
  );
}

/// A type-safe wrapper around `BlocListener` that provides compile-time safety.
///
/// This widget ensures that:
/// - Generic types are checked at compile time
/// - Listener callbacks receive strongly-typed state
///
/// Compatible with [MultiBlocListener] (extends [SingleChildWidget]).
///
/// **Usage Example:**
/// ```dart
/// TypeSafeBlocListener<CounterCubit, CounterState>(
///   listenWhen: (previous, current) => previous.count != current.count,
///   listener: (context, state) {
///     if (state.hasError) {
///       ScaffoldMessenger.of(context).showSnackBar(
///         SnackBar(content: Text(state.error)),
///       );
///     }
///   },
///   child: MyChildWidget(),
/// )
/// ```
///
/// **In MultiBlocListener (omit child):**
/// ```dart
/// MultiBlocListener(
///   listeners: [
///     TypeSafeBlocListener<CounterCubit, CounterState>(...),
///   ],
///   child: MyChildWidget(),
/// )
/// ```
class TypeSafeBlocListener<C extends StateStreamableSource<S>, S>
    extends SingleChildStatelessWidget {
  /// Creates a type-safe bloc listener.
  ///
  /// The [listener] function is called for side effects (e.g., navigation,
  /// showing dialogs) whenever the state changes.
  ///
  /// When used in [MultiBlocListener], omit [child]; the child is injected.
  const TypeSafeBlocListener({
    required this.listener,
    this.bloc,
    this.listenWhen,
    super.key,
    super.child,
  });

  /// Listener function called when state changes (unless [listenWhen] returns false).
  final BlocWidgetListener<S> listener;

  /// Optional bloc instance. If omitted, looks up via [BlocProvider].
  final C? bloc;

  /// Optional function to determine whether to call the listener.
  final bool Function(S previous, S current)? listenWhen;

  @override
  Widget buildWithChild(
    final BuildContext context,
    final Widget? child,
  ) => BlocListener<C, S>(
    bloc: bloc,
    listenWhen: listenWhen,
    listener: listener,
    child: child,
  );
}

/// A type-safe wrapper around `BlocConsumer` that provides compile-time safety.
///
/// This widget combines `BlocBuilder` and `BlocListener` with compile-time type safety.
///
/// **Usage Example:**
/// ```dart
/// TypeSafeBlocConsumer<CounterCubit, CounterState>(
///   listener: (context, state) {
///     if (state.hasError) {
///       ScaffoldMessenger.of(context).showSnackBar(
///         SnackBar(content: Text(state.error)),
///       );
///     }
///   },
///   builder: (context, state) => Text('Count: ${state.count}'),
/// )
/// ```
class TypeSafeBlocConsumer<C extends StateStreamableSource<S>, S>
    extends StatelessWidget {
  /// Creates a type-safe bloc consumer.
  ///
  /// The [listener] function is called for side effects (e.g., navigation, showing dialogs).
  /// The [builder] function builds the widget tree.
  const TypeSafeBlocConsumer({
    required this.builder,
    this.listener,
    this.listenWhen,
    this.buildWhen,
    super.key,
  });

  /// Builder function that receives the current state.
  final Widget Function(BuildContext context, S state) builder;

  /// Optional listener function for side effects.
  ///
  /// This function is called whenever the state changes (unless [listenWhen] returns false).
  final BlocWidgetListener<S>? listener;

  /// Optional function to determine whether to call the listener.
  final bool Function(S previous, S current)? listenWhen;

  /// Optional function to determine whether to rebuild.
  final bool Function(S previous, S current)? buildWhen;

  @override
  Widget build(final BuildContext context) => BlocConsumer<C, S>(
    listener: listener ?? (_, final _) {},
    listenWhen: listenWhen,
    buildWhen: buildWhen,
    builder: builder,
  );
}
