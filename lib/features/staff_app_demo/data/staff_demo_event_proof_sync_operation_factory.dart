import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_event_proof_sync_constants.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';

class StaffDemoEventProofSyncOperationFactory {
  SyncOperation createSubmitOperation({
    required final String proofId,
    required final String userId,
    required final String siteId,
    required final String? shiftId,
    required final List<String> photoFilePaths,
    required final String signaturePngFilePath,
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
