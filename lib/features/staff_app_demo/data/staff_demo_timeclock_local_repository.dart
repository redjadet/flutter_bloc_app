import 'package:flutter_bloc_app/shared/storage/hive_repository_base.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';

class StaffDemoOpenEntrySnapshot {
  const StaffDemoOpenEntrySnapshot({
    required this.entryId,
    required this.clockInAtUtc,
    required this.shiftId,
    required this.siteId,
    required this.payload,
  });

  final String entryId;
  final DateTime clockInAtUtc;
  final String? shiftId;
  final String? siteId;

  /// Original punch evidence (lat/lng/accuracy/etc). This is intentionally
  /// opaque so we can preserve evidence without tightly coupling the schema.
  final Map<String, dynamic> payload;
}

class StaffDemoTimeclockLocalRepository extends HiveRepositoryBase {
  StaffDemoTimeclockLocalRepository({required super.hiveService});

  static const String _boxName = 'staff_demo_timeclock_local';

  @override
  String get boxName => _boxName;

  String _openEntryKey(final String userId) => 'openEntry:$userId';

  Future<StaffDemoOpenEntrySnapshot?> loadOpenEntry({
    required final String userId,
  }) => StorageGuard.run<StaffDemoOpenEntrySnapshot?>(
    logContext: 'StaffDemoTimeclockLocalRepository.loadOpenEntry',
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
      final payloadRaw = map['payload'];
      final payload = payloadRaw is Map
          ? Map<String, dynamic>.from(payloadRaw)
          : <String, dynamic>{};
      return StaffDemoOpenEntrySnapshot(
        entryId: entryId,
        clockInAtUtc: DateTime.fromMillisecondsSinceEpoch(
          clockInAtMs,
          isUtc: true,
        ),
        shiftId: shiftId,
        siteId: siteId,
        payload: payload,
      );
    },
    fallback: () => null,
  );

  Future<void> saveOpenEntry({
    required final String userId,
    required final StaffDemoOpenEntrySnapshot snapshot,
  }) async {
    await StorageGuard.run<void>(
      logContext: 'StaffDemoTimeclockLocalRepository.saveOpenEntry',
      action: () async {
        final box = await getBox();
        await box.put(_openEntryKey(userId), <String, dynamic>{
          'entryId': snapshot.entryId,
          'clockInAtMs': snapshot.clockInAtUtc.millisecondsSinceEpoch,
          'shiftId': snapshot.shiftId,
          'siteId': snapshot.siteId,
          'payload': snapshot.payload,
        });
      },
    );
  }

  Future<void> clearOpenEntry({required final String userId}) async {
    await StorageGuard.run<void>(
      logContext: 'StaffDemoTimeclockLocalRepository.clearOpenEntry',
      action: () async {
        final box = await getBox();
        await box.delete(_openEntryKey(userId));
      },
    );
  }
}
