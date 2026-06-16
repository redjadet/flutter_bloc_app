abstract interface class StaffDemoProofFileStore {
  Future<String> persistPhotoFile({required String sourcePath});

  Future<String> persistSignaturePngBytes({required List<int> bytes});

  Future<bool> fileExists(final String path);

  Future<List<int>> readFileBytes(final String path);

  Future<void> deleteFileAtPath(final String path);
}
