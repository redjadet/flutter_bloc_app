import 'package:flutter_bloc_app/app/composition/features/register_social_feed_demo_services.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_realtime_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_repository.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_scenario_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_helpers.dart';

void main() {
  setUpAll(() async {
    await setupHiveForTesting();
  });

  setUp(() async {
    await setupTestDependencies(
      const TestSetupOptions(
        useMockFirebaseAuth: true,
        useMockFirebasePlatform: true,
      ),
    );
  });

  tearDown(() async {
    await tearDownTestDependencies();
  });

  test('resolves repository, realtime, and scenario after registration', () {
    registerSocialFeedDemoServices();
    expect(getIt<SocialFeedRepository>(), isA<SocialFeedRepository>());
    expect(getIt<SocialFeedRealtimeSource>(), isA<SocialFeedRealtimeSource>());
    expect(
      getIt<SocialFeedScenarioController>(),
      isA<SocialFeedScenarioController>(),
    );
  });
}
