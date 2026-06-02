part of 'register_staff_app_demo_services.dart';

T _withFirestoreOrFallback<T>(
  final T Function(FirebaseFirestore firestore) builder, {
  required final T Function() fallback,
}) {
  try {
    final app = Firebase.app();
    final firestore = FirebaseFirestore.instanceFor(app: app);
    return builder(firestore);
  } on Exception {
    return fallback();
  }
}

T _withFirestoreAndStorageOrFallback<T>(
  final T Function(FirebaseFirestore firestore, FirebaseStorage storage)
  builder, {
  required final T Function() fallback,
}) {
  try {
    final app = Firebase.app();
    final firestore = FirebaseFirestore.instanceFor(app: app);
    final storage = FirebaseStorage.instanceFor(app: app);
    return builder(firestore, storage);
  } on Exception {
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
  @override
  Future<StaffDemoClockResult> clockIn() async =>
      throw StateError('Firebase unavailable');

  @override
  Future<StaffDemoClockResult> clockOut() async =>
      throw StateError('Firebase unavailable');
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
