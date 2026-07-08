import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/config/flavor.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/app/platform/biometric_authenticator.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/services/error_notification_service.dart';
import 'package:flutter_bloc_app/app/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/app/sync/sync_context_extensions.dart';
import 'package:flutter_bloc_app/app/theme/theme.dart';
import 'package:flutter_bloc_app/app/utils/bloc/cubit_helpers.dart';
import 'package:flutter_bloc_app/app/utils/context_utils.dart';
import 'package:flutter_bloc_app/app/utils/error_handling.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/app/widgets/type_safe_bloc_selector.dart';
import 'package:flutter_bloc_app/features/counter/counter.dart';
import 'package:go_router/go_router.dart';
import 'package:utilities/utilities.dart';

part 'counter_page_content.dart';
part 'counter_page_listeners.part.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({
    required this.title,
    required this.errorNotificationService,
    required this.biometricAuthenticator,
    this.timerService,
    super.key,
    this.optionalBanner,
  });

  final String title;
  final ErrorNotificationService errorNotificationService;
  final BiometricAuthenticator biometricAuthenticator;

  /// Used for snackbar hide delay; when null, [DefaultTimerService] is used.
  final TimerService? timerService;

  /// Optional banner slot; composed by the app/router (e.g. remote_config widget).
  final Widget? optionalBanner;

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> with WidgetsBindingObserver {
  late final bool _showFlavorBadge;
  late final ConfettiController _confettiController;
  late final _CounterPageListenerDelegate _listenerDelegate;
  DateTime? _lastFlushTime;
  bool _isCannotGoBelowZeroSnackBarVisible = false;
  bool _didEnsureSyncStarted = false;
  TimerDisposable? _snackBarHideTimerHandle;

  static const Duration _flushThrottleDuration = Duration(milliseconds: 500);
  static const Duration _cannotGoBelowZeroSnackBarDuration = Duration(
    seconds: 2,
  );

  @override
  void initState() {
    super.initState();
    _showFlavorBadge = FlavorManager.I.flavor != Flavor.prod;
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 800),
    );
    _listenerDelegate = _CounterPageListenerDelegate(this);
    WidgetsBinding.instance.addObserver(this);
  }

  void _markCannotGoBelowZeroSnackBarHidden() {
    if (!mounted) return;
    setState(() => _isCannotGoBelowZeroSnackBarVisible = false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didEnsureSyncStarted) {
      return;
    }
    _didEnsureSyncStarted = true;
    context.ensureSyncStartedIfAvailable();
  }

  @override
  void dispose() {
    _listenerDelegate.disposeCannotGoBelowZeroSnackBarDelayHandle();
    WidgetsBinding.instance.removeObserver(this);
    _confettiController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (!mounted) {
      return;
    }

    final CounterCubit cubit = context.cubit<CounterCubit>();
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        cubit.pauseAutoDecrement();
        unawaited(_listenerDelegate.flushSyncIfPossible(context));
        break;
      case AppLifecycleState.resumed:
        cubit.resumeAutoDecrement();
    }
  }

  @override
  Widget build(final BuildContext context) {
    final GoRouter? router = GoRouter.maybeOf(context);
    if (router == null) {
      return MultiBlocListener(
        listeners: _buildListeners(),
        child: _CounterPageContent(
          title: widget.title,
          showFlavorBadge: _showFlavorBadge,
          optionalBanner: widget.optionalBanner,
          confettiController: _confettiController,
          onOpenSettings: () => _handleOpenSettings(context),
        ),
      );
    }

    final String currentPath =
        router.routerDelegate.currentConfiguration.uri.path;
    final bool isActiveRoute = currentPath == AppRoutes.counterPath;

    return Offstage(
      offstage: !isActiveRoute,
      child: MultiBlocListener(
        listeners: _buildListeners(),
        child: _CounterPageContent(
          title: widget.title,
          showFlavorBadge: _showFlavorBadge,
          optionalBanner: widget.optionalBanner,
          confettiController: _confettiController,
          onOpenSettings: () => _handleOpenSettings(context),
        ),
      ),
    );
  }

  List<TypeSafeBlocListener<CounterCubit, CounterState>> _buildListeners() =>
      _listenerDelegate.buildListeners();

  Future<void> _handleOpenSettings(final BuildContext context) async {
    final l10n = context.l10n;
    if (kIsWeb) {
      unawaited(
        widget.errorNotificationService.showSnackBar(
          context,
          l10n.settingsBiometricUnavailable,
        ),
      );
      await context.pushNamed(AppRoutes.settings);
      return;
    }
    final bool authenticated = await widget.biometricAuthenticator.authenticate(
      localizedReason: l10n.settingsBiometricPrompt,
    );
    if (!context.mounted) {
      ContextUtils.logNotMounted('CounterPage._handleOpenSettings');
      return;
    }
    if (authenticated) {
      await context.pushNamed(AppRoutes.settings);
    } else {
      unawaited(
        widget.errorNotificationService.showSnackBar(
          context,
          l10n.settingsBiometricFailed,
        ),
      );
    }
  }
}
