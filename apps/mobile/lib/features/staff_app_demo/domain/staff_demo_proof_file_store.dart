abstract interface class StaffDemoProofFileStore {
  Future<String> persistPhotoFile({required String sourcePath});

  Future<String> persistSignaturePngBytes({required List<int> bytes});

  Future<bool> fileExists(String path);

  Future<List<int>> readFileBytes(String path);

  Future<void> deleteFileAtPath(String path);
}
