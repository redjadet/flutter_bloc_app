import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_time_entry_flags.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_time_entry_summary.dart';

class FirestoreStaffDemoTimeEntriesRepository {
  FirestoreStaffDemoTimeEntriesRepository({
    required final FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Future<List<StaffDemoTimeEntrySummary>> fetchRecent({
    final int limit = 20,
  }) async {
    final snap = await _firestore
        .collection('staffDemoTimeEntries')
        .orderBy('clockInAtClientMs', descending: true)
        .limit(limit)
        .get();

    final out = <StaffDemoTimeEntrySummary>[];
    for (final doc in snap.docs) {
      final data = doc.data();
      final userId = data['userId'];
      final entryState = data['entryState'];
      if (userId is! String || userId.isEmpty) continue;
      if (entryState is! String || entryState.isEmpty) continue;
      final flagsRaw = data['flags'];
      final flagsMap = flagsRaw is Map
          ? Map<String, dynamic>.from(flagsRaw)
          : <String, dynamic>{};
      final flags = StaffDemoTimeEntryFlags(
        outsideGeofence: (flagsMap['outsideGeofence'] as bool?) ?? false,
        earlyClockIn: (flagsMap['earlyClockIn'] as bool?) ?? false,
        locationInsufficient:
            (flagsMap['locationInsufficient'] as bool?) ?? false,
        missingScheduledShift:
            (flagsMap['missingScheduledShift'] as bool?) ?? false,
        duplicatePunchAttempt:
            (flagsMap['duplicatePunchAttempt'] as bool?) ?? false,
        deviceClockSkewSuspected:
            (flagsMap['deviceClockSkewSuspected'] as bool?) ?? false,
      );
      out.add(
        StaffDemoTimeEntrySummary(
          entryId: doc.id,
          userId: userId,
          entryState: entryState,
          flags: flags,
          clockInAtClientMs: data['clockInAtClientMs'] as int?,
          clockOutAtClientMs: data['clockOutAtClientMs'] as int?,
        ),
      );
    }
    return out;
  }
}
