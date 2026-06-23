import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/appointment_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/therapy_call_repository.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/shared/utils/request_id_guard.dart';

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
    required this._appointments,
    required this._calls,
  }) : super(
         const CallState(
           isBusy: false,
           cameraPermissionGranted: false,
           microphonePermissionGranted: false,
           appointments: <Appointment>[],
         ),
       );

  final AppointmentRepository _appointments;
  final TherapyCallRepository _calls;
  final RequestIdGuard _operationGuard = RequestIdGuard();

  bool _isRequestStillActive(final int requestId) =>
      !isClosed && _operationGuard.isCurrent(requestId);

  void toggleCameraPermission({required final bool granted}) {
    emit(state.copyWith(cameraPermissionGranted: granted));
  }

  void toggleMicrophonePermission({required final bool granted}) {
    emit(state.copyWith(microphonePermissionGranted: granted));
  }

  Future<void> refresh() async {
    final requestId = _operationGuard.next();
    emit(state.copyWith(isBusy: true));
    await CubitExceptionHandler.executeAsync(
      operation: () => _appointments.listAppointmentsForCurrentRole(),
      onSuccess: (list) {
        if (!_isRequestStillActive(requestId)) return;
        final currentSelection = state.selectedAppointmentId;
        final selected =
            currentSelection != null &&
                list.any((a) => a.id == currentSelection)
            ? currentSelection
            : list.isEmpty
            ? null
            : list.first.id;
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
      },
      onError: (message) {
        if (!_isRequestStillActive(requestId)) return;
        emit(state.copyWith(isBusy: false, errorMessage: message));
      },
      logContext: 'CallCubit.refresh',
      isAlive: () => !isClosed,
    );
  }

  void selectAppointment(final String appointmentId) {
    _operationGuard.invalidate();
    emit(
      state.copyWith(
        isBusy: false,
        selectedAppointmentId: appointmentId,
        session: null,
      ),
    );
  }

  Future<void> createSession() async {
    final apptId = state.selectedAppointmentId;
    if (apptId == null) return;
    final requestId = _operationGuard.next();
    emit(state.copyWith(isBusy: true));
    await CubitExceptionHandler.executeAsync(
      operation: () => _calls.createSession(appointmentId: apptId),
      onSuccess: (session) {
        if (!_isRequestStillActive(requestId)) return;
        emit(state.copyWith(isBusy: false, session: session));
      },
      onError: (message) {
        if (!_isRequestStillActive(requestId)) return;
        emit(state.copyWith(isBusy: false, errorMessage: message));
      },
      logContext: 'CallCubit.createSession',
      isAlive: () => !isClosed,
    );
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
    final requestId = _operationGuard.next();
    emit(state.copyWith(isBusy: true));
    await CubitExceptionHandler.executeAsync(
      operation: () => _calls.join(callSessionId: session.id),
      onSuccess: (updated) {
        if (!_isRequestStillActive(requestId)) return;
        emit(state.copyWith(isBusy: false, session: updated));
      },
      onError: (message) {
        if (!_isRequestStillActive(requestId)) return;
        emit(state.copyWith(isBusy: false, errorMessage: message));
      },
      logContext: 'CallCubit.join',
      isAlive: () => !isClosed,
    );
  }
}
