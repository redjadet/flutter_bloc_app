import 'package:core/core.dart';
import 'package:flutter_bloc_app/app/app_scope.dart';
import 'package:flutter_bloc_app/app/auth/session_lifecycle_coordinator.dart';
import 'package:flutter_bloc_app/app/config/supabase_config_coordinator.dart';
import 'package:flutter_bloc_app/app/services/app_memory_service.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_repository.dart';
import 'package:flutter_bloc_app/features/deeplink/deeplink.dart';
import 'package:flutter_bloc_app/features/remote_config/presentation/cubit/remote_config_cubit.dart';
import 'package:flutter_bloc_app/features/settings/settings.dart';
import 'package:networking/networking.dart';

/// Explicit app-shell dependencies for [AppScope].
///
/// Resolved once at the composition root so presentation widgets do not query
/// the service locator.
class AppScopeDependencies {
  const AppScopeDependencies({
    required this.syncCoordinator,
    required this.memoryService,
    required this.timerService,
    required this.authRepository,
    required this.sessionCoordinator,
    required this.networkStatusService,
    required this.localeRepository,
    required this.themeRepository,
    required this.createRemoteConfigCubit,
    required this.deepLinkService,
    required this.deepLinkParser,
    required this.retryNotificationService,
    this.supabaseConfigCoordinator,
  });

  final BackgroundSyncCoordinator syncCoordinator;
  final AppMemoryService memoryService;
  final TimerService timerService;
  final AuthRepository authRepository;
  final SessionLifecycleCoordinator sessionCoordinator;
  final NetworkStatusService networkStatusService;
  final LocaleRepository localeRepository;
  final ThemeRepository themeRepository;
  final RemoteConfigCubit Function() createRemoteConfigCubit;
  final DeepLinkService deepLinkService;
  final DeepLinkParser deepLinkParser;
  final RetryNotificationService retryNotificationService;
  final SupabaseConfigCoordinator? supabaseConfigCoordinator;
}
