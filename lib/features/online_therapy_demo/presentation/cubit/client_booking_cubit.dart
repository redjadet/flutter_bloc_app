import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/appointment_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/therapist_repository.dart';

class ClientBookingState {
  const ClientBookingState({
    required this.isBusy,
    required this.therapists,
    required this.availability,
    required this.appointments,
    this.pendingBookingSlot,
    this.selectedTherapistId,
    this.errorMessage,
  });

  final bool isBusy;
  final List<TherapistProfile> therapists;
  final String? selectedTherapistId;
  final List<AvailabilitySlot> availability;
  final List<Appointment> appointments;
  final AvailabilitySlot? pendingBookingSlot;
  final String? errorMessage;

  static const Object _noChange = Object();

  TherapistProfile? get selectedTherapist => selectedTherapistId == null
      ? null
      : therapists.where((t) => t.id == selectedTherapistId).firstOrNull;

  ClientBookingState copyWith({
    bool? isBusy,
    List<TherapistProfile>? therapists,
    Object? selectedTherapistId = _noChange,
    List<AvailabilitySlot>? availability,
    List<Appointment>? appointments,
    Object? pendingBookingSlot = _noChange,
    String? errorMessage,
  }) => ClientBookingState(
    isBusy: isBusy ?? this.isBusy,
    therapists: therapists ?? this.therapists,
    selectedTherapistId: identical(selectedTherapistId, _noChange)
        ? this.selectedTherapistId
        : selectedTherapistId as String?,
    availability: availability ?? this.availability,
    appointments: appointments ?? this.appointments,
    pendingBookingSlot: identical(pendingBookingSlot, _noChange)
        ? this.pendingBookingSlot
        : pendingBookingSlot as AvailabilitySlot?,
    errorMessage: errorMessage,
  );
}

class ClientBookingCubit extends Cubit<ClientBookingState> {
  ClientBookingCubit({
    required final TherapistRepository therapists,
    required final AppointmentRepository appointments,
  }) : _therapists = therapists,
       _appointments = appointments,
       super(
         const ClientBookingState(
           isBusy: false,
           therapists: <TherapistProfile>[],
           availability: <AvailabilitySlot>[],
           appointments: <Appointment>[],
         ),
       );

  final TherapistRepository _therapists;
  final AppointmentRepository _appointments;
  static final DateTime _demoAvailabilityDate = DateTime.utc(2026, 4, 22);

  Future<void> refresh() async {
    await loadTherapists();
    await loadAppointments();
  }

  Future<void> loadTherapists() async {
    if (state.isBusy) return;
    emit(state.copyWith(isBusy: true));
    try {
      final list = await _therapists.listTherapists();
      final currentSelection = state.selectedTherapistId;
      final selected =
          currentSelection != null && list.any((t) => t.id == currentSelection)
          ? currentSelection
          : list.isEmpty
          ? null
          : list.first.id;
      if (isClosed) return;
      emit(
        state.copyWith(
          isBusy: false,
          therapists: list,
          selectedTherapistId: selected,
          availability: selected != null && selected == currentSelection
              ? null
              : <AvailabilitySlot>[],
        ),
      );
      if (selected != null) {
        await loadAvailability(therapistId: selected);
      }
    } on Object catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, errorMessage: e.toString()));
    }
  }

  Future<void> selectTherapist(final String therapistId) async {
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
    emit(state.copyWith(isBusy: true));
    try {
      final slots = await _therapists.listAvailability(
        therapistId: therapistId,
        date: _demoAvailabilityDate,
      );
      if (isClosed) return;
      if (state.selectedTherapistId != therapistId) return;
      emit(state.copyWith(isBusy: false, availability: slots));
    } on Object catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, errorMessage: e.toString()));
    }
  }

  Future<void> loadAppointments() async {
    emit(state.copyWith(isBusy: true));
    try {
      final list = await _appointments.listAppointmentsForCurrentRole();
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, appointments: list));
    } on Object catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, errorMessage: e.toString()));
    }
  }

  Future<void> createAppointmentFromSlot(final AvailabilitySlot slot) async {
    emit(state.copyWith(isBusy: true));
    try {
      await _appointments.createAppointment(
        therapistId: slot.therapistId,
        startAt: slot.startAt,
        endAt: slot.endAt,
      );
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, pendingBookingSlot: null));
      await refresh();
    } on Object catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, errorMessage: e.toString()));
    }
  }

  Future<void> cancelAppointment(final String appointmentId) async {
    emit(state.copyWith(isBusy: true));
    try {
      await _appointments.cancelAppointment(
        appointmentId: appointmentId,
        reason: 'Cancelled in demo',
      );
      if (isClosed) return;
      emit(state.copyWith(isBusy: false));
      await refresh();
    } on Object catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, errorMessage: e.toString()));
    }
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
