import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_bloc_app/app.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/counter/presentation/pages/counter_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await getIt.reset(dispose: true);
    await configureDependencies();
  });

  tearDown(() async {
    await getIt.reset(dispose: true);
  });

  testWidgets('MyApp renders counter page when auth not required', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp(requireAuth: false));
    await tester.pumpAndSettle();

    expect(find.byType(CounterPage), findsOneWidget);
  });
}
