import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/config/supabase_config_coordinator.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/deeplink/deeplink.dart';
import 'package:flutter_bloc_app/features/remote_config/presentation/cubit/remote_config_cubit.dart';
import 'package:flutter_bloc_app/features/settings/settings.dart';
import 'package:flutter_bloc_app/shared/responsive/responsive.dart';
import 'package:flutter_bloc_app/shared/services/app_memory_service.dart';
import 'package:flutter_bloc_app/shared/services/app_memory_trim_level.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/services/retry_notification_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/utils/bloc_provider_helpers.dart';
import 'package:flutter_bloc_app/shared/widgets/retry_snackbar_listener.dart';
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';
import 'package:go_router/go_router.dart';

class AppScope extends StatefulWidget {
  const AppScope({required this.router, super.key});

  final GoRouter router;

  @override
  State<AppScope> createState() => _AppScopeState();
}

class _AppScopeState extends State<AppScope> with WidgetsBindingObserver {
  late final BackgroundSyncCoordinator _syncCoordinator;
  SupabaseConfigCoordinator? _supabaseConfigCoordinator;
  late final AppMemoryService _memoryService;
  late final TimerService _timerService;
  TimerDisposable? _resumeDebounceHandle;
  TimerDisposable? _backgroundTrimHandle;

  @override
  void initState() {
    super.initState();
    // Ensure DI is configured when running tests that directly pump MyApp.
    ensureConfigured();
    _syncCoordinator = getIt<BackgroundSyncCoordinator>();
    if (getIt.isRegistered<SupabaseConfigCoordinator>()) {
      _supabaseConfigCoordinator = getIt<SupabaseConfigCoordinator>();
    }
    _memoryService = getIt<AppMemoryService>();
    _timerService = getIt<TimerService>();
    WidgetsBinding.instance.addObserver(this);
    final coordinator = _supabaseConfigCoordinator;
    if (coordinator != null) {
      unawaited(coordinator.start());
    }
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _backgroundTrimHandle?.dispose();
      _backgroundTrimHandle = null;
      _resumeDebounceHandle?.dispose();
      _resumeDebounceHandle = _timerService.runOnce(
        const Duration(milliseconds: 500),
        () => unawaited(_syncCoordinator.flush()),
      );
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _backgroundTrimHandle?.dispose();
      _backgroundTrimHandle = _timerService.runOnce(
        const Duration(milliseconds: 750),
        () => unawaited(
          _memoryService.trim(AppMemoryTrimLevel.background),
        ),
      );
    }
  }

  @override
  void didHaveMemoryPressure() {
    _backgroundTrimHandle?.dispose();
    _backgroundTrimHandle = null;
    unawaited(_memoryService.trim(AppMemoryTrimLevel.pressure));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resumeDebounceHandle?.dispose();
    _resumeDebounceHandle = null;
    _backgroundTrimHandle?.dispose();
    _backgroundTrimHandle = null;
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => SyncStatusCubit(
          networkStatusService: getIt<NetworkStatusService>(),
          coordinator: _syncCoordinator,
        ),
      ),
      BlocProviderHelpers.providerWithAsyncInit<LocaleCubit>(
        create: () => LocaleCubit(repository: getIt<LocaleRepository>()),
        init: (final cubit) => cubit.loadInitial(),
      ),
      BlocProviderHelpers.providerWithAsyncInit<ThemeCubit>(
        create: () => ThemeCubit(repository: getIt<ThemeRepository>()),
        init: (final cubit) => cubit.loadInitial(),
      ),
      BlocProvider(
        create: (_) => getIt<RemoteConfigCubit>(),
      ),
    ],
    child: DeepLinkListener(
      router: widget.router,
      service: getIt<DeepLinkService>(),
      parser: getIt<DeepLinkParser>(),
      child: ResponsiveScope(
        child: TypeSafeBlocBuilder<LocaleCubit, Locale?>(
          builder: (final context, final locale) =>
              TypeSafeBlocBuilder<ThemeCubit, ThemeMode>(
                builder: (final context, final themeMode) =>
                    AppConfig.createMaterialApp(
                      themeMode: themeMode,
                      router: widget.router,
                      locale: locale,
                      appOverlayBuilder: (final context, final child) =>
                          RetrySnackBarListener(
                            notifications:
                                getIt<RetryNotificationService>().notifications,
                            child: child ?? const SizedBox.shrink(),
                          ),
                    ),
              ),
        ),
      ),
    ),
  );
}
