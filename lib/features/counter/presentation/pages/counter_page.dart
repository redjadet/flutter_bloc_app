import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/counter/counter.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_context_extensions.dart';
import 'package:flutter_bloc_app/shared/utils/app_error.dart';
import 'package:go_router/go_router.dart';

part 'counter_page_content.dart';

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
    WidgetsBinding.instance.addObserver(this);
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
    _disposeCannotGoBelowZeroSnackBarDelayHandle();
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
        unawaited(_flushSyncIfPossible(context));
        break;
      case AppLifecycleState.resumed:
        cubit.resumeAutoDecrement();
    }
  }

  @override
  Widget build(final BuildContext context) {
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

  List<TypeSafeBlocListener<CounterCubit, CounterState>> _buildListeners() {
    return <TypeSafeBlocListener<CounterCubit, CounterState>>[
      TypeSafeBlocListener<CounterCubit, CounterState>(
        listenWhen: (final prev, final curr) => prev.error != curr.error,
        listener: _handleCounterErrorStateChanged,
      ),
      TypeSafeBlocListener<CounterCubit, CounterState>(
        listenWhen: (final prev, final curr) => curr.count > prev.count,
        listener: _handleCounterIncremented,
      ),
      TypeSafeBlocListener<CounterCubit, CounterState>(
        listenWhen: (final prev, final curr) =>
            prev.count == 0 && curr.count > 0,
        listener: _handleCounterRecoveredFromZero,
      ),
      TypeSafeBlocListener<CounterCubit, CounterState>(
        listenWhen: (final prev, final curr) => prev.count != curr.count,
        listener: _handleCounterCountChanged,
      ),
    ];
  }

  Future<void> _flushSyncIfPossible(final BuildContext context) async {
    try {
      final SyncStatusCubit syncCubit = context.cubit<SyncStatusCubit>();
      if (!syncCubit.state.isOnline) {
        return;
      }

      final DateTime now = DateTime.now();
      final DateTime? lastFlush = _lastFlushTime;
      if (lastFlush != null &&
          now.difference(lastFlush) < _flushThrottleDuration) {
        return;
      }
      _lastFlushTime = now;

      unawaited(syncCubit.flush());
    } on Object {
      // SyncStatusCubit not available in this subtree (e.g., tests/minimal shells).
    }
  }

  void _handleCounterErrorStateChanged(
    final BuildContext context,
    final CounterState state,
  ) {
    final CounterError? error = state.error;
    if (error == null) {
      return;
    }

    final String localizedMessage = counterErrorMessage(
      context.l10n,
      error,
    );
    if (error.type == CounterErrorType.cannotGoBelowZero) {
      if (!_isCannotGoBelowZeroSnackBarVisible) {
        _showCannotGoBelowZeroSnackBar(localizedMessage);
      }
      return;
    }

    ErrorHandling.handleCubitError(
      context,
      UnknownError(
        message: localizedMessage,
        cause: error,
      ),
      customMessage: localizedMessage,
      onRetry: () => CubitHelpers.safeExecute<CounterCubit, CounterState>(
        context,
        (final cubit) => cubit.clearError(),
      ),
    );
  }

  void _handleCounterIncremented(
    final BuildContext context,
    final CounterState state,
  ) {
    _confettiController.play();
  }

  void _handleCounterRecoveredFromZero(
    final BuildContext context,
    final CounterState state,
  ) {
    _isCannotGoBelowZeroSnackBarVisible = false;
    ErrorHandling.clearSnackBars(context);
  }

  void _handleCounterCountChanged(
    final BuildContext context,
    final CounterState state,
  ) {
    // check-ignore: listener callback is event-driven, not a build side effect
    unawaited(_flushSyncIfPossible(context));
  }

  void _disposeCannotGoBelowZeroSnackBarDelayHandle() {
    _snackBarHideTimerHandle?.dispose();
    _snackBarHideTimerHandle = null;
  }

  void _hideCannotGoBelowZeroSnackBar() {
    if (!mounted) {
      return;
    }
    _disposeCannotGoBelowZeroSnackBarDelayHandle();
    ErrorHandling.hideCurrentSnackBar(context);
  }

  void _handleCannotGoBelowZeroSnackBarClosed() {
    _disposeCannotGoBelowZeroSnackBarDelayHandle();
    if (mounted) {
      setState(() => _isCannotGoBelowZeroSnackBarVisible = false);
    }
  }

  void _scheduleCannotGoBelowZeroSnackBarHide(final TimerService timerService) {
    _snackBarHideTimerHandle = timerService.runOnce(
      _cannotGoBelowZeroSnackBarDuration,
      _hideCannotGoBelowZeroSnackBar,
    );
  }

  void _showCannotGoBelowZeroSnackBar(final String message) {
    _disposeCannotGoBelowZeroSnackBarDelayHandle();

    final ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
    controller = ErrorHandling.showErrorSnackBar(
      context,
      message,
      duration: _cannotGoBelowZeroSnackBarDuration,
    );
    if (controller == null) {
      return;
    }
    _isCannotGoBelowZeroSnackBarVisible = true;

    final TimerService timerService =
        widget.timerService ?? DefaultTimerService();
    _scheduleCannotGoBelowZeroSnackBarHide(timerService);

    unawaited(
      controller.closed.whenComplete(_handleCannotGoBelowZeroSnackBarClosed),
    );
  }

  Future<void> _handleOpenSettings(final BuildContext context) async {
    final l10n = context.l10n;
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
