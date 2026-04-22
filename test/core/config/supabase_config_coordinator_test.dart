import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/core/config/supabase_config_coordinator.dart';
import 'package:flutter_bloc_app/core/config/supabase_config_provider.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_service.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _FakeRemoteConfigService implements RemoteConfigService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> forceFetch() async {}

  @override
  Future<void> clearCache() async {}

  @override
  bool getBool(final String key) => false;

  @override
  String getString(final String key) => '';

  @override
  int getInt(final String key) => 0;

  @override
  double getDouble(final String key) => 0.0;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SupabaseConfigCoordinator', () {
    late _MockFirebaseAuth auth;
    late StreamController<User?> authChanges;
    late SupabaseConfigProvider provider;

    setUp(() {
      auth = _MockFirebaseAuth();
      authChanges = StreamController<User?>.broadcast();
      when(() => auth.authStateChanges()).thenAnswer((_) => authChanges.stream);
      when(() => auth.currentUser).thenReturn(null);
      provider = SupabaseConfigProvider(
        auth: auth,
        remoteConfig: _FakeRemoteConfigService(),
        storage: InMemorySecretStorage(),
      );
    });

    tearDown(() async {
      await authChanges.close();
    });

    test(
      'dedupes duplicate sign-in events while a fetch is in flight',
      () async {
        final user = _MockUser();
        final completer = Completer<SupabaseConfigFetchResult>();
        var callCount = 0;

        final coordinatorWithOverride = SupabaseConfigCoordinator(
          auth: auth,
          provider: provider,
          fetchAndApplyIfNeeded: () {
            callCount++;
            return completer.future;
          },
        );
        await coordinatorWithOverride.start();

        authChanges.add(user);
        authChanges.add(user);
        await pumpEventQueue(times: 10);

        expect(callCount, 1);

        completer.complete(
          const SupabaseConfigFetchResult(
            updated: false,
            skipped: true,
            reason: 'test',
          ),
        );
        await pumpEventQueue(times: 10);

        await coordinatorWithOverride.dispose();
      },
    );

    test(
      'startup path triggers only one fetch even if auth emits quickly',
      () async {
        final user = _MockUser();
        when(() => auth.currentUser).thenReturn(user);

        final completer = Completer<SupabaseConfigFetchResult>();
        var callCount = 0;

        final coordinator = SupabaseConfigCoordinator(
          auth: auth,
          provider: provider,
          fetchAndApplyIfNeeded: () {
            callCount++;
            return completer.future;
          },
        );
        await coordinator.start();

        authChanges.add(user);
        await pumpEventQueue(times: 10);

        expect(callCount, 1);

        completer.complete(
          const SupabaseConfigFetchResult(
            updated: false,
            skipped: true,
            reason: 'test',
          ),
        );
        await pumpEventQueue(times: 10);

        await coordinator.dispose();
      },
    );
  });
}
