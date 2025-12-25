import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/counter/counter.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
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
  DateTime? _lastFlushTime;
  static const Duration _flushThrottleDuration = Duration(milliseconds: 500);

  Future<void> _flushSyncIfPossible(final BuildContext context) async {
    try {
      final SyncStatusCubit syncCubit = context.read<SyncStatusCubit>();
      if (!syncCubit.state.isOnline) {
        return;
      }

      // Throttle flushes to prevent concurrent calls
      final DateTime now = DateTime.now();
      if (_lastFlushTime != null &&
          now.difference(_lastFlushTime!) < _flushThrottleDuration) {
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
    _showFlavorBadge = FlavorManager.I.flavor != Flavor.prod;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (!mounted) return;
    final CounterCubit cubit = context.read<CounterCubit>();
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
        BlocListener<CounterCubit, CounterState>(
          listenWhen: (final prev, final curr) => prev.error != curr.error,
          listener: (final context, final state) {
            final error = state.error;
            if (error != null) {
              final String localizedMessage = counterErrorMessage(l10n, error);
              ErrorHandling.handleCubitError(
                context,
                error,
                customMessage: localizedMessage,
                onRetry: () =>
                    CubitHelpers.safeExecute<CounterCubit, CounterState>(
                      context,
                      (final cubit) => cubit.clearError(),
                    ),
              );
            }
          },
        ),
        BlocListener<CounterCubit, CounterState>(
          listenWhen: (final prev, final curr) =>
              prev.count == 0 && curr.count > 0,
          listener: (final context, final state) {
            ErrorHandling.clearSnackBars(context);
          },
        ),
        BlocListener<CounterCubit, CounterState>(
          listenWhen: (final prev, final curr) => prev.count != curr.count,
          listener: (final context, final state) async {
            // Kick off a sync flush immediately when counter changes, but only if SyncStatusCubit is available.
            unawaited(_flushSyncIfPossible(context));
          },
        ),
      ],
      child: Scaffold(
        appBar: CounterPageAppBar(
          title: widget.title,
          onOpenSettings: () => _handleOpenSettings(context),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: context.pagePadding,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
                child: CounterPageBody(
                  theme: theme,
                  l10n: l10n,
                  showFlavorBadge: _showFlavorBadge,
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: const CountdownBar(),
        floatingActionButton: const CounterActions(),
      ),
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
