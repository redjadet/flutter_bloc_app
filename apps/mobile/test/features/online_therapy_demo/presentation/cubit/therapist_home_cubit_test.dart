import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/appointment_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/therapist_home_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sampleAppointment = Appointment(
    id: 'appt-1',
    therapistId: 'therapist-1',
    clientId: 'client-1',
    startAt: DateTime.utc(2026, 4, 22, 10),
    endAt: DateTime.utc(2026, 4, 22, 11),
    status: AppointmentStatus.confirmed,
    createdAt: DateTime.utc(2026, 4, 20),
  );

  group('TherapistHomeCubit', () {
    test('refresh loads appointments', () async {
      final cubit = TherapistHomeCubit(
        appointments: _FakeAppointmentRepository(
          listResult: <Appointment>[sampleAppointment],
        ),
      );
      addTearDown(cubit.close);

      await cubit.refresh();

      expect(cubit.state.isBusy, isFalse);
      expect(cubit.state.appointments, <Appointment>[sampleAppointment]);
      expect(cubit.state.errorMessage, isNull);
    });

    test('refresh handles empty list', () async {
      final cubit = TherapistHomeCubit(
        appointments: _FakeAppointmentRepository(listResult: <Appointment>[]),
      );
      addTearDown(cubit.close);

      await cubit.refresh();

      expect(cubit.state.isBusy, isFalse);
      expect(cubit.state.appointments, isEmpty);
    });

    test('refresh surfaces repository failure', () async {
      final cubit = TherapistHomeCubit(
        appointments: _ThrowingAppointmentRepository(),
      );
      addTearDown(cubit.close);

      await cubit.refresh();

      expect(cubit.state.isBusy, isFalse);
      expect(cubit.state.errorMessage, isNotNull);
    });
  });
}

class _FakeAppointmentRepository implements AppointmentRepository {
  _FakeAppointmentRepository({required this.listResult});

  final List<Appointment> listResult;

  @override
  Future<Appointment> cancelAppointment({
    required String appointmentId,
    required String reason,
  }) => throw UnimplementedError();

  @override
  Future<Appointment> createAppointment({
    required String therapistId,
    required DateTime startAt,
    required DateTime endAt,
  }) => throw UnimplementedError();

  @override
  Future<List<Appointment>> listAppointmentsForCurrentRole() async =>
      listResult;
}

class _ThrowingAppointmentRepository implements AppointmentRepository {
  @override
  Future<Appointment> cancelAppointment({
    required String appointmentId,
    required String reason,
  }) => throw UnimplementedError();

  @override
  Future<Appointment> createAppointment({
    required String therapistId,
    required DateTime startAt,
    required DateTime endAt,
  }) => throw UnimplementedError();

  @override
  Future<List<Appointment>> listAppointmentsForCurrentRole() {
    throw StateError('list failed');
  }
}
