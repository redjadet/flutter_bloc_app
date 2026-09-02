import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/app/utils/network_error_mapper.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/data/fake_in_app_purchase_repository.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_demo_controls.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_product.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_purchase_result.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/presentation/cubit/in_app_purchase_demo_cubit.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/presentation/cubit/in_app_purchase_demo_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_helpers.dart';

void main() {
  group('InAppPurchaseDemoCubit', () {
    late FakeInAppPurchaseRepository fakeRepo;

    setUp(() {
      fakeRepo =
          FakeInAppPurchaseRepository(
              delay: Duration.zero,
              clockNow: () => DateTime(2026, 1, 1),
              timerService: FakeTimerService(),
            )
            ..forcedOutcome = IapDemoForcedOutcome.success
            ..throwOnLoadProducts = false
            ..throwOnPurchase = null
            ..throwOnRefreshEntitlements = null;
    });

    tearDown(() async {
      await fakeRepo.dispose();
    });

    InAppPurchaseDemoCubit buildCubit() => InAppPurchaseDemoCubit(
      fakeRepository: fakeRepo,
      realRepository: fakeRepo,
      fakeOutcomeControls: fakeRepo,
      realDemoControls: fakeRepo,
    );

    blocTest<InAppPurchaseDemoCubit, InAppPurchaseDemoState>(
      'initialize loads products and entitlements',
      build: buildCubit,
      act: (cubit) => cubit.initialize(),
      expect: () => [
        isA<InAppPurchaseDemoState>().having(
          (s) => s.status,
          'status',
          InAppPurchaseDemoStatus.loadingProducts,
        ),
        isA<InAppPurchaseDemoState>().having(
          (s) => s.status,
          'status',
          InAppPurchaseDemoStatus.ready,
        ),
      ],
    );

    blocTest<InAppPurchaseDemoCubit, InAppPurchaseDemoState>(
      'buy updates entitlements for consumable',
      build: buildCubit,
      act: (cubit) async {
        await cubit.initialize();
        final products = cubit.state.products;
        final consumable = products.firstWhere(
          (p) => p.type == IapProductType.consumable,
        );
        await cubit.buy(consumable);
      },
      verify: (cubit) {
        expect(cubit.state.entitlements.credits, greaterThanOrEqualTo(100));
      },
    );

    blocTest<InAppPurchaseDemoCubit, InAppPurchaseDemoState>(
      'purchase stream error clears busy state and surfaces message',
      build: buildCubit,
      act: (cubit) async {
        await cubit.initialize();
        fakeRepo.simulatePurchaseStreamError(Exception('store stream failed'));
        await Future<void>.delayed(Duration.zero);
      },
      verify: (cubit) {
        expect(cubit.state.status, InAppPurchaseDemoStatus.error);
        expect(cubit.state.isBusy, isFalse);
        expect(
          cubit.state.errorMessage,
          NetworkErrorMapper.getErrorMessage(Exception('store stream failed')),
        );
      },
    );

    blocTest<InAppPurchaseDemoCubit, InAppPurchaseDemoState>(
      'terminal failure result clears busy state and returns to ready',
      build: buildCubit,
      act: (cubit) async {
        await cubit.initialize();
        final consumable = cubit.state.products.firstWhere(
          (p) => p.type == IapProductType.consumable,
        );
        fakeRepo.forcedOutcome = IapDemoForcedOutcome.success;
        final buyFuture = cubit.buy(consumable);
        await Future<void>.delayed(Duration.zero);
        fakeRepo.simulatePurchaseResult(
          IapPurchaseResult.failure(
            productId: consumable.id,
            message: 'purchase failed',
          ),
        );
        await buyFuture;
        await Future<void>.delayed(Duration.zero);
      },
      verify: (cubit) {
        expect(cubit.state.status, InAppPurchaseDemoStatus.ready);
        expect(cubit.state.isBusy, isFalse);
        expect(
          cubit.state.lastResult,
          isA<IapPurchaseResult>().having(
            (r) => r.maybeWhen(
              failure: (id, message) =>
                  id == IapDemoProductIds.consumableCredits100 &&
                  message == 'purchase failed',
              orElse: () => false,
            ),
            'failure result',
            isTrue,
          ),
        );
      },
    );

    blocTest<InAppPurchaseDemoCubit, InAppPurchaseDemoState>(
      'restore updates non-consumable and subscription entitlements',
      build: buildCubit,
      act: (cubit) async {
        await cubit.initialize();
        await cubit.restore();
      },
      verify: (cubit) {
        expect(cubit.state.entitlements.isPremiumOwned, isTrue);
        expect(cubit.state.entitlements.isSubscriptionActive, isTrue);
      },
    );

    blocTest<InAppPurchaseDemoCubit, InAppPurchaseDemoState>(
      'initialize completes with error when repository throws Error',
      build: buildCubit,
      act: (cubit) async {
        fakeRepo.throwOnLoadProducts = true;
        await cubit.initialize();
      },
      verify: (cubit) {
        expect(cubit.state.status, InAppPurchaseDemoStatus.error);
        expect(cubit.state.errorMessage, isNotNull);
      },
    );

    blocTest<InAppPurchaseDemoCubit, InAppPurchaseDemoState>(
      'buy completes with failure when repository throws Error',
      build: buildCubit,
      act: (cubit) async {
        await cubit.initialize();
        final product = cubit.state.products.first;
        fakeRepo.throwOnPurchase = StateError('purchase failed');
        await cubit.buy(product);
      },
      verify: (cubit) {
        expect(cubit.state.isBusy, isFalse);
        expect(
          cubit.state.lastResult,
          isA<IapPurchaseResult>().having(
            (r) => r.maybeWhen(
              failure: (_, message) =>
                  message ==
                  NetworkErrorMapper.getErrorMessage(
                    StateError('purchase failed'),
                  ),
              orElse: () => false,
            ),
            'failure',
            isTrue,
          ),
        );
      },
    );

    blocTest<InAppPurchaseDemoCubit, InAppPurchaseDemoState>(
      'purchase result followed by entitlement refresh Error surfaces error',
      build: buildCubit,
      act: (cubit) async {
        await cubit.initialize();
        fakeRepo.throwOnRefreshEntitlements = StateError('refresh failed');
        fakeRepo.simulatePurchaseResult(
          const IapPurchaseResult.success(
            productId: IapDemoProductIds.consumableCredits100,
          ),
        );
        await Future<void>.delayed(Duration.zero);
      },
      verify: (cubit) {
        expect(cubit.state.status, InAppPurchaseDemoStatus.error);
        expect(cubit.state.isBusy, isFalse);
        expect(
          cubit.state.errorMessage,
          NetworkErrorMapper.getErrorMessage(StateError('refresh failed')),
        );
      },
    );
  });
}
