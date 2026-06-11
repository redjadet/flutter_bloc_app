import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/appointment_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/therapist_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/client_booking_state.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/request_id_guard.dart';

export 'client_booking_state.dart';

part 'client_booking_cubit_loaders.part.dart';

class ClientBookingCubit extends Cubit<ClientBookingState> {
  ClientBookingCubit({
    required this._therapists,
    required this._appointments,
  }) : super(
         const ClientBookingState(
           isBusy: false,
           therapists: <TherapistProfile>[],
           availability: <AvailabilitySlot>[],
           appointments: <Appointment>[],
         ),
       );

  final TherapistRepository _therapists;
  final AppointmentRepository _appointments;
  final RequestIdGuard _operationGuard = RequestIdGuard();
  static final DateTime _demoAvailabilityDate = DateTime.utc(2026, 4, 22);

  bool _isRequestStillActive(final int requestId) =>
      !isClosed && _operationGuard.isCurrent(requestId);

  Future<void> refresh() async {
    final requestId = _operationGuard.next();
    emit(state.copyWith(isBusy: true, clearErrorMessage: true));
    try {
      await _loadTherapistsBody(requestId);
      if (!_isRequestStillActive(requestId)) return;
      await _loadSelectedAvailabilityBody(requestId);
      if (!_isRequestStillActive(requestId)) return;
      await _loadAppointmentsBody(requestId);
      if (!_isRequestStillActive(requestId)) return;
      emit(state.copyWith(isBusy: false, clearErrorMessage: true));
    } on Object catch (e, st) {
      AppLogger.error('ClientBookingCubit.refresh failed', e, st);
      if (!_isRequestStillActive(requestId)) return;
      emit(state.copyWith(isBusy: false, errorMessage: e.toString()));
    }
  }

  Future<void> loadTherapists() async {
    final requestId = _operationGuard.next();
    emit(state.copyWith(isBusy: true, clearErrorMessage: true));
    try {
      await _loadTherapistsBody(requestId);
      if (!_isRequestStillActive(requestId)) return;
      await _loadSelectedAvailabilityBody(requestId);
      if (!_isRequestStillActive(requestId)) return;
      emit(state.copyWith(isBusy: false, clearErrorMessage: true));
    } on Object catch (e, st) {
      AppLogger.error('ClientBookingCubit.loadTherapists failed', e, st);
      if (!_isRequestStillActive(requestId)) return;
      emit(state.copyWith(isBusy: false, errorMessage: e.toString()));
    }
  }

  Future<void> selectTherapist(final String therapistId) async {
    if (therapistId.trim().isEmpty) {
      _operationGuard.invalidate();
      emit(
        state.copyWith(
          isBusy: false,
          selectedTherapistId: null,
          availability: <AvailabilitySlot>[],
          clearErrorMessage: true,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        selectedTherapistId: therapistId,
        availability: <AvailabilitySlot>[],
      ),
    );
    await loadAvailability(therapistId: therapistId);
  }

  void setPendingBookingSlot(final AvailabilitySlot slot) {
    emit(state.copyWith(pendingBookingSlot: slot));
  }

  void clearPendingBookingSlot() {
    emit(state.copyWith(pendingBookingSlot: null));
  }

  Future<void> loadAvailability({required final String therapistId}) async {
    if (therapistId.trim().isEmpty) {
      _operationGuard.invalidate();
      emit(
        state.copyWith(
          isBusy: false,
          availability: <AvailabilitySlot>[],
          clearErrorMessage: true,
        ),
      );
      return;
    }
    final requestId = _operationGuard.next();
    emit(state.copyWith(isBusy: true, clearErrorMessage: true));
    try {
      final slots = await _therapists.listAvailability(
        therapistId: therapistId,
        date: _demoAvailabilityDate,
      );
      if (!_isRequestStillActive(requestId)) return;
      if (state.selectedTherapistId != therapistId) {
        emit(state.copyWith(isBusy: false));
        return;
      }
      emit(
        state.copyWith(
          isBusy: false,
          availability: slots,
          clearErrorMessage: true,
        ),
      );
    } on Object catch (e, st) {
      AppLogger.error('ClientBookingCubit.loadAvailability failed', e, st);
      if (!_isRequestStillActive(requestId)) return;
      emit(state.copyWith(isBusy: false, errorMessage: e.toString()));
    }
  }

  Future<void> loadAppointments() async {
    final requestId = _operationGuard.next();
    emit(state.copyWith(isBusy: true, clearErrorMessage: true));
    try {
      await _loadAppointmentsBody(requestId);
      if (!_isRequestStillActive(requestId)) return;
      emit(state.copyWith(isBusy: false, clearErrorMessage: true));
    } on Object catch (e, st) {
      AppLogger.error('ClientBookingCubit.loadAppointments failed', e, st);
      if (!_isRequestStillActive(requestId)) return;
      emit(state.copyWith(isBusy: false, errorMessage: e.toString()));
    }
  }

  /// Returns `true` when the appointment was created and the list refreshed.
  Future<bool> createAppointmentFromSlot(final AvailabilitySlot slot) async {
    final requestId = _operationGuard.next();
    emit(state.copyWith(isBusy: true, clearErrorMessage: true));
    try {
      await _appointments.createAppointment(
        therapistId: slot.therapistId,
        startAt: slot.startAt,
        endAt: slot.endAt,
      );
      if (!_isRequestStillActive(requestId)) return false;
      emit(state.copyWith(pendingBookingSlot: null));
      await _loadSelectedAvailabilityBody(requestId);
      if (!_isRequestStillActive(requestId)) return false;
      await _loadAppointmentsBody(requestId);
      if (!_isRequestStillActive(requestId)) return false;
      emit(state.copyWith(isBusy: false, clearErrorMessage: true));
      return true;
    } on Object catch (e, st) {
      AppLogger.error(
        'ClientBookingCubit.createAppointmentFromSlot failed',
        e,
        st,
      );
      if (!_isRequestStillActive(requestId)) return false;
      emit(state.copyWith(isBusy: false, errorMessage: e.toString()));
      return false;
    }
  }

  Future<void> cancelAppointment(final String appointmentId) async {
    if (appointmentId.trim().isEmpty) {
      _operationGuard.invalidate();
      emit(state.copyWith(isBusy: false));
      return;
    }
    final requestId = _operationGuard.next();
    emit(state.copyWith(isBusy: true, clearErrorMessage: true));
    try {
      await _appointments.cancelAppointment(
        appointmentId: appointmentId,
        reason: 'Cancelled in demo',
      );
      if (!_isRequestStillActive(requestId)) return;
      await _loadTherapistsBody(requestId);
      if (!_isRequestStillActive(requestId)) return;
      await _loadSelectedAvailabilityBody(requestId);
      if (!_isRequestStillActive(requestId)) return;
      await _loadAppointmentsBody(requestId);
      if (!_isRequestStillActive(requestId)) return;
      emit(state.copyWith(isBusy: false, clearErrorMessage: true));
    } on Object catch (e, st) {
      AppLogger.error('ClientBookingCubit.cancelAppointment failed', e, st);
      if (!_isRequestStillActive(requestId)) return;
      emit(state.copyWith(isBusy: false, errorMessage: e.toString()));
    }
  }
}
