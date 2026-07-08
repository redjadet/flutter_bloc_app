// ignore_for_file: subtype_of_sealed_class

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auth/auth.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/offline_first_staff_demo_timeclock_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_location_service.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_open_entry_snapshot.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_shift_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_timeclock_local_store.dart';
import 'package:storage/storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class _MockStaffDemoShiftRepository extends Mock
    implements StaffDemoShiftRepository {}

class _MockStaffDemoSiteRepository extends Mock
    implements StaffDemoSiteRepository {}

class _MockPendingSyncRepository extends Mock
    implements PendingSyncRepository {}

class _FakeSyncableRepository extends Fake implements SyncableRepository {}

class _MockSyncableRepositoryRegistry extends Mock
    implements SyncableRepositoryRegistry {}

class _InMemoryTimeclockLocalStore implements StaffDemoTimeclockLocalStore {
  StaffDemoOpenEntrySnapshot? _open;

  @override
  Future<void> clearOpenEntry({required final String userId}) async {
    _open = null;
  }

  @override
  Future<StaffDemoOpenEntrySnapshot?> loadOpenEntry({
    required final String userId,
  }) async => _open;

  @override
  Future<void> saveOpenEntry({
    required final String userId,
    required final StaffDemoOpenEntrySnapshot snapshot,
  }) async {
    _open = snapshot;
  }
}

class _FakeGeolocatorPlatform extends GeolocatorPlatform {
  LocationPermission checkPermissionResult = LocationPermission.always;
  LocationPermission requestPermissionResult = LocationPermission.always;
  bool serviceEnabled = true;

  @override
  Future<LocationPermission> checkPermission() async => checkPermissionResult;

  @override
  Future<LocationPermission> requestPermission() async =>
      requestPermissionResult;

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<Position> getCurrentPosition({
    final LocationSettings? locationSettings,
  }) async {
    final limit = locationSettings?.timeLimit;
    if (limit == null) {
      return Completer<Position>().future;
    }
    await Future<void>.delayed(limit);
    throw TimeoutException('Timed out waiting for position update.', limit);
  }
}

