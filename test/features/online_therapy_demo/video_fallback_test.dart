import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/fake_repositories.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/online_therapy_fake_api.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/online_therapy_network_mode.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('callFailure makes join fail (fallback)', () async {
    final api = OnlineTherapyFakeApi(
      initialMode: OnlineTherapyNetworkMode.callFailure,
    );
    final auth = FakeTherapyAuthRepository(api: api);
    final therapists = FakeTherapistRepository(api: api);
    final appointments = FakeAppointmentRepository(api: api);
    final calls = FakeTherapyCallRepository(api: api);

    await auth.login(email: 'demo@example.com', role: TherapyRole.client);

    final therapist = (await therapists.listTherapists()).first;
    final slot = (await therapists.listAvailability(
      therapistId: therapist.id,
      date: DateTime.utc(2026, 4, 22),
    )).firstWhere((s) => s.status == AvailabilitySlotStatus.available);

    final appt = await appointments.createAppointment(
      therapistId: slot.therapistId,
      startAt: slot.startAt,
      endAt: slot.endAt,
    );

    final session = await calls.createSession(appointmentId: appt.id);
    final joined = await calls.join(callSessionId: session.id);
    expect(joined.joinStatus, CallJoinStatus.failed);
  });
}
