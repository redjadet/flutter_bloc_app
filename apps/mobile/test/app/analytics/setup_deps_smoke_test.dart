import 'package:auth/auth.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('setupTestDependencies registers AuthRepository', () async {
    try {
      await setupTestDependencies(
        const TestSetupOptions(
          useMockFirebaseAuth: true,
          useMockFirebasePlatform: true,
        ),
      );
    } on Object catch (error, stackTrace) {
      fail('setupTestDependencies threw: $error\n$stackTrace');
    }
    expect(getIt.isRegistered<AuthRepository>(), isTrue);
    await tearDownTestDependencies();
  });
}
