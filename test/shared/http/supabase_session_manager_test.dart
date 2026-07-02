import 'package:flutter_bloc_app/core/auth/auth_provider_kind.dart';
import 'package:flutter_bloc_app/core/auth/session_invalidation_reason.dart';
import 'package:flutter_bloc_app/core/auth/session_lifecycle_coordinator.dart';
import 'package:flutter_bloc_app/shared/http/supabase_session_manager.dart';
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
