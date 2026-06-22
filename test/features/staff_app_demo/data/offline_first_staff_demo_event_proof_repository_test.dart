// ignore_for_file: subtype_of_sealed_class

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/offline_first_staff_demo_event_proof_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_event_proof_sync_constants.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_event_proof_sync_operation_factory.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_event_proof_submit_exception.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_file_store.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class _MockFirebaseStorage extends Mock implements FirebaseStorage {}

class _MockPendingSyncRepository extends Mock
    implements PendingSyncRepository {}

class _FakeSyncableRepository extends Fake implements SyncableRepository {}

class _MockSyncableRepositoryRegistry extends Mock
    implements SyncableRepositoryRegistry {}

class _MockStaffDemoEventProofSyncOperationFactory extends Mock
    implements StaffDemoEventProofSyncOperationFactory {}

class _MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class _MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class _MockReference extends Mock implements Reference {}

class _DiskProofFileStore implements StaffDemoProofFileStore {
  @override
  Future<bool> fileExists(final String path) => File(path).exists();

  @override
  Future<List<int>> readFileBytes(final String path) =>
      File(path).readAsBytes();

  @override
  Future<String> persistPhotoFile({required final String sourcePath}) async =>
      sourcePath;

  @override
  Future<String> persistSignaturePngBytes({
    required final List<int> bytes,
  }) async => throw UnimplementedError();

  @override
  Future<void> deleteFileAtPath(final String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(SettableMetadata());
    registerFallbackValue(_FakeSyncableRepository());
    registerFallbackValue(
      SyncOperation.create(
        entityType: StaffDemoEventProofSyncConstants.entityType,
        idempotencyKey: 'fallback-proof',
        payload: const <String, dynamic>{},
      ),
    );
  });

  group('OfflineFirstStaffDemoEventProofRepository', () {
    test(
      'queues proof submission when storage upload fails with network error',
      () async {
        final firestore = _MockFirebaseFirestore();
        final storage = _MockFirebaseStorage();
        final pendingSyncRepository = _MockPendingSyncRepository();
        final registry = _MockSyncableRepositoryRegistry();
        final operationFactory = _MockStaffDemoEventProofSyncOperationFactory();
        final proofFileStore = _DiskProofFileStore();
        final collection = _MockCollectionReference();
        final document = _MockDocumentReference();
        final storageReference = _MockReference();
        final tempDir = await Directory.systemTemp.createTemp(
          'staff-proof-offline-repo-test',
        );
        final photoFile = File('${tempDir.path}/photo.jpg');
        final signatureFile = File('${tempDir.path}/signature.png');
        await photoFile.writeAsBytes(const <int>[1, 2, 3], flush: true);
        await signatureFile.writeAsBytes(const <int>[4, 5, 6], flush: true);

        when(() => registry.register(any())).thenReturn(null);
        when(() => firestore.collection(any())).thenReturn(collection);
        when(() => collection.doc()).thenReturn(document);
        when(() => document.id).thenReturn('proof-queued-1');
        when(() => storage.ref(any())).thenReturn(storageReference);
        when(() => storageReference.putData(any(), any())).thenThrow(
          FirebaseException(plugin: 'firebase_storage', code: 'unavailable'),
        );
        when(
          () => operationFactory.createSubmitOperation(
            proofId: any(named: 'proofId'),
            userId: any(named: 'userId'),
            siteId: any(named: 'siteId'),
            shiftId: any(named: 'shiftId'),
            photoFilePaths: any(named: 'photoFilePaths'),
            signaturePngFilePath: any(named: 'signaturePngFilePath'),
          ),
        ).thenReturn(
          SyncOperation.create(
            entityType: StaffDemoEventProofSyncConstants.entityType,
            idempotencyKey: 'proof-queued-1',
            payload: const <String, dynamic>{},
          ),
        );
        when(() => pendingSyncRepository.enqueue(any())).thenAnswer(
          (final Invocation inv) async =>
              inv.positionalArguments[0] as SyncOperation,
        );

        final repository = OfflineFirstStaffDemoEventProofRepository(
          firestore: firestore,
          storage: storage,
          pendingSyncRepository: pendingSyncRepository,
          registry: registry,
          operationFactory: operationFactory,
          proofFileStore: proofFileStore,
        );
        addTearDown(() async {
          await tempDir.delete(recursive: true);
        });

        await expectLater(
          repository.submitProof(
            userId: 'user-1',
            siteId: 'site-1',
            shiftId: 'shift-1',
            photoFilePaths: <String>[photoFile.path],
            signaturePngFilePath: signatureFile.path,
          ),
          throwsA(isA<StaffDemoEventProofOfflineEnqueuedException>()),
        );

        verify(() => pendingSyncRepository.enqueue(any())).called(1);
      },
    );

    test('throws when a photo file path is missing on disk', () async {
      final firestore = _MockFirebaseFirestore();
      final storage = _MockFirebaseStorage();
      final pendingSyncRepository = _MockPendingSyncRepository();
      final registry = _MockSyncableRepositoryRegistry();
      final operationFactory = _MockStaffDemoEventProofSyncOperationFactory();
      final proofFileStore = _DiskProofFileStore();
      final tempDir = await Directory.systemTemp.createTemp(
        'staff-proof-missing-photo-test',
      );
      final signatureFile = File('${tempDir.path}/signature.png');
      await signatureFile.writeAsBytes(const <int>[4, 5, 6], flush: true);

      when(() => registry.register(any())).thenReturn(null);

      final repository = OfflineFirstStaffDemoEventProofRepository(
        firestore: firestore,
        storage: storage,
        pendingSyncRepository: pendingSyncRepository,
        registry: registry,
        operationFactory: operationFactory,
        proofFileStore: proofFileStore,
        proofIdFactory: () => 'proof-missing-photo',
      );
      addTearDown(() async {
        await tempDir.delete(recursive: true);
      });

      await expectLater(
        repository.submitProof(
          userId: 'user-1',
          siteId: 'site-1',
          shiftId: 'shift-1',
          photoFilePaths: <String>['${tempDir.path}/missing.jpg'],
          signaturePngFilePath: signatureFile.path,
        ),
        throwsA(
          isA<StaffDemoProofFileMissingException>().having(
            (final StaffDemoProofFileMissingException e) => e.message,
            'message',
            contains('Photo file missing'),
          ),
        ),
      );

      verifyNever(() => storage.ref(any()));
      verifyNever(() => pendingSyncRepository.enqueue(any()));
    });

    test('pullRemote is intentional no-op for push-only proof sync', () async {
      final firestore = _MockFirebaseFirestore();
      final storage = _MockFirebaseStorage();
      final pendingSyncRepository = _MockPendingSyncRepository();
      final registry = _MockSyncableRepositoryRegistry();
      final operationFactory = _MockStaffDemoEventProofSyncOperationFactory();
      final proofFileStore = _DiskProofFileStore();

      when(() => registry.register(any())).thenReturn(null);

      final repository = OfflineFirstStaffDemoEventProofRepository(
        firestore: firestore,
        storage: storage,
        pendingSyncRepository: pendingSyncRepository,
        registry: registry,
        operationFactory: operationFactory,
        proofFileStore: proofFileStore,
        proofIdFactory: () => 'proof-no-pull',
      );

      await expectLater(repository.pullRemote(), completes);
    });
  });
}
