import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/fake_repositories.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/online_therapy_fake_api.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/admin_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';

void main() {
  group('AdminCubit success paths', () {
    late OnlineTherapyFakeApi api;
    late FakeTherapyAuthRepository auth;
    late AdminCubit cubit;

    setUp(() {
      api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
      auth = FakeTherapyAuthRepository(api: api);
      cubit = AdminCubit(
        admin: FakeTherapyAdminRepository(api: api),
        audit: FakeAuditRepository(api: api),
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    test(
      'refresh loads pending therapists and audit events for admin',
      () async {
        await auth.login(email: 'admin@example.com', role: TherapyRole.admin);

        await cubit.refresh();

        expect(cubit.state.isBusy, isFalse);
        expect(cubit.state.errorMessage, isNull);
        expect(cubit.state.pendingTherapists, isNotEmpty);
        expect(cubit.state.auditEvents, isNotEmpty);
      },
    );

    test('approve marks therapist verified and refreshes lists', () async {
      await auth.login(email: 'admin@example.com', role: TherapyRole.admin);
      await cubit.refresh();
      final pendingId = cubit.state.pendingTherapists.first.id;

      await cubit.approve(pendingId);

      expect(cubit.state.isBusy, isFalse);
      expect(cubit.state.errorMessage, isNull);
      expect(
        cubit.state.pendingTherapists.any((t) => t.id == pendingId),
        isFalse,
      );
      expect(
        cubit.state.auditEvents.any((e) => e.action == 'therapist_approved'),
        isTrue,
      );
    });
  });
}

class _ImmediateTimerService implements TimerService {
  @override
  TimerDisposable periodic(
    final Duration interval,
    final void Function() onTick,
  ) {
    onTick();
    return _NoopTimerDisposable();
  }

  @override
  TimerDisposable runOnce(
    final Duration delay,
    final void Function() onComplete,
  ) {
    onComplete();
    return _NoopTimerDisposable();
  }
}

class _NoopTimerDisposable implements TimerDisposable {
  @override
  void dispose() {}
}
