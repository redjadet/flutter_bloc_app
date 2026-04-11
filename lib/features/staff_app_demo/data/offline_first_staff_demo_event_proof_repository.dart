import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_event_proof_sync_constants.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_event_proof_sync_operation_factory.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_event_proof_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_event_proof_submit_exception.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

class OfflineFirstStaffDemoEventProofRepository
    implements StaffDemoEventProofRepository, SyncableRepository {
  OfflineFirstStaffDemoEventProofRepository({
    required final FirebaseFirestore firestore,
    required final FirebaseStorage storage,
    required final PendingSyncRepository pendingSyncRepository,
    required final SyncableRepositoryRegistry registry,
    required final StaffDemoEventProofSyncOperationFactory operationFactory,
    String Function()? proofIdFactory,
  }) : _firestore = firestore,
       _storage = storage,
       _pendingSyncRepository = pendingSyncRepository,
       _registry = registry,
       _operationFactory = operationFactory,
       _proofIdFactory = proofIdFactory {
    _registry.register(this);
  }

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final PendingSyncRepository _pendingSyncRepository;
  final SyncableRepositoryRegistry _registry;
  final StaffDemoEventProofSyncOperationFactory _operationFactory;
  final String Function()? _proofIdFactory;

  @override
  String get entityType => StaffDemoEventProofSyncConstants.entityType;

  @override
  Future<String> submitProof({
    required final String userId,
    required final String siteId,
    required final String? shiftId,
    required final List<String> photoFilePaths,
    required final String signaturePngFilePath,
  }) async {
    final String proofId =
        _proofIdFactory?.call() ??
        _firestore
            .collection(
              StaffDemoEventProofSyncConstants.firestoreCollection,
            )
            .doc()
            .id;

    try {
      await _submitRemote(
        proofId: proofId,
        userId: userId,
        siteId: siteId,
        shiftId: shiftId,
        photoFilePaths: photoFilePaths,
        signaturePngFilePath: signaturePngFilePath,
      );
      return proofId;
    } on Exception catch (error, stackTrace) {
      if (!_shouldQueueForOfflineRetry(error)) {
        rethrow;
      }
      AppLogger.error(
        'OfflineFirstStaffDemoEventProofRepository.submitProof failed, queuing operation',
        error,
        stackTrace,
      );
      final SyncOperation op = _operationFactory.createSubmitOperation(
        proofId: proofId,
        userId: userId,
        siteId: siteId,
        shiftId: shiftId,
        photoFilePaths: photoFilePaths,
        signaturePngFilePath: signaturePngFilePath,
      );
      await _pendingSyncRepository.enqueue(op);
      throw const StaffDemoEventProofOfflineEnqueuedException();
    }
  }

  @override
  Future<void> processOperation(final SyncOperation operation) async {
    final payload = operation.payload;
    final proofId =
        payload[StaffDemoEventProofSyncConstants.payloadProofId] as String?;
    final userId =
        payload[StaffDemoEventProofSyncConstants.payloadUserId] as String?;
    final siteId =
        payload[StaffDemoEventProofSyncConstants.payloadSiteId] as String?;
    final shiftId =
        payload[StaffDemoEventProofSyncConstants.payloadShiftId] as String?;
    final photoPathsDynamic =
        payload[StaffDemoEventProofSyncConstants.payloadPhotoPaths];
    final signaturePath =
        payload[StaffDemoEventProofSyncConstants.payloadSignaturePath]
            as String?;

    if (proofId == null || proofId.isEmpty) return;
    if (userId == null || userId.isEmpty) return;
    if (siteId == null || siteId.isEmpty) return;
    if (signaturePath == null || signaturePath.isEmpty) return;

    final List<String> photoFilePaths = photoPathsDynamic is List
        ? photoPathsDynamic.whereType<String>().toList(growable: false)
        : const <String>[];

    await _submitRemote(
      proofId: proofId,
      userId: userId,
      siteId: siteId,
      shiftId: shiftId,
      photoFilePaths: photoFilePaths,
      signaturePngFilePath: signaturePath,
    );
  }

  Future<void> _submitRemote({
    required final String proofId,
    required final String userId,
    required final String siteId,
    required final String? shiftId,
    required final List<String> photoFilePaths,
    required final String signaturePngFilePath,
  }) async {
    final List<String> uploadedPhotoStoragePaths = <String>[];
    for (int i = 0; i < photoFilePaths.length; i++) {
      final path = photoFilePaths[i];
      final file = File(path);
      if (!file.existsSync()) continue;
      final storagePath =
          'staff-app-demo/proofs/$userId/$proofId/photos/photo_${i + 1}.jpg';
      await _storage.ref(storagePath).putFile(file);
      uploadedPhotoStoragePaths.add(storagePath);
    }

    final sigFile = File(signaturePngFilePath);
    if (!sigFile.existsSync()) {
      throw FileSystemException(
        'Signature file missing.',
        signaturePngFilePath,
      );
    }
    final String signatureStoragePath =
        'staff-app-demo/proofs/$userId/$proofId/signature.png';
    await _storage.ref(signatureStoragePath).putFile(sigFile);

    await _firestore
        .collection(StaffDemoEventProofSyncConstants.firestoreCollection)
        .doc(proofId)
        .set(<String, dynamic>{
          'userId': userId,
          'siteId': siteId,
          'shiftId': shiftId,
          'photoStoragePaths': uploadedPhotoStoragePaths,
          'signatureStoragePath': signatureStoragePath,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  @override
  Future<void> pullRemote() async {}

  bool _shouldQueueForOfflineRetry(final Object error) {
    if (error is SocketException || error is TimeoutException) {
      return true;
    }
    if (error is FirebaseException) {
      return switch (error.code) {
        'aborted' ||
        'cancelled' ||
        'data-loss' ||
        'deadline-exceeded' ||
        'internal' ||
        'network-request-failed' ||
        'resource-exhausted' ||
        'unavailable' ||
        'unknown' => true,
        _ => false,
      };
    }
    return false;
  }
}
