import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/responsive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/app_config.dart';
import 'package:flutter_bloc_app/app/composition/app_scope_dependencies.dart';
import 'package:flutter_bloc_app/app/config/supabase_config_coordinator.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/presentation/cubit/app_auth_cubit.dart';
import 'package:flutter_bloc_app/app/presentation/cubit/app_auth_state.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/services/app_memory_service.dart';
import 'package:flutter_bloc_app/app/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/app/utils/bloc_provider_helpers.dart';
import 'package:flutter_bloc_app/app/widgets/retry_snackbar_listener.dart';
import 'package:flutter_bloc_app/features/deeplink/deeplink.dart';
import 'package:flutter_bloc_app/features/settings/settings.dart';
import 'package:go_router/go_router.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:networking/networking.dart';
import 'package:utilities/utilities.dart';

class AppScope extends StatefulWidget {
  const AppScope({
    required this.router,
    required this.dependencies,
    super.key,
  });

  final GoRouter router;
  final AppScopeDependencies dependencies;

  @override
  State<AppScope> createState() => _AppScopeState();
}

class _AppScopeState extends State<AppScope> with WidgetsBindingObserver {
  late final BackgroundSyncCoordinator _syncCoordinator;
  SupabaseConfigCoordinator? _supabaseConfigCoordinator;
  late final AppMemoryService _memoryService;
  late final TimerService _timerService;
  late final AppAuthCubit _appAuthCubit;
  TimerDisposable? _resumeDebounceHandle;
  TimerDisposable? _backgroundTrimHandle;

  AppScopeDependencies get _deps => widget.dependencies;

  @override
  void initState() {
    super.initState();
    _syncCoordinator = _deps.syncCoordinator;
    _supabaseConfigCoordinator = _deps.supabaseConfigCoordinator;
    _memoryService = _deps.memoryService;
    _timerService = _deps.timerService;
    _appAuthCubit = AppAuthCubit(
      authRepository: _deps.authRepository,
      sessionCoordinator: _deps.sessionCoordinator,
    );
    WidgetsBinding.instance.addObserver(this);
    unawaited(_appAuthCubit.start());
    final coordinator = _supabaseConfigCoordinator;
    if (coordinator != null) {
      unawaited(coordinator.start());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
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
    unawaited(_appAuthCubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => SyncStatusCubit(
          networkStatusService: _deps.networkStatusService,
          coordinator: _syncCoordinator,
        ),
      ),
      BlocProviderHelpers.providerWithAsyncInit<LocaleCubit>(
        create: () => LocaleCubit(repository: _deps.localeRepository),
        init: (cubit) => cubit.loadInitial(),
      ),
      BlocProviderHelpers.providerWithAsyncInit<ThemeCubit>(
        create: () => ThemeCubit(repository: _deps.themeRepository),
        init: (cubit) => cubit.loadInitial(),
      ),
      BlocProvider(
        create: (_) => _deps.createRemoteConfigCubit(),
      ),
      BlocProvider.value(value: _appAuthCubit),
    ],
    child: _AppAuthSessionListener(
      router: widget.router,
      child: DeepLinkListener(
        router: widget.router,
        service: _deps.deepLinkService,
        parser: _deps.deepLinkParser,
        child: ResponsiveScope(
          child: TypeSafeBlocBuilder<LocaleCubit, Locale?>(
            builder: (context, locale) =>
                TypeSafeBlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, themeMode) => AppConfig.createMaterialApp(
                    themeMode: themeMode,
                    router: widget.router,
                    locale: locale,
                    appOverlayBuilder: (context, child) =>
                        RetrySnackBarListener(
                          notifications:
                              _deps.retryNotificationService.notifications,
                          child: child ?? const SizedBox.shrink(),
                        ),
                  ),
                ),
          ),
        ),
      ),
    ),
  );
}

class _AppAuthSessionListener extends StatelessWidget {
  const _AppAuthSessionListener({
    required this.router,
    required this.child,
  });

  final GoRouter router;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppAuthCubit, AppAuthState>(
      listenWhen: (previous, current) => current.maybeMap(
        sessionExpired: (_) => true,
        orElse: () => false,
      ),
      listener: (context, state) {
        state.maybeMap(
          sessionExpired: (_) {
            final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(
              context,
            );
            messenger?.showSnackBar(
              SnackBar(content: Text(context.l10n.sessionExpiredMessage)),
            );
            context.cubit<AppAuthCubit>().acknowledgeSessionExpired();
            router.go(AppRoutes.authPath);
          },
          orElse: () {},
        );
      },
      child: child,
    );
  }
}
