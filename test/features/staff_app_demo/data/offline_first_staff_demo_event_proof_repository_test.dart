import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/offline_first_staff_demo_event_proof_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_event_proof_sync_constants.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_event_proof_sync_operation_factory.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_event_proof_submit_exception.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive/hive.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockStorageReference extends Mock implements Reference {}

class _FakeFile extends Fake implements File {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeFile());
  });

  group('OfflineFirstStaffDemoEventProofRepository', () {
    late Directory tempDir;
    late HiveService hiveService;
    late PendingSyncRepository pendingRepository;
    late SyncableRepositoryRegistry registry;
    late StaffDemoEventProofSyncOperationFactory operationFactory;
    late MockFirebaseFirestore firestore;
    late MockFirebaseStorage storage;
    late MockStorageReference storageReference;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('staff_demo_proof_repo_');
      Hive.init(tempDir.path);
      hiveService = HiveService(
        keyManager: HiveKeyManager(storage: InMemorySecretStorage()),
      );
      await hiveService.initialize();
      pendingRepository = PendingSyncRepository(hiveService: hiveService);
      registry = SyncableRepositoryRegistry();
      operationFactory = StaffDemoEventProofSyncOperationFactory();
      firestore = MockFirebaseFirestore();
      storage = MockFirebaseStorage();
      storageReference = MockStorageReference();

      when(() => storage.ref(any())).thenReturn(storageReference);
    });

    tearDown(() async {
      await pendingRepository.clear();
      await Hive.deleteFromDisk();
      tempDir.deleteSync(recursive: true);
    });

    test(
      'submitProof enqueues retryable work when storage throws a retryable FirebaseException',
      () async {
        final photoFile = File('${tempDir.path}/photo-1.jpg');
        await photoFile.writeAsBytes(const <int>[1, 2, 3], flush: true);
        final signatureFile = File('${tempDir.path}/signature.png');
        await signatureFile.writeAsBytes(const <int>[4, 5, 6], flush: true);

        when(() => storageReference.putFile(any())).thenThrow(
          FirebaseException(
            plugin: 'firebase_storage',
            code: 'unavailable',
            message: 'offline',
          ),
        );

        final repository = OfflineFirstStaffDemoEventProofRepository(
          firestore: firestore,
          storage: storage,
          pendingSyncRepository: pendingRepository,
          registry: registry,
          operationFactory: operationFactory,
          proofIdFactory: () => 'proof-1',
        );

        await expectLater(
          () => repository.submitProof(
            userId: 'user-1',
            siteId: 'site1',
            shiftId: 'shift-1',
            photoFilePaths: <String>[photoFile.path],
            signaturePngFilePath: signatureFile.path,
          ),
          throwsA(isA<StaffDemoEventProofOfflineEnqueuedException>()),
        );

        final List<SyncOperation> pending = await pendingRepository
            .getPendingOperations(now: DateTime.now().toUtc());
        expect(pending, hasLength(1));
        final SyncOperation operation = pending.single;
        expect(
          operation.entityType,
          StaffDemoEventProofSyncConstants.entityType,
        );
        expect(operation.idempotencyKey, 'proof-1');
        expect(
          operation.payload[StaffDemoEventProofSyncConstants.payloadProofId],
          'proof-1',
        );
        expect(
          operation.payload[StaffDemoEventProofSyncConstants.payloadUserId],
          'user-1',
        );
        expect(
          operation.payload[StaffDemoEventProofSyncConstants.payloadSiteId],
          'site1',
        );
        expect(
          operation.payload[StaffDemoEventProofSyncConstants.payloadShiftId],
          'shift-1',
        );
        expect(
          operation.payload[StaffDemoEventProofSyncConstants.payloadPhotoPaths],
          <String>[photoFile.path],
        );
        expect(
          operation.payload[StaffDemoEventProofSyncConstants
              .payloadSignaturePath],
          signatureFile.path,
        );
      },
    );
  });
}
