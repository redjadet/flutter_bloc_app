import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Captures [FlutterError] details during a widget test (e.g. RenderFlex overflow).
({List<FlutterErrorDetails> errors, void Function() dispose})
startLayoutOverflowCapture() {
  final List<FlutterErrorDetails> errors = <FlutterErrorDetails>[];
  final FlutterExceptionHandler? originalOnError = FlutterError.onError;
  FlutterError.onError = (final FlutterErrorDetails details) {
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

void expectNoRenderOverflows(final List<FlutterErrorDetails> errors) {
  final Iterable<FlutterErrorDetails> overflows = errors.where(
    (final FlutterErrorDetails e) => e.exceptionAsString().contains('overflow'),
  );
  expect(
    overflows,
    isEmpty,
    reason: overflows.map((e) => e.exceptionAsString()).join('\n---\n'),
  );
}
