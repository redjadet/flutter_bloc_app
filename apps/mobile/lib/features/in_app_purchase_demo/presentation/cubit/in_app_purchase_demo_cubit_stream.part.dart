part of 'in_app_purchase_demo_cubit.dart';

mixin _InAppPurchaseDemoCubitStream on _InAppPurchaseDemoCubitBase {
  Future<void> toggleRepository({required bool useFake}) async {
    if (state.isBusy) return;
    _attempt++;
    emit(
      state.copyWith(
        useFakeRepository: useFake,
        lastResult: null,
        errorMessage: null,
      ),
    );
    final StreamSubscription<IapPurchaseResult>? previousSubscription = _sub;
    _sub = null;
    await cancelRegisteredSubscription(previousSubscription);
    _subscribePurchaseResults();
    await initialize();
  }

  void _subscribePurchaseResults() {
    _sub = registerSubscription(
      _activeRepository.watchPurchaseResults().listen(
        _onPurchaseResult,
        onError: _onPurchaseStreamError,
      ),
    );
  }

  Future<void> _onPurchaseResult(IapPurchaseResult result) async {
    if (isClosed) return;
    final bool isPending = result.maybeWhen(
      pending: (_, _) => true,
      orElse: () => false,
    );
    emit(
      state.copyWith(
        lastResult: result,
        isBusy: isPending && state.isBusy,
        status: isPending ? state.status : InAppPurchaseDemoStatus.ready,
      ),
    );
    await refreshEntitlements();
  }

  void _onPurchaseStreamError(Object error, StackTrace stackTrace) {
    AppLogger.error(
      'InAppPurchaseDemoCubit.watchPurchaseResults',
      error,
      stackTrace,
    );
    if (isClosed) return;
    emit(
      state.copyWith(
        status: InAppPurchaseDemoStatus.error,
        isBusy: false,
        errorMessage: NetworkErrorMapper.getErrorMessage(error),
      ),
    );
  }

  @override
  Future<void> close() async {
    final StreamSubscription<IapPurchaseResult>? subscription = _sub;
    _sub = null;
    await cancelRegisteredSubscription(subscription);
    await super.close();
  }
}
