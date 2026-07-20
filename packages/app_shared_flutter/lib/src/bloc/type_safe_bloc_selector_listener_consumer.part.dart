part of 'type_safe_bloc_selector.dart';

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
  Widget buildWithChild(final BuildContext context, final Widget? child) =>
      BlocListener<C, S>(
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
    this.bloc,
    this.listener,
    this.listenWhen,
    this.buildWhen,
    super.key,
  });

  /// Builder function that receives the current state.
  final Widget Function(BuildContext context, S state) builder;

  /// Optional bloc instance. If omitted, looks up via [BlocProvider].
  final C? bloc;

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
    bloc: bloc,
    listener: listener ?? (_, final _) {},
    listenWhen: listenWhen,
    buildWhen: buildWhen,
    builder: builder,
  );
}
