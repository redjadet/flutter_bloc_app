import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/core/theme/mix_app_theme.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_command.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_cubit.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/cubit/iot_demo_state.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/pages/iot_demo_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:mix/mix.dart';

class _StubIotDemoRepository implements IotDemoRepository {
  @override
  Stream<List<IotDevice>> watchDevices() => const Stream.empty();

  @override
  Future<void> connect(final String deviceId) async {}

  @override
  Future<void> disconnect(final String deviceId) async {}

  @override
  Future<void> sendCommand(
    final String deviceId,
    final IotDeviceCommand command,
  ) async {}
}

class _TestIotDemoCubit extends IotDemoCubit {
  _TestIotDemoCubit() : super(repository: _StubIotDemoRepository());

  void setTestState(final IotDemoState value) => emit(value);
}

Future<void> _pumpPage(
  final WidgetTester tester, {
  required final IotDemoState state,
}) async {
  final cubit = _TestIotDemoCubit()..setTestState(state);
  addTearDown(cubit.close);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (final context) => MixTheme(
          data: buildAppMixThemeData(context),
          child: BlocProvider<IotDemoCubit>.value(
            value: cubit,
            child: const IotDemoPage(),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('IotDemoPage', () {
    final l10n = AppLocalizationsEn();

    testWidgets('shows progress indicator in loading state', (
      final tester,
    ) async {
      await _pumpPage(tester, state: const IotDemoState.loading());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty message when device list is empty', (
      final tester,
    ) async {
      await _pumpPage(
        tester,
        state: IotDemoState.loaded([], selectedDeviceId: null),
      );

      expect(find.text(l10n.iotDemoDeviceListEmpty), findsOneWidget);
    });

    testWidgets('shows device list when loaded', (final tester) async {
      const devices = [
        IotDevice(
          id: 'light-1',
          name: 'Living Room Light',
          type: IotDeviceType.light,
        ),
      ];
      await _pumpPage(
        tester,
        state: IotDemoState.loaded(devices, selectedDeviceId: null),
      );

      expect(find.text(l10n.iotDemoPageTitle), findsOneWidget);
      expect(find.text('Living Room Light'), findsOneWidget);
    });

    testWidgets('shows error and retry when in error state', (
      final tester,
    ) async {
      await _pumpPage(
        tester,
        state: IotDemoState.error('Something went wrong'),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('Set value dialog close does not use controller after dispose',
        (final tester) async {
      const devices = [
        IotDevice(
          id: 'thermostat-1',
          name: 'Thermostat',
          type: IotDeviceType.thermostat,
          connectionState: IotConnectionState.connected,
          value: 21,
        ),
      ];
      await _pumpPage(
        tester,
        state: IotDemoState.loaded(devices, selectedDeviceId: 'thermostat-1'),
      );
      await tester.pump();
      expect(find.text(l10n.iotDemoSetValue), findsOneWidget);
      await tester.tap(find.text(l10n.iotDemoSetValue));
      await tester.pumpAndSettle();
      expect(find.text(l10n.iotDemoSetValueHint), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.iotDemoSetValueHint), findsNothing);
    });
  });
}
