import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'src/file_too_long_rule.dart';

/// Entry point the analysis server loads from `lib/main.dart`.
final plugin = FileLengthLintPlugin();

class FileLengthLintPlugin extends Plugin {
  @override
  String get name => 'file_length_lint';

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(FileTooLongRule());
  }
}
