import 'package:design_system/design_system.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_repository.dart';
import 'package:flutter_bloc_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/widgets/scapes_grid_content.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_harness.dart';

part 'flow_scenarios_helpers.dart';
part 'flow_scenarios_primary.dart';
part 'flow_scenarios_secondary.dart';
part 'flow_scenarios_tertiary.dart';

void registerSmokeIntegrationFlows() {
  registerGuestSignInIntegrationFlow();
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
  registerEventBusDemoIntegrationFlow();
  registerNativePlatformShowcaseIntegrationFlow();
  registerWhiteboardIntegrationFlow();
}

void registerPrSmokeIntegrationFlows() {
  registerGuestSignInIntegrationFlow();
  registerAppLaunchIntegrationFlow();
  registerChartsIntegrationFlow();
  registerSearchIntegrationFlow();
  registerSettingsIntegrationFlow();
  registerTodoListIntegrationFlow();
  registerCounterPersistenceIntegrationFlow();
  registerChatListIntegrationFlow();
}

void registerExtendedIntegrationFlows() {
  registerChartsRefreshIntegrationFlow();
  registerCounterPersistenceIntegrationFlow();
  registerIotDemoBleTabIntegrationFlow();
  registerNavigationIntegrationFlow();
  registerPlaylearnEmptyTopicsIntegrationFlow();
  registerSearchEmptyResultsIntegrationFlow();
  registerSettingsThemePersistenceIntegrationFlow();
  registerTodoListFilterIntegrationFlow();
}

/// Standard CI tier: full smoke journeys plus extended flows (persistence,
/// navigation, filter/empty/error paths). Strictly broader than
/// [registerSmokeIntegrationFlows] and matches journey coverage for J1–J4 in
/// `docs/engineering/integration_journey_map.md`.
void registerStandardIntegrationFlows() {
  registerSmokeIntegrationFlows();
  registerExtendedIntegrationFlows();
}

/// Runs after [registerStandardIntegrationFlows]. Keep long-tail or
/// extra-cost scenarios here so `standard` / smoke tiers stay faster.
void registerExhaustiveOnlyIntegrationFlows() {
  registerGraphqlNetworkRetryIntegrationFlow();
}

void registerAllIntegrationFlows() {
  registerStandardIntegrationFlows();
  registerExhaustiveOnlyIntegrationFlows();
}
