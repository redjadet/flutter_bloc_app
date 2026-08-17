/// Persists picked case-study video clips under app documents.
abstract class CaseStudyClipFileStore {
  Future<String> persistClipToStaging({
    required String sourcePath,
    required String caseId,
    required String questionId,
    required int commitToken,
  });

  String finalClipFilePathFromStaging(String stagingPath);

  String promoteStagingToFinalSync({
    required String stagingPath,
    required String finalPath,
  });

  Future<String> persistClip({
    required String sourcePath,
    required String caseId,
    required String questionId,
  });

  Future<void> deleteFileIfExists(String? path);

  Future<void> deleteCaseFolder(String caseId);

  Future<List<int>> readClipBytes(String path);
}
