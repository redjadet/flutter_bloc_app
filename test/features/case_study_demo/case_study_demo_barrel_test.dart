import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/case_study_demo/case_study_demo.dart';

void main() {
  test('case_study_demo barrel exposes public API types', () {
    expect(CaseStudySessionCubit, isA<Type>());
    expect(CaseStudyDemoHomePage, isA<Type>());
    expect(CaseStudyLocalRepository, isA<Type>());
    expect(CaseStudyRemoteRepository, isA<Type>());
  });
}
