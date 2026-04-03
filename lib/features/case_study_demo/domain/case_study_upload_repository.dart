/// Mock “upload” — simulates latency only; no network.
abstract class CaseStudyUploadRepository {
  Future<void> submitCase();
}
