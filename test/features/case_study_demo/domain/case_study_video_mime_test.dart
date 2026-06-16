import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_video_mime.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mimeTypeForCaseStudyVideoPath', () {
    test('maps common extensions', () {
      expect(
        mimeTypeForCaseStudyVideoPath('case-study://clip/demo.mp4'),
        'video/mp4',
      );
      expect(
        mimeTypeForCaseStudyVideoPath('case-study://clip/demo.webm'),
        'video/webm',
      );
      expect(
        mimeTypeForCaseStudyVideoPath('case-study://clip/demo.mov'),
        'video/quicktime',
      );
    });

    test('defaults when extension missing or unknown', () {
      expect(
        mimeTypeForCaseStudyVideoPath('case-study://clip/noext'),
        'video/mp4',
      );
      expect(
        mimeTypeForCaseStudyVideoPath('case-study://clip/file.xyz'),
        'video/mp4',
      );
    });
  });

  group('fileExtensionForCaseStudyVideoPath', () {
    test('maps common extensions', () {
      expect(
        fileExtensionForCaseStudyVideoPath('case-study://clip/demo.mp4'),
        'mp4',
      );
      expect(
        fileExtensionForCaseStudyVideoPath('case-study://clip/demo.webm'),
        'webm',
      );
      expect(
        fileExtensionForCaseStudyVideoPath('case-study://clip/demo.mov'),
        'mov',
      );
    });

    test('defaults when extension missing or unknown', () {
      expect(
        fileExtensionForCaseStudyVideoPath('case-study://clip/noext'),
        'mp4',
      );
      expect(
        fileExtensionForCaseStudyVideoPath('case-study://clip/file.xyz'),
        'xyz',
      );
    });
  });
}
