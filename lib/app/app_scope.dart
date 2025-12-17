import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/features.dart';
import 'package:flutter_bloc_app/features/remote_config/presentation/cubit/remote_config_cubit.dart';
import 'package:flutter_bloc_app/shared/responsive/responsive.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/services/retry_notification_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/utils/bloc_provider_helpers.dart';
import 'package:flutter_bloc_app/shared/widgets/retry_snackbar_listener.dart';
import 'package:go_router/go_router.dart';

class AppScope extends StatelessWidget {
  const AppScope({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(final BuildContext context) {
    // Ensure DI is configured when running tests that directly pump MyApp
    ensureConfigured();
    final BackgroundSyncCoordinator syncCoordinator =
        getIt<BackgroundSyncCoordinator>();
    unawaited(syncCoordinator.start());
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SyncStatusCubit(
            networkStatusService: getIt<NetworkStatusService>(),
            coordinator: syncCoordinator,
          ),
        ),
        BlocProviderHelpers.providerWithAsyncInit<CounterCubit>(
          create: () => CounterCubit(
            repository: getIt<CounterRepository>(),
            timerService: getIt(),
            loadDelay: FlavorManager.I.isDev
                ? AppConstants.devSkeletonDelay
                : Duration.zero,
          ),
          init: (cubit) => cubit.loadInitial(),
        ),
        BlocProviderHelpers.providerWithAsyncInit<LocaleCubit>(
          create: () => LocaleCubit(repository: getIt<LocaleRepository>()),
          init: (cubit) => cubit.loadInitial(),
        ),
        BlocProviderHelpers.providerWithAsyncInit<ThemeCubit>(
          create: () => ThemeCubit(repository: getIt<ThemeRepository>()),
          init: (cubit) => cubit.loadInitial(),
        ),
        BlocProviderHelpers.providerWithAsyncInit<RemoteConfigCubit>(
          create: () => getIt<RemoteConfigCubit>(),
          init: (cubit) => cubit.initialize(),
        ),
      ],
      child: DeepLinkListener(
        router: router,
        service: getIt<DeepLinkService>(),
        parser: getIt<DeepLinkParser>(),
        child: ResponsiveScope(
          child: BlocBuilder<LocaleCubit, Locale?>(
            builder: (final context, final locale) =>
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (final context, final themeMode) =>
                      AppConfig.createMaterialApp(
                        themeMode: themeMode,
                        router: router,
                        locale: locale,
                        appOverlayBuilder: (final context, final child) =>
                            RetrySnackBarListener(
                              notifications: getIt<RetryNotificationService>()
                                  .notifications,
                              child: child ?? const SizedBox.shrink(),
                            ),
                      ),
                ),
          ),
        ),
      ),
    );
  }
}
