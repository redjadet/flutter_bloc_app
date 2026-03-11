import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SyncStatusX', () {
    test('exposes semantic helpers for each enum value', () {
      expect(SyncStatus.idle.isIdle, isTrue);
      expect(SyncStatus.idle.isSyncing, isFalse);
      expect(SyncStatus.idle.isDegraded, isFalse);

      expect(SyncStatus.syncing.isIdle, isFalse);
      expect(SyncStatus.syncing.isSyncing, isTrue);
      expect(SyncStatus.syncing.isDegraded, isFalse);

      expect(SyncStatus.degraded.isIdle, isFalse);
      expect(SyncStatus.degraded.isSyncing, isFalse);
      expect(SyncStatus.degraded.isDegraded, isTrue);
    });
  });
}
