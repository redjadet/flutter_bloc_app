import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_location_service.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_timeclock_local_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_punch_evaluator.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_shift.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_shift_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_time_entry_flags.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_timeclock_repository.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:geolocator/geolocator.dart';

class OfflineFirstStaffDemoTimeclockRepository
    implements StaffDemoTimeclockRepository, SyncableRepository {
  OfflineFirstStaffDemoTimeclockRepository({
    required final AuthRepository authRepository,
    required final FirebaseFirestore firestore,
    required final StaffDemoShiftRepository shiftRepository,
    required final StaffDemoSiteRepository siteRepository,
    required final StaffDemoLocationService locationService,
    required final StaffDemoTimeclockLocalRepository localRepository,
    required final PendingSyncRepository pendingSyncRepository,
    required final SyncableRepositoryRegistry registry,
  }) : _authRepository = authRepository,
       _firestore = firestore,
       _shiftRepository = shiftRepository,
       _siteRepository = siteRepository,
       _locationService = locationService,
       _localRepository = localRepository,
       _pendingSyncRepository = pendingSyncRepository,
       _registry = registry {
    _registry.register(this);
  }

  static const String staffDemoTimeEntryEntity = 'staff_demo_time_entry';

  final AuthRepository _authRepository;
  final FirebaseFirestore _firestore;
  final StaffDemoShiftRepository _shiftRepository;
  final StaffDemoSiteRepository _siteRepository;
  final StaffDemoLocationService _locationService;
  final StaffDemoTimeclockLocalRepository _localRepository;
  final PendingSyncRepository _pendingSyncRepository;
  final SyncableRepositoryRegistry _registry;

  @override
  String get entityType => staffDemoTimeEntryEntity;

  String? _currentUserId() => _authRepository.currentUser?.id;

  @override
  Future<StaffDemoClockResult> clockIn() async {
    final userId = _currentUserId();
    if (userId == null || userId.isEmpty) {
      throw StateError('Not signed in');
    }

    final existing = await _localRepository.loadOpenEntry(userId: userId);
    if (existing != null) {
      throw StateError('Already clocked in');
    }

    final nowUtc = DateTime.now().toUtc();
    final StaffDemoShift? shift = await _shiftRepository.findActiveShift(
      userId: userId,
      nowUtc: nowUtc,
    );
    final StaffDemoSite? site = shift != null
        ? await _siteRepository.loadSite(siteId: shift.siteId)
        : null;

    final location = await _locationService.captureCurrentLocation();
    final accuracyMeters = location?.accuracyMeters;

    double? distanceMeters;
    if (location != null && site != null) {
      final distance = Geolocator.distanceBetween(
        location.lat,
        location.lng,
        site.centerLat,
        site.centerLng,
      );
      distanceMeters = distance;
    }

    final flags = StaffDemoPunchEvaluator.evaluateClockIn(
      nowUtc: nowUtc,
      shiftStartUtc: shift?.startAtUtc,
      distanceMeters: distanceMeters,
      radiusMeters: site?.radiusMeters,
      accuracyMeters: accuracyMeters,
    ).flags;

    final entryId = 'te_${userId}_${nowUtc.microsecondsSinceEpoch}';

    final payload = <String, dynamic>{
      'action': 'clock_in',
      'entryId': entryId,
      'userId': userId,
      'shiftId': shift?.shiftId,
      'siteId': shift?.siteId,
      'timezoneName': shift?.timezoneName ?? 'UTC',
      'clockInAtClientMs': nowUtc.millisecondsSinceEpoch,
      'clockInLocation': location == null
          ? null
          : <String, dynamic>{'lat': location.lat, 'lng': location.lng},
      'clockInAccuracyMeters': accuracyMeters,
      'distanceMeters': distanceMeters,
      'radiusMeters': site?.radiusMeters,
      'flags': flags.toJson(),
    };

    await _localRepository.saveOpenEntry(
      userId: userId,
      snapshot: StaffDemoOpenEntrySnapshot(
        entryId: entryId,
        clockInAtUtc: nowUtc,
        shiftId: shift?.shiftId,
        siteId: shift?.siteId,
        payload: payload,
      ),
    );

    await _pendingSyncRepository.enqueue(
      SyncOperation.create(
        entityType: entityType,
        payload: payload,
        idempotencyKey: '${staffDemoTimeEntryEntity}_clock_in_$entryId',
      ),
    );

    return StaffDemoClockResult(
      entryId: entryId,
      flags: flags,
      shiftId: shift?.shiftId,
      siteId: shift?.siteId,
      distanceMeters: distanceMeters,
      radiusMeters: site?.radiusMeters,
    );
  }

  @override
  Future<StaffDemoClockResult> clockOut() async {
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
        idempotencyKey: '${staffDemoTimeEntryEntity}_clock_out_${open.entryId}',
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

  @override
  Future<void> pullRemote() async {
    // v1: timeclock writes are push-based via pending sync ops; pull is a no-op.
  }

  @override
  Future<void> processOperation(final SyncOperation operation) async {
    final payload = operation.payload;
    final String? opUserId = payload['userId'] as String?;
    final String? currentUserId = _currentUserId();
    if (opUserId == null ||
        currentUserId == null ||
        opUserId.isEmpty ||
        opUserId != currentUserId) {
      return;
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
