import 'dart:async';

import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/core/auth/auth_user.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_push_token_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_role.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_session_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _MutableStaffAuthRepository implements AuthRepository {
  _MutableStaffAuthRepository(this.user);

  AuthUser? user;
  final StreamController<AuthUser?> _controller =
      StreamController<AuthUser?>.broadcast();

  @override
  AuthUser? get currentUser => user;

  @override
  Stream<AuthUser?> get authStateChanges => _controller.stream;

  Future<void> dispose() => _controller.close();
}

class _GatedStaffProfileRepository implements StaffDemoProfileRepository {
  _GatedStaffProfileRepository({
    required this.gate,
    required this.profilesByUserId,
  });

  final Future<void> gate;
  final Map<String, StaffDemoProfile?> profilesByUserId;

  @override
  Future<StaffDemoProfile?> loadProfile({required final String userId}) async {
    await gate;
    return profilesByUserId[userId];
  }

  @override
  Future<List<StaffDemoProfile>> listAssignableStaff() async =>
      <StaffDemoProfile>[];
}

class _NoopStaffPushTokenRepository implements StaffDemoPushTokenRepository {
  @override
  Future<void> registerTokens({required final String userId}) async {}
}

void main() {
  group('StaffDemoSessionCubit.hydrate', () {
    test('re-hydrates when auth user changes before profile returns', () async {
      final Completer<void> gate = Completer<void>();
      final _MutableStaffAuthRepository auth = _MutableStaffAuthRepository(
        const AuthUser(id: 'user-a', isAnonymous: false),
      );
      final StaffDemoProfile profileA = StaffDemoProfile(
        userId: 'user-a',
        displayName: 'A',
        email: 'a@example.com',
        role: StaffDemoRole.employee,
        phoneE164: null,
        isActive: true,
      );
      final StaffDemoProfile profileB = StaffDemoProfile(
        userId: 'user-b',
        displayName: 'B',
        email: 'b@example.com',
        role: StaffDemoRole.employee,
        phoneE164: null,
        isActive: true,
      );
      final _GatedStaffProfileRepository profiles =
          _GatedStaffProfileRepository(
            gate: gate.future,
            profilesByUserId: <String, StaffDemoProfile?>{
              'user-a': profileA,
              'user-b': profileB,
            },
          );

      final StaffDemoSessionCubit cubit = StaffDemoSessionCubit(
        authRepository: auth,
        profileRepository: profiles,
        pushTokenRepository: _NoopStaffPushTokenRepository(),
      );

      final Future<void> hydrateDone = cubit.hydrate();
      await Future<void>.delayed(Duration.zero);
      auth.user = const AuthUser(id: 'user-b', isAnonymous: false);
      gate.complete();

      await hydrateDone;
      bool readyB(final StaffDemoSessionState s) =>
          s.status == StaffDemoSessionStatus.ready && s.profile == profileB;
      if (!readyB(cubit.state)) {
        await cubit.stream
            .firstWhere(readyB)
            .timeout(const Duration(seconds: 2));
      }

      expect(cubit.state.status, StaffDemoSessionStatus.ready);
      expect(cubit.state.profile, profileB);

      await cubit.close();
      await auth.dispose();
    });

    test(
      'on profile error, re-hydrates if auth user changed during load',
      () async {
        final Completer<void> gate = Completer<void>();
        final _MutableStaffAuthRepository auth = _MutableStaffAuthRepository(
          const AuthUser(id: 'user-a', isAnonymous: false),
        );

        final StaffDemoSessionCubit cubit = StaffDemoSessionCubit(
          authRepository: auth,
          profileRepository: _ThrowingAfterGateProfileRepository(
            gate: gate.future,
          ),
          pushTokenRepository: _NoopStaffPushTokenRepository(),
        );

        final Future<void> hydrateDone = cubit.hydrate();
        await Future<void>.delayed(Duration.zero);
        auth.user = null;
        gate.complete();

        await hydrateDone;
        bool notSignedIn(final StaffDemoSessionState s) =>
            s.status == StaffDemoSessionStatus.error &&
            s.errorMessage == 'Not signed in.';
        if (!notSignedIn(cubit.state)) {
          await cubit.stream
              .firstWhere(notSignedIn)
              .timeout(const Duration(seconds: 2));
        }

        expect(cubit.state.status, StaffDemoSessionStatus.error);
        expect(cubit.state.errorMessage, 'Not signed in.');

        await cubit.close();
        await auth.dispose();
      },
    );
  });
}

/// After [gate] completes, throws (simulates network failure after auth drift).
class _ThrowingAfterGateProfileRepository
    implements StaffDemoProfileRepository {
  _ThrowingAfterGateProfileRepository({required this.gate});

  final Future<void> gate;

  @override
  Future<StaffDemoProfile?> loadProfile({required final String userId}) async {
    await gate;
    throw StateError('network');
  }

  @override
  Future<List<StaffDemoProfile>> listAssignableStaff() async =>
      <StaffDemoProfile>[];
}
