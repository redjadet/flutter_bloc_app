import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/app/bootstrap/firebase_crashlytics_bootstrap.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    FirebaseCrashlyticsBootstrap.resetRecordingForTest();
    FlutterError.onError = FlutterError.presentError;
  });

  test('metadataKeys returns only allowlisted keys', () {
    final keys = FirebaseCrashlyticsBootstrap.metadataKeys(
      flavorName: 'dev',
      appVersion: '9.9.9',
      firebaseReady: true,
    );
    expect(keys.keys.toList(), <String>[
      'flavor',
      'app_version',
      'firebase_ready',
    ]);
    expect(keys['flavor'], 'dev');
    expect(keys['app_version'], '9.9.9');
    expect(keys['firebase_ready'], 'true');
  });

  test('registerHandlers writes metadata then sanitizes fatals', () async {
    final Map<String, Object> written = <String, Object>{};
    Object? recordedException;
    StackTrace? recordedStack;
    String? recordedReason;
    var recordedFatal = false;

    FirebaseCrashlyticsBootstrap.setCustomKey = (final key, final value) {
      written[key] = value;
    };
    FirebaseCrashlyticsBootstrap.recordCrash =
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
    FirebaseCrashlyticsBootstrap.registerHandlers();

    expect(written.keys.toSet(), <String>{
      'flavor',
      'app_version',
      'firebase_ready',
    });

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
