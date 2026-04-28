import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/appointment_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/audit_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/therapist_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/therapy_admin_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/admin_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/client_booking_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ClientBookingCubit.loadTherapists clears busy and surfaces error', () async {
    final cubit = ClientBookingCubit(
      therapists: _ThrowingTherapistRepository(),
      appointments: _NoopAppointmentRepository(),
    );
    addTearDown(cubit.close);

    await cubit.loadTherapists();

    expect(cubit.state.isBusy, isFalse);
    expect(cubit.state.errorMessage, isNotNull);
  });

  test('AdminCubit.refresh clears busy and surfaces error', () async {
    final cubit = AdminCubit(admin: _ThrowingAdminRepository(), audit: _ThrowingAuditRepository());
    addTearDown(cubit.close);

    await cubit.refresh();

    expect(cubit.state.isBusy, isFalse);
    expect(cubit.state.errorMessage, isNotNull);
  });
}

class _ThrowingTherapistRepository implements TherapistRepository {
  @override
  Future<TherapistProfile> getTherapist({required String therapistId}) {
    throw UnimplementedError();
  }

  @override
  Future<List<AvailabilitySlot>> listAvailability({
    required String therapistId,
    required DateTime date,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<TherapistProfile>> listTherapists({
    String? query,
    String? specialty,
    String? language,
  }) async {
    throw StateError('boom');
  }
}

class _NoopAppointmentRepository implements AppointmentRepository {
  @override
  Future<Appointment> cancelAppointment({required String appointmentId, required String reason}) {
    throw UnimplementedError();
  }

  @override
  Future<Appointment> createAppointment({
    required String therapistId,
    required DateTime startAt,
    required DateTime endAt,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Appointment>> listAppointmentsForCurrentRole() async => <Appointment>[];
}

class _ThrowingAdminRepository implements TherapyAdminRepository {
  @override
  Future<TherapistProfile> approveTherapist({required String therapistId}) {
    throw UnimplementedError();
  }

  @override
  Future<List<TherapistProfile>> listPendingTherapists() async {
    throw StateError('boom');
  }
}

class _ThrowingAuditRepository implements AuditRepository {
  @override
  Future<List<AuditEvent>> listEvents() async {
    throw StateError('boom');
  }
}
