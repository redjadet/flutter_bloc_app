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
class const AppScopeDependencies({
  required final BackgroundSyncCoordinator syncCoordinator,
  required final AppMemoryService memoryService,
  required final TimerService timerService,
  required final AuthRepository authRepository,
  required final SessionLifecycleCoordinator sessionCoordinator,
  required final NetworkStatusService networkStatusService,
  required final LocaleRepository localeRepository,
  required final ThemeRepository themeRepository,
  required final RemoteConfigCubit Function() createRemoteConfigCubit,
  required final DeepLinkService deepLinkService,
  required final DeepLinkParser deepLinkParser,
  required final RetryNotificationService retryNotificationService,
  final SupabaseConfigCoordinator? supabaseConfigCoordinator,
});
