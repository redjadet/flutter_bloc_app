abstract interface class StaffDemoEventProofRepository {
  Future<String> submitProof({
    required String userId,
    required String siteId,
    required String? shiftId,
    required List<String> photoFilePaths,
    required String signaturePngFilePath,
  });
}
