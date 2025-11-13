import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:file_length_lint/file_length_lint.dart';

/// Native Dart 3.10 analyzer plugin entry point.
///
/// This plugin is automatically loaded by the Dart analyzer when configured
/// in `analysis_options.yaml` under the `plugins:` section.
///
/// The plugin is configured in analysis_options.yaml as:
///   plugins:
///     file_length_lint:
///       path: custom_lints/file_length_lint
///       diagnostics:
///         file_too_long: true
///
/// This allows the rule to run automatically with `flutter analyze`.
final plugin = FileLengthLintPlugin();

/// Plugin class for the file length lint rule.
///
/// This plugin registers the `FileLengthLintRule` which checks if files
/// exceed the maximum allowed number of lines (250 by default).
///
/// Note: For native Dart 3.10 analyzer plugins, we use `analysis_server_plugin`
/// to register `AnalysisRule` classes. The analyzer automatically discovers
/// and loads plugins configured via the `plugins:` section in analysis_options.yaml.
class FileLengthLintPlugin extends Plugin {
  @override
  String get name => 'file_length_lint';

  @override
  void register(PluginRegistry registry) {
    // Register the AnalysisRule so it runs automatically with flutter analyze
    // AnalysisRule extends AbstractAnalysisRule, so it can be registered as a lint rule
    registry.registerLintRule(FileLengthLintRule());
  }
}
