import 'package:auth/auth.dart';
import 'package:flutter_bloc_app/app/analytics/product_analytics.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_registrations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('registerAllDependencies surfaces analytics errors', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await ensureFirebaseInitializedForTests(forceMockPlatform: true);
    await getIt.reset(dispose: true);
    try {
      await registerAllDependencies();
      // ignore: avoid_print
      print(
        'registered auth=${getIt.isRegistered<AuthRepository>()} '
        'analytics=${getIt.isRegistered<ProductAnalytics>()}',
      );
    } on Object catch (error, stackTrace) {
      // ignore: avoid_print
      print('REGISTER FAIL: $error');
      // ignore: avoid_print
      print(stackTrace);
      fail('$error');
    }
  });
}
