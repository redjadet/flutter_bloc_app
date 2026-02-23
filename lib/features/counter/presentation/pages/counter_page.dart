import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/counter/counter.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_context_extensions.dart';
import 'package:go_router/go_router.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({
    required this.title,
    required this.errorNotificationService,
    required this.biometricAuthenticator,
    super.key,
  });
  final String title;
  final ErrorNotificationService errorNotificationService;
  final BiometricAuthenticator biometricAuthenticator;

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> with WidgetsBindingObserver {
  late final bool _showFlavorBadge;
  late final ConfettiController _confettiController;
  DateTime? _lastFlushTime;
  bool _isCannotGoBelowZeroSnackBarVisible = false;
  static const Duration _flushThrottleDuration = Duration(milliseconds: 500);
  static const Duration _cannotGoBelowZeroSnackBarDuration = Duration(
    seconds: 2,
  );

  Future<void> _flushSyncIfPossible(final BuildContext context) async {
    try {
      final SyncStatusCubit syncCubit = context.cubit<SyncStatusCubit>();
      if (!syncCubit.state.isOnline) {
        return;
      }

      // Throttle flushes to prevent concurrent calls
      final DateTime now = DateTime.now();
      final DateTime? lastFlush = _lastFlushTime;
      if (lastFlush != null && now.difference(lastFlush) < _flushThrottleDuration) {
        return;
      }
      _lastFlushTime = now;

      unawaited(syncCubit.flush());
    } on Object {
      // SyncStatusCubit not available in this subtree (e.g., tests/minimal shells).
    }
  }

  @override
  void initState() {
    super.initState();
    context.ensureSyncStartedIfAvailable();
    _showFlavorBadge = FlavorManager.I.flavor != Flavor.prod;
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 800),
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _confettiController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (!mounted) return;
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
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    return MultiBlocListener(
      listeners: [
        TypeSafeBlocListener<CounterCubit, CounterState>(
          listenWhen: (final prev, final curr) => prev.error != curr.error,
          listener: (final context, final state) {
            final error = state.error;
            if (error case final currentError?) {
              final String localizedMessage = counterErrorMessage(
                l10n,
                currentError,
              );
              if (currentError.type == CounterErrorType.cannotGoBelowZero) {
                if (!_isCannotGoBelowZeroSnackBarVisible) {
                  _showCannotGoBelowZeroSnackBar(localizedMessage);
                }
                return;
              }
              ErrorHandling.handleCubitError(
                context,
                currentError,
                customMessage: localizedMessage,
                onRetry: () => CubitHelpers.safeExecute<CounterCubit, CounterState>(
                  context,
                  (final cubit) => cubit.clearError(),
                ),
              );
            }
          },
        ),
        TypeSafeBlocListener<CounterCubit, CounterState>(
          listenWhen: (final prev, final curr) => curr.count > prev.count,
          listener: (final context, final state) {
            _confettiController.play();
          },
        ),
        TypeSafeBlocListener<CounterCubit, CounterState>(
          listenWhen: (final prev, final curr) => prev.count == 0 && curr.count > 0,
          listener: (final context, final state) {
            _isCannotGoBelowZeroSnackBarVisible = false;
            ErrorHandling.clearSnackBars(context);
          },
        ),
        TypeSafeBlocListener<CounterCubit, CounterState>(
          listenWhen: (final prev, final curr) => prev.count != curr.count,
          listener: (final context, final state) async {
            // Kick off a sync flush immediately when counter changes, but only if SyncStatusCubit is available.
            // check-ignore: listener callback is event-driven, not a build side effect
            unawaited(_flushSyncIfPossible(context));
          },
        ),
      ],
      child: Stack(
        children: [
          Scaffold(
            appBar: CounterPageAppBar(
              title: widget.title,
              onOpenSettings: () => _handleOpenSettings(context),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: context.pagePadding,
                child: CommonMaxWidth(
                  child: CounterPageBody(
                    theme: theme,
                    l10n: l10n,
                    showFlavorBadge: _showFlavorBadge,
                  ),
                ),
              ),
            ),
            bottomNavigationBar: const CountdownBar(),
            floatingActionButton: const CounterActions(),
          ),
          IgnorePointer(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                colors:
                    Theme.of(
                      context,
                    ).extension<ConfettiTheme>()?.particleColors ??
                    defaultConfettiParticleColors,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCannotGoBelowZeroSnackBar(final String message) {
    final ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? controller =
        ErrorHandling.showErrorSnackBar(
          context,
          message,
          duration: _cannotGoBelowZeroSnackBarDuration,
        );
    if (controller == null) {
      return;
    }
    _isCannotGoBelowZeroSnackBarVisible = true;
    bool isClosed = false;
    unawaited(
      controller.closed.whenComplete(() {
        if (mounted) {
          _isCannotGoBelowZeroSnackBarVisible = false;
        }
        isClosed = true;
      }),
    );
    unawaited(
      Future<void>.delayed(_cannotGoBelowZeroSnackBarDuration, () {
        if (!mounted || isClosed) {
          return;
        }
        final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(
          context,
        );
        messenger?.hideCurrentSnackBar(reason: SnackBarClosedReason.timeout);
      }),
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
