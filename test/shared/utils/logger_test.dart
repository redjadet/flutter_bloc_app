import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    AppLogger.observer = null;
  });

  test('observer receives warning and error log entries', () {
    final List<AppLogEntry> entries = <AppLogEntry>[];
    AppLogger.observer = entries.add;

    AppLogger.warning('warning message');
    AppLogger.error('error message', StateError('boom'));

    expect(entries, hasLength(2));
    expect(entries.first.level, AppLogLevel.warning);
    expect(entries.first.message, 'warning message');
    expect(entries.last.level, AppLogLevel.error);
    expect(entries.last.message, 'error message');
    expect(entries.last.error, isA<StateError>());
  });
}
