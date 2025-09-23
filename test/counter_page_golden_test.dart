import 'package:flutter_bloc_app/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CounterPage Golden', () {
    setUpAll(() async {
      await loadAppFonts();
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testGoldens('renders correctly on common devices', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(
          devices: [Device.phone, Device.tabletPortrait, Device.tabletLandscape],
        )
        ..addScenario(name: 'Initial state', widget: const MyApp());

      await tester.pumpDeviceBuilder(builder);
      await tester.pumpAndSettle();
      await screenMatchesGolden(tester, 'counter_page_initial');
    });
  });
}
