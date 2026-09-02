part of 'in_app_purchase_demo_cubit.dart';

mixin _InAppPurchaseDemoCubitStream on _InAppPurchaseDemoCubitBase {
  Future<void> toggleRepository({required bool useFake}) async {
    if (isClosed || state.isBusy) return;
    _attempt++;
    _invalidatePurchaseSubscriptionGeneration();
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
    if (isClosed) return;
    _subscribePurchaseResults();
    await initialize();
  }

  void _subscribePurchaseResults() {
    final int subscriptionGeneration = _startPurchaseSubscriptionGeneration();
    _sub = registerSubscription(
      _activeRepository.watchPurchaseResults().listen(
        (result) => _onPurchaseResult(result, subscriptionGeneration),
        onError: (Object error, StackTrace stackTrace) =>
            _onPurchaseStreamError(error, stackTrace, subscriptionGeneration),
      ),
    );
  }

  Future<void> _onPurchaseResult(
    IapPurchaseResult result,
    int subscriptionGeneration,
  ) async {
    if (isClosed || !_isPurchaseSubscriptionCurrent(subscriptionGeneration)) {
      return;
    }
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
    await refreshEntitlements(subscriptionGeneration: subscriptionGeneration);
  }

  void _onPurchaseStreamError(
    Object error,
    StackTrace stackTrace,
    int subscriptionGeneration,
  ) {
    AppLogger.error(
      'InAppPurchaseDemoCubit.watchPurchaseResults',
      error,
      stackTrace,
    );
    if (isClosed || !_isPurchaseSubscriptionCurrent(subscriptionGeneration)) {
      return;
    }
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
    _invalidatePurchaseSubscriptionGeneration();
    final StreamSubscription<IapPurchaseResult>? subscription = _sub;
    _sub = null;
    await cancelRegisteredSubscription(subscription);
    await super.close();
  }
}
