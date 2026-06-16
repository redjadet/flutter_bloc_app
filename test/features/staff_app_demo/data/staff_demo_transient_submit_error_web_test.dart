import 'dart:async';

import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_transient_submit_error_web.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_event_proof_submit_exception.dart';
import 'package:flutter_test/flutter_test.dart';

class ClientException implements Exception {
  ClientException(this.message);

  final String message;
}

void main() {
  group('isStaffDemoTransientNetworkError (web)', () {
    test('returns true for TimeoutException', () {
      expect(
        isStaffDemoTransientNetworkError(TimeoutException('timed out')),
        isTrue,
      );
    });

    test('returns true when runtimeType is ClientException', () {
      expect(
        isStaffDemoTransientNetworkError(ClientException('connection failed')),
        isTrue,
      );
    });

    test('returns false for missing proof file errors', () {
      expect(
        isStaffDemoTransientNetworkError(
          StaffDemoProofFileMissingException('Photo file missing: /tmp/a.jpg'),
        ),
        isFalse,
      );
    });
  });
}
