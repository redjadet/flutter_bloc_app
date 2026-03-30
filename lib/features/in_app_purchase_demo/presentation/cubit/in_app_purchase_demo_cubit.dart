import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/data/fake_in_app_purchase_repository.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/data/flutter_in_app_purchase_repository.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_demo_controls.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_product.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_purchase_result.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/in_app_purchase_repository.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/presentation/cubit/in_app_purchase_demo_state.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_subscription_mixin.dart';

class InAppPurchaseDemoCubit extends Cubit<InAppPurchaseDemoState>
    with CubitSubscriptionMixin<InAppPurchaseDemoState> {
  InAppPurchaseDemoCubit({
    required final InAppPurchaseRepository fakeRepository,
    required final InAppPurchaseRepository realRepository,
  }) : _fakeRepository = fakeRepository,
       _realRepository = realRepository,
       super(const InAppPurchaseDemoState()) {
    _sub = registerSubscription(
      _activeRepository.watchPurchaseResults().listen(
        _onPurchaseResult,
        onError: (final Object error, final StackTrace stackTrace) {},
      ),
    );
  }

  final InAppPurchaseRepository _fakeRepository;
  final InAppPurchaseRepository _realRepository;

  // ignore: cancel_subscriptions - Lifecycle is centralized via CubitSubscriptionMixin.
  StreamSubscription<IapPurchaseResult>? _sub;
  int _attempt = 0;

  InAppPurchaseRepository get _activeRepository =>
      state.useFakeRepository ? _fakeRepository : _realRepository;

  FakeInAppPurchaseRepository? get _fakeRepoOrNull =>
      _fakeRepository is FakeInAppPurchaseRepository ? _fakeRepository : null;

  Future<void> initialize() async {
    _resetActiveDemoState();
    if (isClosed) return;
    emit(state.copyWith(status: InAppPurchaseDemoStatus.loadingProducts));
    try {
      final products = await _activeRepository.loadProducts();
      final entitlements = await _activeRepository.refreshEntitlements();
      if (isClosed) return;
      emit(
        state.copyWith(
          status: InAppPurchaseDemoStatus.ready,
          products: products,
          entitlements: entitlements,
          errorMessage: null,
        ),
      );
    } on Exception catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: InAppPurchaseDemoStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _resetActiveDemoState() {
    final active = _activeRepository;
    if (active is FakeInAppPurchaseRepository) {
      active.resetDemoState();
      return;
    }
    if (active is FlutterInAppPurchaseRepository) {
      active.resetDemoState();
      return;
    }
  }

  Future<void> toggleRepository({required final bool useFake}) async {
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
    _sub = registerSubscription(
      _activeRepository.watchPurchaseResults().listen(
        _onPurchaseResult,
        onError: (final Object error, final StackTrace stackTrace) {},
      ),
    );

    await initialize();
  }

  void setForcedOutcome(final IapDemoForcedOutcome outcome) {
    final fake = _fakeRepoOrNull;
    if (fake == null) return;
    fake.forcedOutcome = outcome;
    if (isClosed) return;
    emit(state.copyWith(forcedOutcome: outcome));
  }

  Future<void> buy(final IapProduct product) async {
    if (state.isBusy) return;
    final int attempt = ++_attempt;
    if (isClosed) return;
    emit(
      state.copyWith(
        status: InAppPurchaseDemoStatus.purchasing,
        isBusy: true,
        lastResult: null,
        errorMessage: null,
      ),
    );

    try {
      final result = await _activeRepository.purchase(product);
      // If repository returns an immediate result (fake repo), surface it.
      if (attempt == _attempt) {
        if (isClosed) return;
        emit(state.copyWith(lastResult: result));
      }
    } on Exception catch (e) {
      if (attempt != _attempt) return;
      if (isClosed) return;
      emit(
        state.copyWith(
          lastResult: IapPurchaseResult.failure(
            productId: product.id,
            message: e.toString(),
          ),
        ),
      );
    } finally {
      if (attempt == _attempt) {
        if (!isClosed) {
          emit(
            state.copyWith(
              isBusy: false,
              status: InAppPurchaseDemoStatus.ready,
            ),
          );
        }
      }
    }
  }

  Future<void> restore() async {
    if (state.isBusy) return;
    final int attempt = ++_attempt;
    if (isClosed) return;
    emit(
      state.copyWith(
        status: InAppPurchaseDemoStatus.restoring,
        isBusy: true,
        lastResult: null,
        errorMessage: null,
      ),
    );

    try {
      await _activeRepository.restorePurchases();
      final entitlements = await _activeRepository.refreshEntitlements();
      if (attempt != _attempt) return;
      if (isClosed) return;
      emit(
        state.copyWith(
          entitlements: entitlements,
          lastResult: null,
        ),
      );
    } on Exception catch (e) {
      if (attempt != _attempt) return;
      if (isClosed) return;
      emit(state.copyWith(errorMessage: e.toString()));
    } finally {
      if (attempt == _attempt) {
        if (!isClosed) {
          emit(
            state.copyWith(
              isBusy: false,
              status: InAppPurchaseDemoStatus.ready,
            ),
          );
        }
      }
    }
  }

  Future<void> refreshEntitlements() async {
    final entitlements = await _activeRepository.refreshEntitlements();
    if (isClosed) return;
    emit(state.copyWith(entitlements: entitlements));
  }

  Future<void> _onPurchaseResult(final IapPurchaseResult result) async {
    // Latest-attempt-wins: accept purchase stream updates but never regress busy state.
    if (isClosed) return;
    emit(state.copyWith(lastResult: result));
    await refreshEntitlements();
  }

  @override
  Future<void> close() async {
    final StreamSubscription<IapPurchaseResult>? subscription = _sub;
    _sub = null;
    await cancelRegisteredSubscription(subscription);
    await super.close();
  }
}
