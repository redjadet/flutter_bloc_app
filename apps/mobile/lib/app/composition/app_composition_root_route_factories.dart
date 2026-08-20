import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/app/auth/session_lifecycle_coordinator.dart';
import 'package:flutter_bloc_app/app/composition/app_composition_root_demo_route_factory.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_factories.dart';
import 'package:flutter_bloc_app/app/config/app_runtime_config.dart';
import 'package:flutter_bloc_app/app/platform/biometric_authenticator.dart';
import 'package:flutter_bloc_app/app/router/route_groups.dart';
import 'package:flutter_bloc_app/app/router/routes.dart';
import 'package:flutter_bloc_app/app/router/routes_core.dart';
import 'package:flutter_bloc_app/app/services/error_notification_service.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_repository.dart';
import 'package:flutter_bloc_app/features/calculator/calculator.dart';
import 'package:flutter_bloc_app/features/camera_gallery/camera_gallery.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_repository.dart';
import 'package:flutter_bloc_app/features/counter/counter.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location_repository.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_repository.dart';
import 'package:flutter_bloc_app/features/scapes/domain/scapes_repository.dart';
import 'package:flutter_bloc_app/features/search/domain/search_repository.dart';
import 'package:flutter_bloc_app/features/settings/settings.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/features/todo_list/todo_list.dart';
import 'package:flutter_bloc_app/features/walletconnect_auth/domain/walletconnect_auth_repository.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_repository.dart';
import 'package:storage/storage.dart' show PendingSyncRepository;
import 'package:utilities/utilities.dart'
    show GraphqlCacheClearPort, ProfileCacheControlsPort;

AppRouteFactories resolveAppRouteFactories() {
  final AuthRepository authRepository = getIt<AuthRepository>();
  final TimerService timerService = getIt<TimerService>();

  return AppRouteFactories(
    core: resolveCoreRouteFactory(
      authRepository: authRepository,
      timerService: timerService,
    ),
    auxiliary: resolveAuxiliaryRouteFactory(
      authRepository: authRepository,
      timerService: timerService,
    ),
    demo: resolveDemoRouteFactory(
      authRepository: authRepository,
      timerService: timerService,
    ),
  );
}

CoreRouteFactory resolveCoreRouteFactory({
  AuthRepository? authRepository,
  TimerService? timerService,
}) {
  final AuthRepository resolvedAuthRepository =
      authRepository ?? getIt<AuthRepository>();
  final TimerService resolvedTimerService =
      timerService ?? getIt<TimerService>();

  return CoreRouteFactory(
    authRepository: resolvedAuthRepository,
    paymentCalculator: getIt<PaymentCalculator>(),
    firebaseAuth: getIt.isRegistered<FirebaseAuth>()
        ? getIt<FirebaseAuth>()
        : null,
    cameraGalleryRepository: getIt<CameraGalleryRepository>(),
    scapesRepository: getIt<ScapesRepository>(),
    graphqlDemoRepository: getIt<GraphqlDemoRepository>(),
    counterRepository: getIt<CounterRepository>(),
    timerService: resolvedTimerService,
    runtimeConfig: getIt<AppRuntimeConfig>(),
    errorNotificationService: getIt<ErrorNotificationService>(),
    biometricAuthenticator: getIt<BiometricAuthenticator>(),
    appInfoRepository: getIt<AppInfoRepository>(),
    graphqlCacheClearPort: getIt<GraphqlCacheClearPort>(),
    profileCacheControlsPort: getIt<ProfileCacheControlsPort>(),
    counterSyncDiagnosticsPort: getIt<CounterSyncDiagnosticsPort>(),
    pendingSyncRepository: getIt<PendingSyncRepository>(),
    profileRepository: getIt<ProfileRepository>(),
    chartRepository: getIt<ChartRepository>(),
  );
}

AuxiliaryRouteFactory resolveAuxiliaryRouteFactory({
  AuthRepository? authRepository,
  TimerService? timerService,
}) {
  final AuthRepository resolvedAuthRepository =
      authRepository ?? getIt<AuthRepository>();
  final TimerService resolvedTimerService =
      timerService ?? getIt<TimerService>();

  return AuxiliaryRouteFactory(
    searchRepository: getIt<SearchRepository>(),
    timerService: resolvedTimerService,
    createTodoRepository: () => getIt<TodoRepository>(),
    authRepository: resolvedAuthRepository,
    walletConnectAuthRepository: getIt<WalletConnectAuthRepository>(),
    supabaseAuthRepository: getIt<SupabaseAuthRepository>(),
    sessionCoordinator: getIt.isRegistered<SessionLifecycleCoordinator>()
        ? getIt<SessionLifecycleCoordinator>()
        : null,
    websocketRepository: getIt<WebsocketRepository>(),
    mapLocationRepository: getIt<MapLocationRepository>(),
    createRealtimeMarketRepository: createScopedRealtimeMarketRepository,
  );
}
