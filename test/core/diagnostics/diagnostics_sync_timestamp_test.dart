import 'package:flutter_bloc_app/core/diagnostics/diagnostics_sync_timestamp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isPlausibleDiagnosticsSyncTime', () {
    test('accepts typical sync times', () {
      expect(isPlausibleDiagnosticsSyncTime(DateTime.utc(2020, 6, 15)), isTrue);
      expect(isPlausibleDiagnosticsSyncTime(DateTime(2015, 3, 1)), isTrue);
      // Mid-year UTC stays within [1970, 2100] in local time (avoids +14h rolling year).
      expect(
        isPlausibleDiagnosticsSyncTime(DateTime.utc(2099, 6, 15, 12)),
        isTrue,
      );
    });

    test('rejects far-future and pre-epoch local years', () {
      expect(isPlausibleDiagnosticsSyncTime(DateTime.utc(3000, 1, 1)), isFalse);
      expect(isPlausibleDiagnosticsSyncTime(DateTime.utc(1960, 1, 1)), isFalse);
    });
  });
}
