import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Captures layout-contract failures during a widget test.
///
/// Typical strings: `RenderFlex overflowed`, `overflowed by`. These mean a
/// child reported a size larger than the constraints its parent passed down.
/// See `docs/architecture/flutter_layout_constraints.md`.
({List<FlutterErrorDetails> errors, void Function() dispose})
startLayoutOverflowCapture() {
  final List<FlutterErrorDetails> errors = <FlutterErrorDetails>[];
  final FlutterExceptionHandler? originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    errors.add(details);
    originalOnError?.call(details);
  };
  return (
    errors: errors,
    dispose: () {
      FlutterError.onError = originalOnError;
    },
  );
}

void expectNoRenderOverflows(List<FlutterErrorDetails> errors) {
  final Iterable<FlutterErrorDetails> overflows = errors.where(
    (FlutterErrorDetails e) => e.exceptionAsString().contains('overflow'),
  );
  expect(
    overflows,
    isEmpty,
    reason: overflows.map((e) => e.exceptionAsString()).join('\n---\n'),
  );
}
