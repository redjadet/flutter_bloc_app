import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_open_entry_snapshot.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_timeclock_local_store.dart';
import 'package:storage/storage.dart';

class HiveStaffDemoTimeclockLocalStore extends HiveRepositoryBase
    implements StaffDemoTimeclockLocalStore {
  HiveStaffDemoTimeclockLocalStore({required super.hiveService});

  static const String _boxName = 'staff_demo_timeclock_local';

  @override
  String get boxName => _boxName;

  String _openEntryKey(String userId) => 'openEntry:$userId';

  @override
  Future<StaffDemoOpenEntrySnapshot?> loadOpenEntry({
    required String userId,
  }) => StorageGuard.run<StaffDemoOpenEntrySnapshot?>(
    logContext: 'HiveStaffDemoTimeclockLocalStore.loadOpenEntry',
    action: () async {
      final box = await getBox();
      final dynamic raw = box.get(_openEntryKey(userId));
      if (raw is! Map) return null;
      final map = Map<String, dynamic>.from(raw);
      final entryId = map['entryId'];
      final clockInAtMs = map['clockInAtMs'];
      if (entryId is! String || entryId.isEmpty) return null;
      if (clockInAtMs is! int) return null;
      final shiftId = map['shiftId'] as String?;
      final siteId = map['siteId'] as String?;
      return StaffDemoOpenEntrySnapshot(
        entryId: entryId,
        clockInAtUtc: DateTime.fromMillisecondsSinceEpoch(
          clockInAtMs,
          isUtc: true,
        ),
        shiftId: shiftId,
        siteId: siteId,
      );
    },
    fallback: () => null,
  );

  @override
  Future<void> saveOpenEntry({
    required String userId,
    required StaffDemoOpenEntrySnapshot snapshot,
  }) async {
    await StorageGuard.run<void>(
      logContext: 'HiveStaffDemoTimeclockLocalStore.saveOpenEntry',
      action: () async {
        final box = await getBox();
        await box.put(_openEntryKey(userId), <String, dynamic>{
          'entryId': snapshot.entryId,
          'clockInAtMs': snapshot.clockInAtUtc.millisecondsSinceEpoch,
          'shiftId': snapshot.shiftId,
          'siteId': snapshot.siteId,
        });
      },
    );
  }

  @override
  Future<void> clearOpenEntry({required String userId}) async {
    await StorageGuard.run<void>(
      logContext: 'HiveStaffDemoTimeclockLocalStore.clearOpenEntry',
      action: () async {
        final box = await getBox();
        await box.delete(_openEntryKey(userId));
      },
    );
  }
}
