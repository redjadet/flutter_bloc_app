import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:file_length_lint/file_length_lint.dart';

final plugin = FileLengthLintPlugin();

class FileLengthLintPlugin extends Plugin {
  @override
  String get name => 'file_length_lint';

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(FileLengthLintRule());
  }
}
