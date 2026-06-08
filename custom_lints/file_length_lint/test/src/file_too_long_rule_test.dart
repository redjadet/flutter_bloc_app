import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:file_length_lint/src/file_too_long_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

@reflectiveTest
class FileTooLongRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = FileTooLongRule();
    super.setUp();
    // AnalysisRuleTest.setUp overwrites analysis_options.yaml; re-append plugin
    // config after enabling the rule under test.
    newAnalysisOptionsYamlFile(testPackageRootPath, '''
${analysisOptionsContent(rules: <String>['file_too_long'])}
file_length_lint:
  max_lines: 3
  include_defaults: false
  excludes: []
''');
  }

  void test_short_file_no_diagnostic() async {
    await assertNoDiagnostics(r'''
void main() {}
''');
  }

  void test_long_file_reports() async {
    await assertDiagnostics(
      r'''
void main() {
  print('one');
  print('two');
  print('three');
  print('four');
}
''',
      [lint(0, 0)],
    );
  }
}

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(FileTooLongRuleTest);
  });
}
