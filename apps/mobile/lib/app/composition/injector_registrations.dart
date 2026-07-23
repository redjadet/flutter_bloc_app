import 'package:flutter_bloc_app/app/auth/firebase_local_session_cleanup.dart';
import 'package:flutter_bloc_app/app/auth/session_lifecycle_coordinator.dart';
import 'package:flutter_bloc_app/app/composition/features/register_ai_decision_demo_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_app_memory_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_auth_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_calculator_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_camera_gallery_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_case_study_demo_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_certificate_pinning_demo_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_chart_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_chat_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_counter_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_deeplink_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_event_bus_demo_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_fcm_demo_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_genui_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_google_maps_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_graphql_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_http_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_igaming_demo_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_in_app_purchase_demo_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_iot_demo_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_iot_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_native_platform_showcase_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_online_therapy_demo_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_playlearn_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_profile_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_realtime_market_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_remote_config_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_scapes_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_search_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_settings_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_staff_app_demo_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_supabase_config_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_supabase_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_sync_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_timer_network_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_todo_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_utility_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_walletconnect_auth_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_websocket_services.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/app/config/app_runtime_config.dart';
import 'package:flutter_bloc_app/app/config/backend_availability.dart';
import 'package:storage/storage.dart';

part 'groups/register_core_services.dart';
part 'groups/register_demo_services.dart';
part 'groups/register_feature_services.dart';

Future<void> registerAllDependencies() async {
  await registerCoreServices();
  await registerFeatureServices();
  await registerDemoServices();
  _bindFirebaseLocalSessionCleanup();
}

void _bindFirebaseLocalSessionCleanup() {
  if (!getIt.isRegistered<SessionLifecycleCoordinator>()) {
    return;
  }
  getIt<SessionLifecycleCoordinator>().bindLocalSessionDataCleanup(
    clearFirebaseLocalSessionData,
  );
}
