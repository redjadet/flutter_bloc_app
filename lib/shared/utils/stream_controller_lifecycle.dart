import 'dart:async';

/// Mixin for managing StreamController lifecycle safely.
///
/// This mixin provides standardized methods for safely managing StreamController
/// instances, including safe value emission and cleanup. It reduces code
/// duplication across classes that manage streams.
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
  // ignore: close_sinks - Controller is disposed via disposeController() method
  StreamController<T>? _controller;

  /// Safely emits a value to the stream controller.
  ///
  /// Checks if the controller exists and is not closed before adding the value.
  /// This prevents errors when trying to emit to a closed controller.
  ///
  /// Note: The controller should be properly disposed using [disposeController]
  /// when no longer needed to avoid resource leaks.
  void safeEmit(T value) {
    final StreamController<T>? controller = _controller;
    if (controller != null && !controller.isClosed) {
      controller.add(value);
    }
  }

  /// Safely emits an error to the stream controller.
  ///
  /// Checks if the controller exists and is not closed before adding the error.
  void safeEmitError(Object error, [StackTrace? stackTrace]) {
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
    void Function()? onListen,
    Future<void> Function()? onCancel,
  }) async {
    await disposeController();
    _controller = StreamController<T>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
    );
  }
}
