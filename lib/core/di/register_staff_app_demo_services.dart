import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_content_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_forms_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_inbox_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_messaging_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_profile_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_push_token_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_shift_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_site_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_time_entries_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/mock_staff_demo_profile_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/offline_first_staff_demo_event_proof_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/offline_first_staff_demo_timeclock_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_event_proof_sync_operation_factory.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_location_service.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_proof_file_store.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_timeclock_local_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_content_item.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_content_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_event_proof_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_forms_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_push_token_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_shift.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_shift_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_timeclock_repository.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';

void registerStaffAppDemoServices() {
  registerLazySingletonIfAbsent<StaffDemoLocationService>(
    StaffDemoLocationService.new,
  );

  registerLazySingletonIfAbsent<StaffDemoTimeclockLocalRepository>(
    () => StaffDemoTimeclockLocalRepository(hiveService: getIt<HiveService>()),
  );

  registerLazySingletonIfAbsent<StaffDemoProfileRepository>(
    () => _withFirestoreOrFallback<StaffDemoProfileRepository>(
      (firestore) => FirestoreStaffDemoProfileRepository(firestore: firestore),
      fallback: () => MockStaffDemoProfileRepository(),
    ),
  );

  registerLazySingletonIfAbsent<StaffDemoPushTokenRepository>(
    () => _withFirestoreOrFallback<StaffDemoPushTokenRepository>(
      (firestore) =>
          FirestoreStaffDemoPushTokenRepository(firestore: firestore),
      fallback: () => _NoOpStaffDemoPushTokenRepository(),
    ),
  );

  registerLazySingletonIfAbsent<StaffDemoShiftRepository>(
    () => _withFirestoreOrFallback<StaffDemoShiftRepository>(
      (firestore) => FirestoreStaffDemoShiftRepository(firestore: firestore),
      fallback: () => _NoOpStaffDemoShiftRepository(),
    ),
  );

  registerLazySingletonIfAbsent<StaffDemoSiteRepository>(
    () => _withFirestoreOrFallback<StaffDemoSiteRepository>(
      (firestore) => FirestoreStaffDemoSiteRepository(firestore: firestore),
      fallback: () => _NoOpStaffDemoSiteRepository(),
    ),
  );

  registerLazySingletonIfAbsent<StaffDemoTimeclockRepository>(
    () => _withFirestoreOrFallback<StaffDemoTimeclockRepository>(
      (firestore) => OfflineFirstStaffDemoTimeclockRepository(
        authRepository: getIt<AuthRepository>(),
        firestore: firestore,
        shiftRepository: getIt<StaffDemoShiftRepository>(),
        siteRepository: getIt<StaffDemoSiteRepository>(),
        locationService: getIt<StaffDemoLocationService>(),
        localRepository: getIt<StaffDemoTimeclockLocalRepository>(),
        pendingSyncRepository: getIt<PendingSyncRepository>(),
        registry: getIt<SyncableRepositoryRegistry>(),
      ),
      fallback: () => _NoOpStaffDemoTimeclockRepository(),
    ),
  );

  registerLazySingletonIfAbsent<FirestoreStaffDemoTimeEntriesRepository>(
    () => _withFirestoreOrFallback<FirestoreStaffDemoTimeEntriesRepository>(
      (firestore) =>
          FirestoreStaffDemoTimeEntriesRepository(firestore: firestore),
      fallback: () => throw StateError('Firebase unavailable'),
    ),
  );

  registerLazySingletonIfAbsent<FirestoreStaffDemoMessagingRepository>(
    () => _withFirestoreOrFallback<FirestoreStaffDemoMessagingRepository>(
      (firestore) => FirestoreStaffDemoMessagingRepository(
        firestore: firestore,
        authRepository: getIt<AuthRepository>(),
      ),
      fallback: () => throw StateError('Firebase unavailable'),
    ),
  );

  registerLazySingletonIfAbsent<FirestoreStaffDemoInboxRepository>(
    () => _withFirestoreOrFallback<FirestoreStaffDemoInboxRepository>(
      (firestore) => FirestoreStaffDemoInboxRepository(firestore: firestore),
      fallback: () => throw StateError('Firebase unavailable'),
    ),
  );

  registerLazySingletonIfAbsent<StaffDemoContentRepository>(
    () => _withFirestoreOrFallback<StaffDemoContentRepository>(
      (firestore) {
        FirebaseStorage? storage;
        try {
          final app = Firebase.app();
          storage = FirebaseStorage.instanceFor(app: app);
        } on Exception {
          storage = null;
        }
        return FirestoreStaffDemoContentRepository(
          firestore: firestore,
          storage: storage,
        );
      },
      fallback: () => _NoOpStaffDemoContentRepository(),
    ),
  );

  registerLazySingletonIfAbsent<StaffDemoFormsRepository>(
    () => _withFirestoreOrFallback<StaffDemoFormsRepository>(
      (firestore) => FirestoreStaffDemoFormsRepository(firestore: firestore),
      fallback: () => throw StateError('Firebase unavailable'),
    ),
  );

  registerLazySingletonIfAbsent<StaffDemoEventProofSyncOperationFactory>(
    StaffDemoEventProofSyncOperationFactory.new,
  );

  registerLazySingletonIfAbsent<StaffDemoProofFileStore>(
    StaffDemoProofFileStore.new,
  );

  registerLazySingletonIfAbsent<StaffDemoEventProofRepository>(
    () => _withFirestoreAndStorageOrFallback<StaffDemoEventProofRepository>(
      (firestore, storage) => OfflineFirstStaffDemoEventProofRepository(
        firestore: firestore,
        storage: storage,
        pendingSyncRepository: getIt<PendingSyncRepository>(),
        registry: getIt<SyncableRepositoryRegistry>(),
        operationFactory: getIt<StaffDemoEventProofSyncOperationFactory>(),
      ),
      fallback: () => _NoOpStaffDemoEventProofRepository(),
    ),
  );
}

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
