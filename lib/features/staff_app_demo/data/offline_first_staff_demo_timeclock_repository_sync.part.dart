part of 'offline_first_staff_demo_timeclock_repository.dart';

extension _OfflineFirstStaffDemoTimeclockRepositorySync
    on OfflineFirstStaffDemoTimeclockRepository {
  Future<StaffDemoClockResult> clockOutImpl() async {
    final userId = _currentUserId();
    if (userId == null || userId.isEmpty) {
      throw StateError('Not signed in');
    }

    final open = await _localRepository.loadOpenEntry(userId: userId);
    if (open == null) {
      throw StateError('No open time entry');
    }

    final nowUtc = DateTime.now().toUtc();
    final location = await _locationService.captureCurrentLocation();
    final accuracyMeters = location?.accuracyMeters;
    final bool locationInsufficient =
        accuracyMeters == null ||
        accuracyMeters > StaffDemoPunchEvaluator.maxTrustedAccuracyMeters;

    final payload = <String, dynamic>{
      'action': 'clock_out',
      'entryId': open.entryId,
      'userId': userId,
      'clockOutAtClientMs': nowUtc.millisecondsSinceEpoch,
      'clockOutLocation': location == null
          ? null
          : <String, dynamic>{'lat': location.lat, 'lng': location.lng},
      'clockOutAccuracyMeters': accuracyMeters,
      'flags': <String, dynamic>{
        'locationInsufficient': locationInsufficient,
      },
    };

    await _pendingSyncRepository.enqueue(
      SyncOperation.create(
        entityType: entityType,
        payload: payload,
        idempotencyKey:
            '${OfflineFirstStaffDemoTimeclockRepository.staffDemoTimeEntryEntity}_clock_out_${open.entryId}',
      ),
    );

    await _localRepository.clearOpenEntry(userId: userId);

    return StaffDemoClockResult(
      entryId: open.entryId,
      flags: StaffDemoTimeEntryFlags(
        outsideGeofence: false,
        earlyClockIn: false,
        locationInsufficient: locationInsufficient,
        missingScheduledShift: false,
        duplicatePunchAttempt: false,
        deviceClockSkewSuspected: false,
      ),
      shiftId: open.shiftId,
      siteId: open.siteId,
      distanceMeters: null,
      radiusMeters: null,
    );
  }

  Future<void> pullRemoteImpl() async {
    // v1: timeclock writes are push-based via pending sync ops; pull is a no-op.
  }

  Future<void> processOperationImpl(final SyncOperation operation) async {
    final payload = operation.payload;
    final String? opUserId = payload['userId'] as String?;
    if (opUserId == null || opUserId.isEmpty) {
      return;
    }
    final String? currentUserId = _currentUserId();
    if (currentUserId == null || opUserId != currentUserId) {
      throw const SyncOperationDeferredException(
        'staff_demo_timeclock user scope mismatch',
      );
    }

    final action = payload['action'];
    final entryId = payload['entryId'];
    if (action is! String || entryId is! String || entryId.isEmpty) {
      return;
    }

    final docRef = _firestore.collection('staffDemoTimeEntries').doc(entryId);

    if (action == 'clock_in') {
      await docRef.set(<String, dynamic>{
        ...payload,
        'clockInAtServer': FieldValue.serverTimestamp(),
        'entryState': 'open',
      }, SetOptions(merge: true));
      return;
    }

    if (action == 'clock_out') {
      await docRef.set(<String, dynamic>{
        ...payload,
        'clockOutAtServer': FieldValue.serverTimestamp(),
        'entryState': 'closed',
      }, SetOptions(merge: true));
      return;
    }

    AppLogger.info(
      'OfflineFirstStaffDemoTimeclockRepository.processOperation: unknown action=$action',
    );
  }
}
