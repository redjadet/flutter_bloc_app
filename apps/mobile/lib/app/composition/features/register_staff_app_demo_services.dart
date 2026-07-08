import 'package:auth/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
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
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_content_item.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_content_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_event_proof_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_forms_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_inbox_recipient_snapshot.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_inbox_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_messaging_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_open_entry_snapshot.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_file_store.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_photo_picker.dart';
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
import 'package:storage/storage.dart';

part 'register_staff_app_demo_services.part.dart';

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
        localRepository: getIt<StaffDemoTimeclockLocalStore>(),
        pendingSyncRepository: getIt<PendingSyncRepository>(),
        registry: getIt<SyncableRepositoryRegistry>(),
      ),
      fallback: () => _NoOpStaffDemoTimeclockRepository(
        authRepository: getIt<AuthRepository>(),
        localRepository: getIt<StaffDemoTimeclockLocalStore>(),
      ),
    ),
  );

  registerLazySingletonIfAbsent<StaffDemoTimeEntriesRepository>(
    () => _withFirestoreOrFallback<StaffDemoTimeEntriesRepository>(
      (firestore) =>
          FirestoreStaffDemoTimeEntriesRepository(firestore: firestore),
      fallback: () => _NoOpStaffDemoTimeEntriesRepository(),
    ),
  );

  registerLazySingletonIfAbsent<StaffDemoMessagingRepository>(
    () => _withFirestoreOrFallback<StaffDemoMessagingRepository>(
      (firestore) => FirestoreStaffDemoMessagingRepository(
        firestore: firestore,
        authRepository: getIt<AuthRepository>(),
      ),
      fallback: () => _NoOpStaffDemoMessagingRepository(),
    ),
  );

  registerLazySingletonIfAbsent<StaffDemoInboxRepository>(
    () => _withFirestoreOrFallback<StaffDemoInboxRepository>(
      (firestore) => FirestoreStaffDemoInboxRepository(firestore: firestore),
      fallback: () => _NoOpStaffDemoInboxRepository(),
    ),
  );

  registerLazySingletonIfAbsent<StaffDemoContentRepository>(
    () => _withFirestoreOrFallback<StaffDemoContentRepository>(
      (firestore) {
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
      },
      fallback: () => _NoOpStaffDemoContentRepository(),
    ),
  );

  registerLazySingletonIfAbsent<StaffDemoFormsRepository>(
    () => _withFirestoreOrFallback<StaffDemoFormsRepository>(
      (firestore) => FirestoreStaffDemoFormsRepository(firestore: firestore),
      fallback: () => _NoOpStaffDemoFormsRepository(),
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
      fallback: () => _NoOpStaffDemoEventProofRepository(),
    ),
  );
}
