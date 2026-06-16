part of 'register_staff_app_demo_services.dart';

T _withFirestoreOrFallback<T>(
  final T Function(FirebaseFirestore firestore) builder, {
  required final T Function() fallback,
}) {
  try {
    if (Firebase.apps.isEmpty) {
      return fallback();
    }
    final app = Firebase.app();
    final firestore = FirebaseFirestore.instanceFor(app: app);
    return builder(firestore);
  } on Object {
    return fallback();
  }
}

T _withFirestoreAndStorageOrFallback<T>(
  final T Function(FirebaseFirestore firestore, FirebaseStorage storage)
  builder, {
  required final T Function() fallback,
}) {
  try {
    if (Firebase.apps.isEmpty) {
      return fallback();
    }
    final app = Firebase.app();
    final firestore = FirebaseFirestore.instanceFor(app: app);
    final storage = FirebaseStorage.instanceFor(app: app);
    return builder(firestore, storage);
  } on Object {
    return fallback();
  }
}

class _NoOpStaffDemoShiftRepository implements StaffDemoShiftRepository {
  @override
  Future<StaffDemoShift?> findActiveShift({
    required String userId,
    required DateTime nowUtc,
  }) async => null;
}

class _NoOpStaffDemoSiteRepository implements StaffDemoSiteRepository {
  @override
  Future<List<StaffDemoSite>> listSites() async => const <StaffDemoSite>[];

  @override
  Future<StaffDemoSite?> loadSite({required String siteId}) async => null;
}

class _NoOpStaffDemoTimeclockRepository
    implements StaffDemoTimeclockRepository {
  _NoOpStaffDemoTimeclockRepository({
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

class _NoOpStaffDemoTimeEntriesRepository
    implements StaffDemoTimeEntriesRepository {
  @override
  Future<List<StaffDemoTimeEntrySummary>> fetchRecent({int limit = 20}) async =>
      const <StaffDemoTimeEntrySummary>[];
}

class _NoOpStaffDemoMessagingRepository
    implements StaffDemoMessagingRepository {
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

class _NoOpStaffDemoInboxRepository implements StaffDemoInboxRepository {
  @override
  Stream<List<StaffDemoInboxRecipientSnapshot>> watchRecipients({
    required String userId,
  }) => const Stream<List<StaffDemoInboxRecipientSnapshot>>.empty();

  @override
  Future<Map<String, dynamic>?> loadMessage(String messageId) async => null;

  @override
  Future<String?> loadShiftStatus(String shiftId) async => null;
}

class _NoOpStaffDemoFormsRepository implements StaffDemoFormsRepository {
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

class _NoOpStaffDemoPushTokenRepository
    implements StaffDemoPushTokenRepository {
  @override
  Future<void> registerTokens({required String userId}) async {}
}

class _NoOpStaffDemoContentRepository implements StaffDemoContentRepository {
  @override
  Future<List<StaffDemoContentItem>> listPublished() async =>
      const <StaffDemoContentItem>[];

  @override
  Future<Uri> getDownloadUrl({required String storagePath}) async =>
      throw StateError('Firebase unavailable');
}

class _NoOpStaffDemoEventProofRepository
    implements StaffDemoEventProofRepository {
  @override
  Future<String> submitProof({
    required String userId,
    required String siteId,
    required String? shiftId,
    required List<String> photoFilePaths,
    required String signaturePngFilePath,
  }) async => throw StateError('Firebase unavailable');
}
