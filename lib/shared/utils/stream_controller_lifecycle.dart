import 'dart:async';

/// Safe emission and lifecycle for `StreamController`.
///
/// **When to use:**
/// - **Mixin `StreamControllerLifecycle`:** Use when a class owns a single
///   stream controller and manages its lifecycle (create/dispose). Call
///   `safeEmit`/`safeEmitError` and `disposeController` in close/dispose.
/// - **Static `StreamControllerSafeEmit`:** Use when you have a controller
///   reference that may be closed elsewhere (e.g. multiple controllers, or
///   controller passed in). Call `StreamControllerSafeEmit.safeAdd` or
///   `StreamControllerSafeEmit.safeAddError` before adding to the stream.
///
/// Both patterns avoid calling `add` or `addError` on a closed controller,
/// which would throw [StateError].
abstract final class StreamControllerSafeEmit {
  StreamControllerSafeEmit._();

  /// Adds [value] to [controller] only if it is not null and not closed.
  static void safeAdd<T>(
    final StreamController<T>? controller,
    final T value,
  ) {
    if (controller != null && !controller.isClosed) {
      controller.add(value);
    }
  }

  /// Adds [error] to [controller] only if it is not null and not closed.
  static void safeAddError(
    final StreamController<dynamic>? controller,
    final Object error, [
    final StackTrace? stackTrace,
  ]) {
    if (controller != null && !controller.isClosed) {
      controller.addError(error, stackTrace);
    }
  }
}

/// Mixin for managing StreamController lifecycle safely.
///
/// This mixin provides standardized methods for safely managing StreamController
/// instances, including safe value emission and cleanup. It reduces code
/// duplication across classes that manage streams.
///
/// For one-off emission when you hold a controller reference (and do not use
/// this mixin), use `StreamControllerSafeEmit.safeAdd` / `safeAddError`.
///
/// Example:
/// ```dart
/// class MyService with StreamControllerLifecycle<String> {
///   MyService() {
///     _controller = StreamController<String>.broadcast();
///   }
///
///   void updateValue(String value) {
///     safeEmit(value);
///   }
///
///   @override
///   Future<void> dispose() async {
///     await disposeController();
///     super.dispose();
///   }
/// }
/// ```
mixin StreamControllerLifecycle<T> {
  /// The stream controller managed by this mixin.
  ///
  /// Classes using this mixin should call [disposeController] in their
  /// dispose/close methods to properly clean up the controller.
  StreamController<T>? get controller => _controller;
  StreamController<T>? _controller;

  /// Safely emits a value to the stream controller.
  ///
  /// Checks if the controller exists and is not closed before adding the value.
  /// This prevents errors when trying to emit to a closed controller.
  ///
  /// Note: The controller should be properly disposed using [disposeController]
  /// when no longer needed to avoid resource leaks.
  void safeEmit(final T value) {
    final StreamController<T>? controller = _controller;
    if (controller != null && !controller.isClosed) {
      controller.add(value);
    }
  }

  /// Safely emits an error to the stream controller.
  ///
  /// Checks if the controller exists and is not closed before adding the error.
  void safeEmitError(final Object error, [final StackTrace? stackTrace]) {
    final StreamController<T>? controller = _controller;
    if (controller != null && !controller.isClosed) {
      controller.addError(error, stackTrace);
    }
  }

  /// Disposes of the stream controller.
  ///
  /// Closes the controller and nullifies the reference. Safe to call multiple times.
  Future<void> disposeController() async {
    final StreamController<T>? controller = _controller;
    _controller = null;
    if (controller != null && !controller.isClosed) {
      await controller.close();
    }
  }

  /// Creates a new broadcast stream controller.
  ///
  /// If a controller already exists, it will be disposed first.
  /// Optionally accepts onListen and onCancel callbacks.
  Future<void> createController({
    final void Function()? onListen,
    final Future<void> Function()? onCancel,
  }) async {
    await disposeController();
    _controller = StreamController<T>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
    );
  }
}