Position _samplePosition({final double accuracy = 12}) => Position(
  latitude: 41.0,
  longitude: 29.0,
  timestamp: DateTime.utc(2026, 1, 1),
  accuracy: accuracy,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

void main() {
  late GeolocatorPlatform previousPlatform;
  late _FakeGeolocatorPlatform fakeGeolocator;
  late _MockAuthRepository authRepository;
  late _MockPendingSyncRepository pendingSyncRepository;
  late _MockSyncableRepositoryRegistry registry;
  late _InMemoryTimeclockLocalStore localStore;
  late StaffDemoLocationService locationService;
  late OfflineFirstStaffDemoTimeclockRepository repository;
  late List<SyncOperation> enqueuedOperations;

  const user = AuthUser(
    id: 'user-1',
    email: 'u@example.com',
    isAnonymous: false,
  );

  setUpAll(() {
    registerFallbackValue(_FakeSyncableRepository());
    registerFallbackValue(
      SyncOperation.create(
        entityType:
            OfflineFirstStaffDemoTimeclockRepository.staffDemoTimeEntryEntity,
        idempotencyKey: 'fallback-timeclock',
        payload: const <String, dynamic>{},
      ),
    );
  });

  setUp(() {
    previousPlatform = GeolocatorPlatform.instance;
    fakeGeolocator = _FakeGeolocatorPlatform();
    GeolocatorPlatform.instance = fakeGeolocator;

    authRepository = _MockAuthRepository();
    pendingSyncRepository = _MockPendingSyncRepository();
    registry = _MockSyncableRepositoryRegistry();
    localStore = _InMemoryTimeclockLocalStore();
    locationService = StaffDemoLocationService();
    enqueuedOperations = <SyncOperation>[];

    when(() => authRepository.currentUser).thenReturn(user);
    when(() => registry.register(any())).thenReturn(null);
    when(() => pendingSyncRepository.enqueue(any())).thenAnswer((
      final Invocation inv,
    ) async {
      final SyncOperation operation =
          inv.positionalArguments[0] as SyncOperation;
      enqueuedOperations.add(operation);
      return operation;
    });

    final shiftRepository = _MockStaffDemoShiftRepository();
    final siteRepository = _MockStaffDemoSiteRepository();
    when(
      () => shiftRepository.findActiveShift(
        userId: any(named: 'userId'),
        nowUtc: any(named: 'nowUtc'),
      ),
    ).thenAnswer((_) async => null);

    repository = OfflineFirstStaffDemoTimeclockRepository(
      authRepository: authRepository,
      firestore: _MockFirebaseFirestore(),
      shiftRepository: shiftRepository,
      siteRepository: siteRepository,
      locationService: locationService,
      localRepository: localStore,
      pendingSyncRepository: pendingSyncRepository,
      registry: registry,
    );
  });

  tearDown(() {
    GeolocatorPlatform.instance = previousPlatform;
  });

  test(
    'clockIn succeeds with locationInsufficient when permission denied',
    () async {
      fakeGeolocator.checkPermissionResult = LocationPermission.deniedForever;

      final result = await repository.clockIn();

      expect(result.flags.locationInsufficient, isTrue);
      expect(enqueuedOperations, hasLength(1));
      final payload = enqueuedOperations.single.payload;
      expect(payload['action'], 'clock_in');
      expect(payload['userId'], user.id);
      expect(payload['clockInLocation'], isNull);
      expect(payload['clockInAccuracyMeters'], isNull);
      expect(payload['flags'], isA<Map<String, dynamic>>());
      expect(
        (payload['flags'] as Map<String, dynamic>)['locationInsufficient'],
        isTrue,
      );
      final open = await localStore.loadOpenEntry(userId: user.id);
      expect(open, isNotNull);
      expect(open!.entryId, result.entryId);
    },
  );

  test(
    'clockOut succeeds with locationInsufficient when location unavailable',
    () async {
      locationService = StaffDemoLocationService(
        currentPositionFetcher: () async => _samplePosition(),
      );
      final shiftRepository = _MockStaffDemoShiftRepository();
      when(
        () => shiftRepository.findActiveShift(
          userId: any(named: 'userId'),
          nowUtc: any(named: 'nowUtc'),
        ),
      ).thenAnswer((_) async => null);

      repository = OfflineFirstStaffDemoTimeclockRepository(
        authRepository: authRepository,
        firestore: _MockFirebaseFirestore(),
        shiftRepository: shiftRepository,
        siteRepository: _MockStaffDemoSiteRepository(),
        locationService: locationService,
        localRepository: localStore,
        pendingSyncRepository: pendingSyncRepository,
        registry: registry,
      );

      final clockInResult = await repository.clockIn();
      expect(clockInResult.flags.locationInsufficient, isFalse);
      enqueuedOperations.clear();

      fakeGeolocator.serviceEnabled = false;

      final clockOutResult = await repository.clockOut();

      expect(clockOutResult.flags.locationInsufficient, isTrue);
      expect(enqueuedOperations, hasLength(1));
      final payload = enqueuedOperations.single.payload;
      expect(payload['action'], 'clock_out');
      expect(payload['entryId'], clockInResult.entryId);
      expect(payload['clockOutLocation'], isNull);
      expect(payload['clockOutAccuracyMeters'], isNull);
      expect(payload['flags'], <String, dynamic>{'locationInsufficient': true});
      final open = await localStore.loadOpenEntry(userId: user.id);
      expect(open, isNull);
    },
  );

  test(
    'clockOut sets locationInsufficient when accuracy exceeds trust threshold',
    () async {
      var callCount = 0;
      locationService = StaffDemoLocationService(
        currentPositionFetcher: () async {
          callCount++;
          return _samplePosition(accuracy: callCount == 1 ? 12 : 150);
        },
      );
      final shiftRepository = _MockStaffDemoShiftRepository();
      when(
        () => shiftRepository.findActiveShift(
          userId: any(named: 'userId'),
          nowUtc: any(named: 'nowUtc'),
        ),
      ).thenAnswer((_) async => null);

      repository = OfflineFirstStaffDemoTimeclockRepository(
        authRepository: authRepository,
        firestore: _MockFirebaseFirestore(),
        shiftRepository: shiftRepository,
        siteRepository: _MockStaffDemoSiteRepository(),
        locationService: locationService,
        localRepository: localStore,
        pendingSyncRepository: pendingSyncRepository,
        registry: registry,
      );

      await repository.clockIn();
      enqueuedOperations.clear();

      final clockOutResult = await repository.clockOut();

      expect(clockOutResult.flags.locationInsufficient, isTrue);
      expect(enqueuedOperations.single.payload['clockOutAccuracyMeters'], 150);
    },
  );
}
