import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/online_therapy_fake_api.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/therapy_auth_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _ThrowingLoginTherapyAuthRepository implements TherapyAuthRepository {
  _ThrowingLoginTherapyAuthRepository(this._user);

  TherapyUser? _user;

  @override
  TherapyUser? get currentUser => _user;

  @override
  Future<TherapyUser> login({
    required final String email,
    required final TherapyRole role,
  }) async {
    throw StateError('network');
  }

  @override
  Future<void> logout() async {
    _user = null;
  }
}

TherapyUser _sampleUser(final TherapyRole role) => TherapyUser(
  id: 'u1',
  role: role,
  displayName: 'Demo',
  maskedEmail: 'd***@example.com',
  createdAt: DateTime.utc(2024, 1, 1),
);

void main() {
  group('OnlineTherapyDemoSessionCubit.setRole', () {
    test('restores previous user and role when role switch login fails', () async {
      final TherapyUser clientUser = _sampleUser(TherapyRole.client);
      final _ThrowingLoginTherapyAuthRepository auth =
          _ThrowingLoginTherapyAuthRepository(clientUser);
      final OnlineTherapyFakeApi api = OnlineTherapyFakeApi();

      final OnlineTherapyDemoSessionCubit cubit = OnlineTherapyDemoSessionCubit(
        auth: auth,
        api: api,
      );

      expect(cubit.state.user, clientUser);
      expect(cubit.state.role, TherapyRole.client);

      await cubit.setRole(TherapyRole.therapist);

      expect(cubit.state.isBusy, isFalse);
      expect(cubit.state.user, clientUser);
      expect(cubit.state.role, TherapyRole.client);
      expect(cubit.state.errorMessage, contains('network'));

      await cubit.close();
    });
  });
}
