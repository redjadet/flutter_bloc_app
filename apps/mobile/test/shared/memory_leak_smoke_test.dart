import 'package:flutter_bloc_app/app/app_scope.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/memory/leak_safe_test_widgets.dart';
import '../test_helpers.dart' as test_helpers;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await test_helpers.setupHiveForTesting();
  });

  setUp(() async {
    await test_helpers.setupTestDependencies();
  });

  tearDown(() async {
    await test_helpers.tearDownTestDependencies();
  });

  leakSafeTestWidgets('AppScope mount and unmount is leak-safe', (
    tester,
  ) async {
    final GoRouter router = GoRouter(
      routes: <GoRoute>[
        GoRoute(
          path: '/',
          builder: (context, state) => const SizedBox.shrink(),
        ),
      ],
    );

    await tester.pumpWidget(AppScope(router: router));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    router.dispose();
  });
}
