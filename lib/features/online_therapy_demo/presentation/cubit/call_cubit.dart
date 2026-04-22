import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/appointment_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/therapy_call_repository.dart';

class CallState {
  const CallState({
    required this.isBusy,
    required this.cameraPermissionGranted,
    required this.microphonePermissionGranted,
    required this.appointments,
    this.selectedAppointmentId,
    this.session,
    this.errorMessage,
  });

  final bool isBusy;
  final bool cameraPermissionGranted;
  final bool microphonePermissionGranted;
  final List<Appointment> appointments;
  final String? selectedAppointmentId;
  final CallSession? session;
  final String? errorMessage;

  static const Object _noChange = Object();

  CallState copyWith({
    bool? isBusy,
    bool? cameraPermissionGranted,
    bool? microphonePermissionGranted,
    List<Appointment>? appointments,
    Object? selectedAppointmentId = _noChange,
    Object? session = _noChange,
    String? errorMessage,
  }) => CallState(
    isBusy: isBusy ?? this.isBusy,
    cameraPermissionGranted:
        cameraPermissionGranted ?? this.cameraPermissionGranted,
    microphonePermissionGranted:
        microphonePermissionGranted ?? this.microphonePermissionGranted,
    appointments: appointments ?? this.appointments,
    selectedAppointmentId: identical(selectedAppointmentId, _noChange)
        ? this.selectedAppointmentId
        : selectedAppointmentId as String?,
    session: identical(session, _noChange)
        ? this.session
        : session as CallSession?,
    errorMessage: errorMessage,
  );
}

class CallCubit extends Cubit<CallState> {
  CallCubit({
    required final AppointmentRepository appointments,
    required final TherapyCallRepository calls,
  }) : _appointments = appointments,
       _calls = calls,
       super(
         const CallState(
           isBusy: false,
           cameraPermissionGranted: false,
           microphonePermissionGranted: false,
           appointments: <Appointment>[],
         ),
       );

  final AppointmentRepository _appointments;
  final TherapyCallRepository _calls;

  void toggleCameraPermission({required final bool granted}) {
    emit(state.copyWith(cameraPermissionGranted: granted));
  }

  void toggleMicrophonePermission({required final bool granted}) {
    emit(state.copyWith(microphonePermissionGranted: granted));
  }

  Future<void> refresh() async {
    emit(state.copyWith(isBusy: true));
    try {
      final list = await _appointments.listAppointmentsForCurrentRole();
      final currentSelection = state.selectedAppointmentId;
      final selected =
          currentSelection != null && list.any((a) => a.id == currentSelection)
          ? currentSelection
          : list.isEmpty
          ? null
          : list.first.id;
      if (isClosed) return;
      emit(
        state.copyWith(
          isBusy: false,
          appointments: list,
          selectedAppointmentId: selected,
          session: selected == state.selectedAppointmentId
              ? CallState._noChange
              : null,
        ),
      );
    } on Object catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, errorMessage: e.toString()));
    }
  }

  void selectAppointment(final String appointmentId) {
    emit(state.copyWith(selectedAppointmentId: appointmentId, session: null));
  }

  Future<void> createSession() async {
    final apptId = state.selectedAppointmentId;
    if (apptId == null) return;
    emit(state.copyWith(isBusy: true));
    try {
      final session = await _calls.createSession(appointmentId: apptId);
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, session: session));
    } on Object catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, errorMessage: e.toString()));
    }
  }

  Future<void> join() async {
    final session = state.session;
    if (session == null) return;
    if (!state.cameraPermissionGranted || !state.microphonePermissionGranted) {
      emit(
        state.copyWith(
          errorMessage: 'Permissions required (camera + microphone)',
        ),
      );
      return;
    }
    emit(state.copyWith(isBusy: true));
    try {
      final updated = await _calls.join(callSessionId: session.id);
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, session: updated));
    } on Object catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, errorMessage: e.toString()));
    }
  }
}
