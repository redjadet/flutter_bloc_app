import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_shift_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_profile_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_site_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_time_entries_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_push_token_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/offline_first_staff_demo_timeclock_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_messaging_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_inbox_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/mock_staff_demo_profile_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_location_service.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_timeclock_local_repository.dart';
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
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';

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
      (firestore) => FirestoreStaffDemoPushTokenRepository(firestore: firestore),
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
      (firestore) => FirestoreStaffDemoTimeEntriesRepository(firestore: firestore),
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

class _NoOpStaffDemoTimeclockRepository implements StaffDemoTimeclockRepository {
  @override
  Future<StaffDemoClockResult> clockIn() async =>
      throw StateError('Firebase unavailable');

  @override
  Future<StaffDemoClockResult> clockOut() async =>
      throw StateError('Firebase unavailable');
}

class _NoOpStaffDemoPushTokenRepository implements StaffDemoPushTokenRepository {
  @override
  Future<void> registerTokens({required String userId}) async {}
}
