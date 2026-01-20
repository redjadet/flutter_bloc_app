import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/genui_demo/data/genui_demo_agent_impl.dart';
import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_agent.dart';

void registerGenUiServices() {
  registerLazySingletonIfAbsent<GenUiDemoAgent>(
    () => GenUiDemoAgentImpl(),
    dispose: (final agent) => agent.dispose(),
  );
}
