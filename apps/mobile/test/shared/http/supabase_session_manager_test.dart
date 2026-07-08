import 'package:auth/auth.dart';
import 'package:flutter_bloc_app/app/auth/session_lifecycle_coordinator.dart';
import 'package:flutter_bloc_app/app/http/supabase/supabase_session_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _SpyCoordinator extends SessionLifecycleCoordinatorImpl {
  int invalidateCalls = 0;
  SessionInvalidationReason? lastReason;

  @override
  Future<void> invalidateSession({
    required final AuthProviderKind provider,
    required final SessionInvalidationReason reason,
  }) async {
    invalidateCalls += 1;
    lastReason = reason;
    await super.invalidateSession(provider: provider, reason: reason);
  }
}

void main() {
  group('SupabaseSessionManager', () {
    test(
      'hydrateFromPersistentSession caches persistent token before reads',
      () {
        final SupabaseSessionManager manager = SupabaseSessionManager(
          readPersistentAccessToken: () => 'startup-token',
        );

        manager.hydrateFromPersistentSession();

        expect(manager.getAccessToken(), 'startup-token');
      },
    );

    test(
      'getAccessToken lazy re-hydrates when memory is empty but SDK session exists',
      () {
        var sessionAvailable = false;
        var persistentReads = 0;
        final SupabaseSessionManager manager = SupabaseSessionManager(
          readPersistentAccessToken: () {
            persistentReads += 1;
            return sessionAvailable ? 'restored-token' : null;
          },
        );

        manager.hydrateFromPersistentSession();
        expect(manager.getAccessToken(), isNull);
        expect(persistentReads, 2);

        sessionAvailable = true;
        expect(manager.getAccessToken(), 'restored-token');
        expect(persistentReads, 3);

        expect(manager.getAccessToken(), 'restored-token');
        expect(persistentReads, 3);
      },
    );

    test('single-flight refresh shares one refresh call', () async {
      var refreshCalls = 0;
      final SupabaseSessionManager manager = SupabaseSessionManager(
        refreshSession: () async {
          refreshCalls += 1;
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return AuthResponse();
        },
        readPersistentAccessToken: () => refreshCalls > 0 ? 'token-a' : null,
      );

      final List<bool> results = await Future.wait(<Future<bool>>[
        manager.refreshSessionSerialized(),
        manager.refreshSessionSerialized(),
      ]);

      expect(refreshCalls, 1);
      expect(results, everyElement(isTrue));
    });

    test('auth-classified refresh failure invalidates session', () async {
      final _SpyCoordinator coordinator = _SpyCoordinator();
      final SupabaseSessionManager manager = SupabaseSessionManager(
        sessionCoordinator: coordinator,
        refreshSession: () async {
          throw AuthException('invalid refresh token', statusCode: '401');
        },
        readPersistentAccessToken: () => null,
      );

      final bool refreshed = await manager.refreshSessionSerialized();

      expect(refreshed, isFalse);
      expect(coordinator.invalidateCalls, 1);
      expect(
        coordinator.lastReason,
        SessionInvalidationReason.supabaseSessionInvalid,
      );
    });
  });
}
