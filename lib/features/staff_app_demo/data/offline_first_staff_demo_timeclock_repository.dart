import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_location_service.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_open_entry_snapshot.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_punch_evaluator.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_shift.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_shift_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_time_entry_flags.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_timeclock_local_store.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_timeclock_repository.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation_deferred_exception.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:geolocator/geolocator.dart';

part 'offline_first_staff_demo_timeclock_repository_sync.part.dart';

class OfflineFirstStaffDemoTimeclockRepository
    implements StaffDemoTimeclockRepository, SyncableRepository {
  OfflineFirstStaffDemoTimeclockRepository({
    required this._authRepository,
    required this._firestore,
    required this._shiftRepository,
    required this._siteRepository,
    required this._locationService,
    required this._localRepository,
    required this._pendingSyncRepository,
    required this._registry,
  }) {
    _registry.register(this);
  }

  static const String staffDemoTimeEntryEntity = 'staff_demo_time_entry';

  final AuthRepository _authRepository;
  final FirebaseFirestore _firestore;
  final StaffDemoShiftRepository _shiftRepository;
  final StaffDemoSiteRepository _siteRepository;
  final StaffDemoLocationService _locationService;
  final StaffDemoTimeclockLocalStore _localRepository;
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
  Future<StaffDemoClockResult> clockOut() => clockOutImpl();

  @override
  Future<void> pullRemote() => pullRemoteImpl();

  @override
  Future<void> processOperation(final SyncOperation operation) =>
      processOperationImpl(operation);
}
