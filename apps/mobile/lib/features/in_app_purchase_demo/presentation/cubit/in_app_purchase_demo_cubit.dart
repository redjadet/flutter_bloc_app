import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/utils/bloc/cubit_subscription_mixin.dart';
import 'package:flutter_bloc_app/app/utils/network_error_mapper.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_demo_controls.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_demo_controls_port.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_product.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_purchase_result.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/in_app_purchase_repository.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/presentation/cubit/in_app_purchase_demo_state.dart';

// Keep ctor param names for `super.` forwarding from InAppPurchaseDemoCubit.
// ignore_for_file: prefer_initializing_formals

part 'in_app_purchase_demo_cubit_stream.part.dart';

class InAppPurchaseDemoCubit extends _InAppPurchaseDemoCubitBase
    with _InAppPurchaseDemoCubitStream {
  InAppPurchaseDemoCubit({
    required super.fakeRepository,
    required super.realRepository,
    super.fakeOutcomeControls,
    super.realDemoControls,
  }) {
    _subscribePurchaseResults();
  }
}

abstract class _InAppPurchaseDemoCubitBase extends Cubit<InAppPurchaseDemoState>
    with CubitSubscriptionMixin<InAppPurchaseDemoState> {
  _InAppPurchaseDemoCubitBase({
    required InAppPurchaseRepository fakeRepository,
    required InAppPurchaseRepository realRepository,
    IapFakeOutcomePort? fakeOutcomeControls,
    IapDemoControlsPort? realDemoControls,
  }) : _fakeRepository = fakeRepository,
       _realRepository = realRepository,
       _fakeOutcomeControls = fakeOutcomeControls,
       _realDemoControls = realDemoControls,
       super(const InAppPurchaseDemoState());

  final InAppPurchaseRepository _fakeRepository;
  final InAppPurchaseRepository _realRepository;
  final IapFakeOutcomePort? _fakeOutcomeControls;
  final IapDemoControlsPort? _realDemoControls;

  // ignore: cancel_subscriptions - Lifecycle is centralized via CubitSubscriptionMixin.
  StreamSubscription<IapPurchaseResult>? _sub;
  int _attempt = 0;

  InAppPurchaseRepository get _activeRepository =>
      state.useFakeRepository ? _fakeRepository : _realRepository;

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
    } on Object catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: InAppPurchaseDemoStatus.error,
          errorMessage: NetworkErrorMapper.getErrorMessage(e),
        ),
      );
    }
  }

  void _resetActiveDemoState() {
    if (state.useFakeRepository) {
      _fakeOutcomeControls?.resetDemoState();
      return;
    }
    _realDemoControls?.resetDemoState();
  }

  void setForcedOutcome(IapDemoForcedOutcome outcome) {
    final fakeControls = _fakeOutcomeControls;
    if (fakeControls == null) return;
    fakeControls.forcedOutcome = outcome;
    if (isClosed) return;
    emit(state.copyWith(forcedOutcome: outcome));
  }

  Future<void> buy(IapProduct product) async {
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
      if (attempt == _attempt && !isClosed) {
        emit(state.copyWith(lastResult: result));
      }
    } on Object catch (e) {
      if (attempt != _attempt || isClosed) return;
      emit(
        state.copyWith(
          lastResult: IapPurchaseResult.failure(
            productId: product.id,
            message: NetworkErrorMapper.getErrorMessage(e),
          ),
        ),
      );
    } finally {
      if (attempt == _attempt && !isClosed) {
        emit(
          state.copyWith(
            isBusy: false,
            status: InAppPurchaseDemoStatus.ready,
          ),
        );
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
      if (attempt != _attempt || isClosed) return;
      emit(state.copyWith(entitlements: entitlements, lastResult: null));
    } on Object catch (e) {
      if (attempt != _attempt || isClosed) return;
      emit(
        state.copyWith(errorMessage: NetworkErrorMapper.getErrorMessage(e)),
      );
    } finally {
      if (attempt == _attempt && !isClosed) {
        emit(
          state.copyWith(
            isBusy: false,
            status: InAppPurchaseDemoStatus.ready,
          ),
        );
      }
    }
  }

  Future<void> refreshEntitlements() async {
    try {
      final entitlements = await _activeRepository.refreshEntitlements();
      if (isClosed) return;
      emit(state.copyWith(entitlements: entitlements, errorMessage: null));
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'InAppPurchaseDemoCubit.refreshEntitlements',
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
  }
}
