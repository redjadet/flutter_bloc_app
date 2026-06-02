part of 'counter_page.dart';

final class _CounterPageListenerDelegate {
  _CounterPageListenerDelegate(this._state);

  final _CounterPageState _state;

  List<TypeSafeBlocListener<CounterCubit, CounterState>> buildListeners() {
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

  Future<void> flushSyncIfPossible(final BuildContext context) async {
    try {
      final SyncStatusCubit syncCubit = context.cubit<SyncStatusCubit>();
      if (!syncCubit.state.isOnline) {
        return;
      }

      final DateTime now = DateTime.now();
      final DateTime? lastFlush = _state._lastFlushTime;
      if (lastFlush != null &&
          now.difference(lastFlush) <
              _CounterPageState._flushThrottleDuration) {
        return;
      }
      _state._lastFlushTime = now;

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
      if (!_state._isCannotGoBelowZeroSnackBarVisible) {
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
    _state._confettiController.play();
  }

  void _handleCounterRecoveredFromZero(
    final BuildContext context,
    final CounterState state,
  ) {
    _state._isCannotGoBelowZeroSnackBarVisible = false;
    ErrorHandling.clearSnackBars(context);
  }

  void _handleCounterCountChanged(
    final BuildContext context,
    final CounterState state,
  ) {
    // check-ignore: listener callback is event-driven, not a build side effect
    unawaited(flushSyncIfPossible(context));
  }

  void disposeCannotGoBelowZeroSnackBarDelayHandle() {
    _state._snackBarHideTimerHandle?.dispose();
    _state._snackBarHideTimerHandle = null;
  }

  void _hideCannotGoBelowZeroSnackBar() {
    if (!_state.mounted) {
      return;
    }
    disposeCannotGoBelowZeroSnackBarDelayHandle();
    ErrorHandling.hideCurrentSnackBar(_state.context);
  }

  void _handleCannotGoBelowZeroSnackBarClosed() {
    disposeCannotGoBelowZeroSnackBarDelayHandle();
    if (_state.mounted) {
      _state._markCannotGoBelowZeroSnackBarHidden();
    }
  }

  void _scheduleCannotGoBelowZeroSnackBarHide(final TimerService timerService) {
    _state._snackBarHideTimerHandle = timerService.runOnce(
      _CounterPageState._cannotGoBelowZeroSnackBarDuration,
      _hideCannotGoBelowZeroSnackBar,
    );
  }

  void _showCannotGoBelowZeroSnackBar(final String message) {
    disposeCannotGoBelowZeroSnackBarDelayHandle();

    final ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
    controller = ErrorHandling.showErrorSnackBar(
      _state.context,
      message,
      duration: _CounterPageState._cannotGoBelowZeroSnackBarDuration,
    );
    if (controller == null) {
      return;
    }
    _state._isCannotGoBelowZeroSnackBarVisible = true;

    final TimerService timerService =
        _state.widget.timerService ?? DefaultTimerService();
    _scheduleCannotGoBelowZeroSnackBarHide(timerService);

    unawaited(
      controller.closed.whenComplete(_handleCannotGoBelowZeroSnackBarClosed),
    );
  }
}
