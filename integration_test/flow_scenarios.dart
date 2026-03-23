import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/widgets/scapes_grid_content.dart';
import 'package:flutter_bloc_app/shared/widgets/common_card.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_harness.dart';

part 'flow_scenarios_primary.dart';
part 'flow_scenarios_secondary.dart';
part 'flow_scenarios_tertiary.dart';
part 'flow_scenarios_helpers.dart';

void registerSmokeIntegrationFlows() {
  registerAppLaunchIntegrationFlow();
  registerCalculatorIntegrationFlow();
  registerChartsIntegrationFlow();
  registerChatListIntegrationFlow();
  registerGenUiDemoIntegrationFlow();
  registerGraphqlDemoIntegrationFlow();
  registerIgamingDemoIntegrationFlow();
  registerIotDemoIntegrationFlow();
  registerMarkdownEditorIntegrationFlow();
  registerPlaylearnIntegrationFlow();
  registerSearchIntegrationFlow();
  registerSettingsIntegrationFlow();
  registerTodoListIntegrationFlow();
  registerWebsocketIntegrationFlow();
  registerWhiteboardIntegrationFlow();
}

void registerPrSmokeIntegrationFlows() {
  registerAppLaunchIntegrationFlow();
  registerChartsIntegrationFlow();
  registerSearchIntegrationFlow();
  registerSettingsIntegrationFlow();
  registerTodoListIntegrationFlow();
}

void registerExtendedIntegrationFlows() {
  registerChartsRefreshIntegrationFlow();
  registerCounterPersistenceIntegrationFlow();
  registerNavigationIntegrationFlow();
  registerPlaylearnEmptyTopicsIntegrationFlow();
  registerSearchEmptyResultsIntegrationFlow();
  registerSettingsThemePersistenceIntegrationFlow();
  registerTodoListFilterIntegrationFlow();
}

void registerAllIntegrationFlows() {
  registerSmokeIntegrationFlows();
  registerExtendedIntegrationFlows();
}
