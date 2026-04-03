import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_upload_repository.dart';

/// Simulates upload latency only.
class CaseStudyMockUploadRepository implements CaseStudyUploadRepository {
  CaseStudyMockUploadRepository({
    this.delay = const Duration(milliseconds: 450),
  });

  final Duration delay;

  @override
  Future<void> submitCase() async {
    // check-ignore: simulate upload latency (demo)
    await Future<void>.delayed(delay);
  }
}
