import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/iot/domain/iot_ble_runtime_config.dart';
import 'package:flutter_bloc_app/features/iot/data/ble_platform_gateway_impl.dart';
import 'package:flutter_bloc_app/features/iot/data/mock_ble_repository.dart';
import 'package:flutter_bloc_app/features/iot/data/mock_classic_bluetooth_repository.dart';
import 'package:flutter_bloc_app/features/iot/data/unsupported_ble_repository.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_platform_gateway.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_cubit.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_state.dart';
import 'package:flutter_bloc_app/features/iot/presentation/widgets/iot_ble_section.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';

class _ImmediateTimerService implements TimerService {
  @override
  TimerDisposable periodic(
    final Duration interval,
    final void Function() onTick,
  ) => _NoopDisposable();

  @override
  TimerDisposable runOnce(
    final Duration delay,
    final void Function() onComplete,
  ) {
    onComplete();
    return _NoopDisposable();
  }
}

class _NoopDisposable with TimerDisposable {
  @override
  void dispose() {}
}

void main() {
  testWidgets('IotBleSection shows status, empty devices, and log panel', (
    final tester,
  ) async {
    final MockBleRepository mockRepository = MockBleRepository();
    final MockClassicBluetoothRepository classicRepository =
        MockClassicBluetoothRepository();
    final IotBleCubit cubit = IotBleCubit(
      mockRepository: mockRepository,
      reactiveRepository: const UnsupportedBleRepository(),
      classicRepository: classicRepository,
      platformGateway: const BlePlatformGatewayImpl(),
      runtimeConfig: const IotBleRuntimeConfig(defaultMockMode: true),
      timerService: _ImmediateTimerService(),
    );
    addTearDown(() async {
      await cubit.close();
      mockRepository.dispose();
      classicRepository.dispose();
    });

    await cubit.initialize();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<IotBleCubit>.value(
          value: cubit,
          child: const Scaffold(body: IotBleSection()),
        ),
      ),
    );
    await tester.pump();

    final AppLocalizationsEn l10n = AppLocalizationsEn();
    expect(find.text(l10n.iotBleStatusTitle), findsOneWidget);
    expect(find.text(l10n.iotBleNoDevices), findsOneWidget);
    expect(find.text(l10n.iotBleEventLogTitle), findsOneWidget);
  });

  testWidgets(
    'Try again after unsupported real mode returns to mock showcase',
    (final tester) async {
      final MockBleRepository mockRepository = MockBleRepository();
      final MockClassicBluetoothRepository classicRepository =
          MockClassicBluetoothRepository();
      final IotBleCubit cubit = IotBleCubit(
        mockRepository: mockRepository,
        reactiveRepository: const UnsupportedBleRepository(),
        classicRepository: classicRepository,
        platformGateway: _SupportsRealBleGateway(),
        runtimeConfig: const IotBleRuntimeConfig(defaultMockMode: true),
        timerService: _ImmediateTimerService(),
      );
      addTearDown(() async {
        await cubit.close();
        mockRepository.dispose();
        classicRepository.dispose();
      });

      await cubit.initialize();
      await cubit.toggleBleMode(useMock: false);

      final AppLocalizationsEn l10n = AppLocalizationsEn();
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<IotBleCubit>.value(
            value: cubit,
            child: const Scaffold(body: IotBleSection()),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.textContaining(l10n.iotBleErrorUnsupportedPlatform),
        findsOneWidget,
      );

      await tester.tap(find.text(l10n.retryButtonLabel));
      await tester.pump();
      await tester.pump();

      expect(find.text(l10n.iotBleStatusTitle), findsOneWidget);
      expect(find.text(l10n.iotBleMockModeLabel), findsWidgets);
      expect(cubit.state.useMockBle, isTrue);
      expect(cubit.state.status, IotBleStatus.ready);
    },
  );
}

class _SupportsRealBleGateway implements BlePlatformGateway {
  const _SupportsRealBleGateway();
  @override
  bool get supportsRealBle => true;

  @override
  bool get supportsRealClassic => false;
}
