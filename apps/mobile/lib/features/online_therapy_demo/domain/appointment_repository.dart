import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';

abstract interface class AppointmentRepository {
  Future<Appointment> createAppointment({
    required String therapistId,
    required DateTime startAt,
    required DateTime endAt,
  });

  Future<List<Appointment>> listAppointmentsForCurrentRole();

  Future<Appointment> cancelAppointment({
    required String appointmentId,
    required String reason,
  });
}
