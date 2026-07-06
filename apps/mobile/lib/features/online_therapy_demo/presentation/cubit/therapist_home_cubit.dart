import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/appointment_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';

class TherapistHomeState {
  const TherapistHomeState({
    required this.isBusy,
    required this.appointments,
    this.errorMessage,
  });

  final bool isBusy;
  final List<Appointment> appointments;
  final String? errorMessage;

  TherapistHomeState copyWith({
    bool? isBusy,
    List<Appointment>? appointments,
    String? errorMessage,
  }) => TherapistHomeState(
    isBusy: isBusy ?? this.isBusy,
    appointments: appointments ?? this.appointments,
    errorMessage: errorMessage,
  );
}

class TherapistHomeCubit extends Cubit<TherapistHomeState> {
  TherapistHomeCubit({required this._appointments})
    : super(
        const TherapistHomeState(isBusy: false, appointments: <Appointment>[]),
      );

  final AppointmentRepository _appointments;

  Future<void> refresh() async {
    emit(state.copyWith(isBusy: true));
    await CubitExceptionHandler.executeAsync(
      operation: () => _appointments.listAppointmentsForCurrentRole(),
      onSuccess: (list) {
        if (isClosed) return;
        emit(state.copyWith(isBusy: false, appointments: list));
      },
      onError: (message) {
        if (isClosed) return;
        emit(state.copyWith(isBusy: false, errorMessage: message));
      },
      logContext: 'TherapistHomeCubit.refresh',
      isAlive: () => !isClosed,
    );
  }
}
