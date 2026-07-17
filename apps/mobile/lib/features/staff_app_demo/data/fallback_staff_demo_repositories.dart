import 'package:auth/auth.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_content_item.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_content_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_event_proof_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_forms_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_inbox_recipient_snapshot.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_inbox_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_messaging_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_open_entry_snapshot.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_push_token_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_shift.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_shift_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_time_entries_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_time_entry_flags.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_time_entry_summary.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_timeclock_local_store.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_timeclock_repository.dart';

/// Offline fallback when Firestore is unavailable.
class NoOpStaffDemoShiftRepository implements StaffDemoShiftRepository {
  @override
  Future<StaffDemoShift?> findActiveShift({
    required String userId,
    required DateTime nowUtc,
  }) async => null;
}

/// Offline fallback when Firestore is unavailable.
class NoOpStaffDemoSiteRepository implements StaffDemoSiteRepository {
  @override
  Future<List<StaffDemoSite>> listSites() async => const <StaffDemoSite>[];

  @override
  Future<StaffDemoSite?> loadSite({required String siteId}) async => null;
}

/// Offline timeclock that persists open entries to the local store only.
class NoOpStaffDemoTimeclockRepository implements StaffDemoTimeclockRepository {
  NoOpStaffDemoTimeclockRepository({
    required this._authRepository,
    required this._localRepository,
  });

  final AuthRepository _authRepository;
  final StaffDemoTimeclockLocalStore _localRepository;

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
    final entryId = 'te_offline_${userId}_${nowUtc.microsecondsSinceEpoch}';

    await _localRepository.saveOpenEntry(
      userId: userId,
      snapshot: StaffDemoOpenEntrySnapshot(
        entryId: entryId,
        clockInAtUtc: nowUtc,
        shiftId: null,
        siteId: null,
        payload: <String, dynamic>{
          'action': 'clock_in',
          'mode': 'offline_no_firebase',
          'entryId': entryId,
          'userId': userId,
          'clockInAtClientMs': nowUtc.millisecondsSinceEpoch,
          'flags': const StaffDemoTimeEntryFlags.none().toJson(),
        },
      ),
    );

    return StaffDemoClockResult(
      entryId: entryId,
      flags: const StaffDemoTimeEntryFlags.none(),
      shiftId: null,
      siteId: null,
      distanceMeters: null,
      radiusMeters: null,
    );
  }

  @override
  Future<StaffDemoClockResult> clockOut() async {
    final userId = _currentUserId();
    if (userId == null || userId.isEmpty) {
      throw StateError('Not signed in');
    }

    final existing = await _localRepository.loadOpenEntry(userId: userId);
    if (existing == null) {
      throw StateError('Not clocked in');
    }

    await _localRepository.clearOpenEntry(userId: userId);

    return StaffDemoClockResult(
      entryId: existing.entryId,
      flags: const StaffDemoTimeEntryFlags.none(),
      shiftId: existing.shiftId,
      siteId: existing.siteId,
      distanceMeters: null,
      radiusMeters: null,
    );
  }
}

/// Offline fallback when Firestore is unavailable.
class NoOpStaffDemoTimeEntriesRepository implements StaffDemoTimeEntriesRepository {
  @override
  Future<List<StaffDemoTimeEntrySummary>> fetchRecent({int limit = 20}) async =>
      const <StaffDemoTimeEntrySummary>[];
}

/// Offline fallback when Firestore is unavailable.
class NoOpStaffDemoMessagingRepository implements StaffDemoMessagingRepository {
  @override
  Future<String> sendShiftAssignment({
    required String toUserId,
    required String body,
    required String siteId,
    required DateTime startAtUtc,
    required DateTime endAtUtc,
    required String timezoneName,
  }) async => 'offline-noop-${DateTime.now().microsecondsSinceEpoch}';

  @override
  Future<void> confirmShiftAssignment({
    required String messageId,
    required String shiftId,
  }) async {}
}

/// Offline fallback when Firestore is unavailable.
class NoOpStaffDemoInboxRepository implements StaffDemoInboxRepository {
  @override
  Stream<List<StaffDemoInboxRecipientSnapshot>> watchRecipients({
    required String userId,
  }) => const Stream<List<StaffDemoInboxRecipientSnapshot>>.empty();

  @override
  Future<Map<String, dynamic>?> loadMessage(String messageId) async => null;

  @override
  Future<String?> loadShiftStatus(String shiftId) async => null;
}

/// Offline fallback when Firestore is unavailable.
class NoOpStaffDemoFormsRepository implements StaffDemoFormsRepository {
  @override
  Future<void> submitAvailability({
    required String userId,
    required DateTime weekStartUtc,
    required Map<String, bool> availabilityByIsoDate,
  }) async {}

  @override
  Future<void> submitManagerReport({
    required String userId,
    required String siteId,
    required String notes,
  }) async {}
}

/// Offline fallback when Firestore is unavailable.
class NoOpStaffDemoPushTokenRepository implements StaffDemoPushTokenRepository {
  @override
  Future<void> registerTokens({required String userId}) async {}
}

/// Offline fallback when Firestore is unavailable.
class NoOpStaffDemoContentRepository implements StaffDemoContentRepository {
  @override
  Future<List<StaffDemoContentItem>> listPublished() async => const <StaffDemoContentItem>[];

  @override
  Future<Uri> getDownloadUrl({required String storagePath}) async =>
      throw StateError('Firebase unavailable');
}

/// Offline fallback when Firestore is unavailable.
class NoOpStaffDemoEventProofRepository implements StaffDemoEventProofRepository {
  @override
  Future<String> submitProof({
    required String userId,
    required String siteId,
    required String? shiftId,
    required List<String> photoFilePaths,
    required String signaturePngFilePath,
  }) async => throw StateError('Firebase unavailable');
}
