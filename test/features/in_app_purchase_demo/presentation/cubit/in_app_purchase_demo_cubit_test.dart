import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/data/fake_in_app_purchase_repository.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_demo_controls.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_product.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/presentation/cubit/in_app_purchase_demo_cubit.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/presentation/cubit/in_app_purchase_demo_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_helpers.dart';

void main() {
  group('InAppPurchaseDemoCubit', () {
    late FakeInAppPurchaseRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeInAppPurchaseRepository(
        delay: Duration.zero,
        clockNow: () => DateTime(2026, 1, 1),
        timerService: FakeTimerService(),
      )..forcedOutcome = IapDemoForcedOutcome.success;
    });

    tearDown(() async {
      await fakeRepo.dispose();
    });

    InAppPurchaseDemoCubit buildCubit() => InAppPurchaseDemoCubit(
      fakeRepository: fakeRepo,
      realRepository: fakeRepo,
    );

    blocTest<InAppPurchaseDemoCubit, InAppPurchaseDemoState>(
      'initialize loads products and entitlements',
      build: buildCubit,
      act: (final cubit) => cubit.initialize(),
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
      act: (final cubit) async {
        await cubit.initialize();
        final products = cubit.state.products;
        final consumable = products.firstWhere(
          (p) => p.type == IapProductType.consumable,
        );
        await cubit.buy(consumable);
      },
      verify: (final cubit) {
        expect(cubit.state.entitlements.credits, greaterThanOrEqualTo(100));
      },
    );

    blocTest<InAppPurchaseDemoCubit, InAppPurchaseDemoState>(
      'restore updates non-consumable and subscription entitlements',
      build: buildCubit,
      act: (final cubit) async {
        await cubit.initialize();
        await cubit.restore();
      },
      verify: (final cubit) {
        expect(cubit.state.entitlements.isPremiumOwned, isTrue);
        expect(cubit.state.entitlements.isSubscriptionActive, isTrue);
      },
    );
  });
}
