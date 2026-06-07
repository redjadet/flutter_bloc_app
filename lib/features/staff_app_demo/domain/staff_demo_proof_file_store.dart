abstract interface class StaffDemoProofFileStore {
  Future<String> persistPhotoFile({required String sourcePath});

  Future<String> persistSignaturePngBytes({required List<int> bytes});
}
