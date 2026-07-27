import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/app/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_shared_flutter/app_shared_flutter.dart';

void main() {
  tearDown(() {
    FirebaseBootstrapService.resetCrashlyticsRecordingForTest();
    FlutterError.onError = FlutterError.presentError;
  });

  test('Crashlytics recordCrash receives sanitized exception text', () async {
    Object? recordedException;
    StackTrace? recordedStack;
    String? recordedReason;
    var recordedFatal = false;

    FirebaseBootstrapService.recordCrash =
        (
          final exception,
          final stack, {
          required final bool fatal,
          required final String reason,
        }) async {
          recordedException = exception;
          recordedStack = stack;
          recordedFatal = fatal;
          recordedReason = reason;
        };

    final previous = FlutterError.onError;
    FirebaseBootstrapService.registerCrashlyticsHandlers();

    final stack = StackTrace.current;
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: StateError('token=supersecret'),
        stack: stack,
      ),
    );

    await Future<void>.delayed(Duration.zero);

    expect(recordedException, isA<String>());
    expect(recordedException.toString(), isNot(contains('supersecret')));
    expect(recordedException.toString(), contains(LogRedaction.redacted));
    expect(recordedStack, same(stack));
    expect(recordedFatal, isTrue);
    expect(recordedReason, 'flutter_fatal');

    FlutterError.onError = previous;
  });
}
