import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_event_proof_sync_constants.dart';
import 'package:storage/storage.dart';

class StaffDemoEventProofSyncOperationFactory {
  SyncOperation createSubmitOperation({
    required String proofId,
    required String userId,
    required String siteId,
    required String? shiftId,
    required List<String> photoFilePaths,
    required String signaturePngFilePath,
  }) => SyncOperation.create(
    entityType: StaffDemoEventProofSyncConstants.entityType,
    idempotencyKey: proofId,
    payload: <String, dynamic>{
      StaffDemoEventProofSyncConstants.payloadProofId: proofId,
      StaffDemoEventProofSyncConstants.payloadUserId: userId,
      StaffDemoEventProofSyncConstants.payloadSiteId: siteId,
      StaffDemoEventProofSyncConstants.payloadShiftId: shiftId,
      StaffDemoEventProofSyncConstants.payloadPhotoPaths: photoFilePaths,
      StaffDemoEventProofSyncConstants.payloadSignaturePath:
          signaturePngFilePath,
    },
  );
}
