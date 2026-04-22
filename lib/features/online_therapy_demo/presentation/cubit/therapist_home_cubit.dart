import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/appointment_repository.dart';

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
  TherapistHomeCubit({required final AppointmentRepository appointments})
    : _appointments = appointments,
      super(
        const TherapistHomeState(isBusy: false, appointments: <Appointment>[]),
      );

  final AppointmentRepository _appointments;

  Future<void> refresh() async {
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
}
