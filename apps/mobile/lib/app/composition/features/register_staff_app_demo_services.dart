import 'package:auth/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/fallback_staff_demo_repositories.dart';
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
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_proof_photo_picker.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_timeclock_local_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_content_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_event_proof_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_forms_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_inbox_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_messaging_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_file_store.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_photo_picker.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_push_token_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_shift_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_time_entries_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_timeclock_local_store.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_timeclock_repository.dart';
import 'package:storage/storage.dart';

/// Registers staff-app demo repositories as lazy singletons.
///
/// Firestore/Storage backends are preferred when Firebase is initialized;
/// otherwise mock/no-op fallbacks keep the demo navigable offline or without
/// Firebase. Local timeclock store is always Hive-backed so clock-in works
/// without remotes. Fallbacks are demo convenience—not production security.
void registerStaffAppDemoServices() {
  registerLazySingletonIfAbsent<StaffDemoLocationService>(
    StaffDemoLocationService.new,
  );

  registerLazySingletonIfAbsent<StaffDemoProofPhotoPicker>(
    ImagePickerStaffDemoProofPhotoPicker.new,
  );

  registerLazySingletonIfAbsent<StaffDemoTimeclockLocalStore>(
    () => HiveStaffDemoTimeclockLocalStore(hiveService: getIt<HiveService>()),
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
      fallback: () => NoOpStaffDemoPushTokenRepository(),
    ),
  );

  registerLazySingletonIfAbsent<StaffDemoShiftRepository>(
    () => _withFirestoreOrFallback<StaffDemoShiftRepository>(
      (firestore) => FirestoreStaffDemoShiftRepository(firestore: firestore),
      fallback: () => NoOpStaffDemoShiftRepository(),
    ),
  );

  registerLazySingletonIfAbsent<StaffDemoSiteRepository>(
    () => _withFirestoreOrFallback<StaffDemoSiteRepository>(
      (firestore) => FirestoreStaffDemoSiteRepository(firestore: firestore),
      fallback: () => NoOpStaffDemoSiteRepository(),
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
        localRepository: getIt<StaffDemoTimeclockLocalStore>(),
        pendingSyncRepository: getIt<PendingSyncRepository>(),
        registry: getIt<SyncableRepositoryRegistry>(),
      ),
      fallback: () => NoOpStaffDemoTimeclockRepository(
        authRepository: getIt<AuthRepository>(),
        localRepository: getIt<StaffDemoTimeclockLocalStore>(),
      ),
    ),
  );

  registerLazySingletonIfAbsent<StaffDemoTimeEntriesRepository>(
    () => _withFirestoreOrFallback<StaffDemoTimeEntriesRepository>(
      (firestore) =>
          FirestoreStaffDemoTimeEntriesRepository(firestore: firestore),
      fallback: () => NoOpStaffDemoTimeEntriesRepository(),
    ),
  );

  registerLazySingletonIfAbsent<StaffDemoMessagingRepository>(
    () => _withFirestoreOrFallback<StaffDemoMessagingRepository>(
      (firestore) => FirestoreStaffDemoMessagingRepository(
        firestore: firestore,
        authRepository: getIt<AuthRepository>(),
      ),
      fallback: () => NoOpStaffDemoMessagingRepository(),
    ),
  );

  registerLazySingletonIfAbsent<StaffDemoInboxRepository>(
    () => _withFirestoreOrFallback<StaffDemoInboxRepository>(
      (firestore) => FirestoreStaffDemoInboxRepository(firestore: firestore),
      fallback: () => NoOpStaffDemoInboxRepository(),
    ),
  );

  registerLazySingletonIfAbsent<StaffDemoContentRepository>(
    () => _withFirestoreOrFallback<StaffDemoContentRepository>((firestore) {
      FirebaseStorage? storage;
      try {
        if (Firebase.apps.isNotEmpty) {
          final app = Firebase.app();
          storage = FirebaseStorage.instanceFor(app: app);
        }
      } on Object {
        storage = null;
      }
      return FirestoreStaffDemoContentRepository(
        firestore: firestore,
        storage: storage,
      );
    }, fallback: () => NoOpStaffDemoContentRepository()),
  );

  registerLazySingletonIfAbsent<StaffDemoFormsRepository>(
    () => _withFirestoreOrFallback<StaffDemoFormsRepository>(
      (firestore) => FirestoreStaffDemoFormsRepository(firestore: firestore),
      fallback: () => NoOpStaffDemoFormsRepository(),
    ),
  );

  registerLazySingletonIfAbsent<StaffDemoEventProofSyncOperationFactory>(
    StaffDemoEventProofSyncOperationFactory.new,
  );

  registerLazySingletonIfAbsent<StaffDemoProofFileStore>(
    () => LocalStaffDemoProofFileStore(hiveService: getIt<HiveService>()),
  );

  registerLazySingletonIfAbsent<StaffDemoEventProofRepository>(
    () => _withFirestoreAndStorageOrFallback<StaffDemoEventProofRepository>(
      (firestore, storage) => OfflineFirstStaffDemoEventProofRepository(
        firestore: firestore,
        storage: storage,
        pendingSyncRepository: getIt<PendingSyncRepository>(),
        registry: getIt<SyncableRepositoryRegistry>(),
        operationFactory: getIt<StaffDemoEventProofSyncOperationFactory>(),
        proofFileStore: getIt<StaffDemoProofFileStore>(),
      ),
      fallback: () => NoOpStaffDemoEventProofRepository(),
    ),
  );
}

T _withFirestoreOrFallback<T>(
  T Function(FirebaseFirestore firestore) builder, {
  required T Function() fallback,
}) {
  // Prefer live Firestore; any init/access failure falls back so demo boots.
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

/// Same as Firestore fallback, but also requires Storage for proof uploads.
T _withFirestoreAndStorageOrFallback<T>(
  T Function(FirebaseFirestore firestore, FirebaseStorage storage) builder, {
  required T Function() fallback,
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
