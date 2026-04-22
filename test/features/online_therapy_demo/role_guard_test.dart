import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/fake_repositories.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/online_therapy_fake_api.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('admin endpoints are blocked for non-admin role', () async {
    final api = OnlineTherapyFakeApi();
    final auth = FakeTherapyAuthRepository(api: api);
    final admin = FakeTherapyAdminRepository(api: api);

    await auth.login(email: 'demo@example.com', role: TherapyRole.client);

    expect(() => admin.listPendingTherapists(), throwsA(isA<StateError>()));
  });
}
