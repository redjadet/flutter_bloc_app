import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/fake_repositories.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/online_therapy_fake_api.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('client can book an available slot (happy path)', () async {
    final api = OnlineTherapyFakeApi();
    final auth = FakeTherapyAuthRepository(api: api);
    final therapists = FakeTherapistRepository(api: api);
    final appointments = FakeAppointmentRepository(api: api);

    await auth.login(email: 'demo@example.com', role: TherapyRole.client);

    final list = await therapists.listTherapists();
    expect(list, isNotEmpty);

    final first = list.first;
    final slots = await therapists.listAvailability(
      therapistId: first.id,
      date: DateTime.utc(2026, 4, 22),
    );
    expect(slots, isNotEmpty);

    final slot = slots.firstWhere(
      (s) => s.status == AvailabilitySlotStatus.available,
    );

    final appt = await appointments.createAppointment(
      therapistId: slot.therapistId,
      startAt: slot.startAt,
      endAt: slot.endAt,
    );
    expect(appt.status, AppointmentStatus.confirmed);

    final myAppointments = await appointments.listAppointmentsForCurrentRole();
    expect(myAppointments.map((a) => a.id), contains(appt.id));
  });
}
