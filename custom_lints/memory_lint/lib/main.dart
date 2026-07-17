import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'src/rules/memory_state_controller_missing_dispose_rule.dart';
import 'src/rules/memory_static_build_context_rule.dart';
import 'src/rules/memory_stream_controller_missing_close_rule.dart';
import 'src/rules/memory_widgets_binding_observer_missing_remove_rule.dart';

/// Entry point the analysis server loads from `lib/main.dart`.
final plugin = MemoryLintPlugin();

class MemoryLintPlugin extends Plugin {
  @override
  String get name => 'memory_lint';

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(MemoryStateControllerMissingDisposeRule());
    registry.registerLintRule(MemoryStreamControllerMissingCloseRule());
    registry.registerLintRule(MemoryWidgetsBindingObserverMissingRemoveRule());
    registry.registerLintRule(MemoryStaticBuildContextRule());
  }
}
