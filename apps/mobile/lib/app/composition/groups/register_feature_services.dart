part of '../injector_registrations.dart';

Future<void> registerFeatureServices() async {
  registerCounterServices();
  registerAuthServices();
  registerRemoteConfigServices();
  registerSupabaseConfigServices();
  registerSupabaseServices();
  registerTimerNetworkServices();
  registerHttpServices();
  registerChartServices();
  registerCalculatorServices();
  registerGraphqlServices();
  registerChatServices();
  registerCaseStudyDemoServices();
  registerSettingsServices();
  registerDeepLinkServices();
  registerWebSocketServices();
  registerGoogleMapsServices();
  registerProfileServices();
  registerSearchServices();
  registerTodoServices();
  registerGenUiServices();
  registerWalletConnectAuthServices();
  registerPlaylearnServices();
}
