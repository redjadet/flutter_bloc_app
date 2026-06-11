// Split loader helpers share Cubit internals from the owning library.
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

part of 'client_booking_cubit.dart';

extension _ClientBookingCubitHelpers on ClientBookingCubit {
  void _handleOperationError(
    final int requestId,
    final Object error,
    final StackTrace stackTrace,
    final String operation,
  ) {
    if (!_isRequestStillActive(requestId)) return;
    CubitExceptionHandler.handleException(
      error,
      stackTrace,
      operation,
      onError: (final message) =>
          emit(state.copyWith(isBusy: false, errorMessage: message)),
    );
  }
}

extension _ClientBookingCubitLoaders on ClientBookingCubit {
  Future<void> _loadTherapistsBody(final int requestId) async {
    final list = await _therapists.listTherapists();
    if (!_isRequestStillActive(requestId)) return;
    final currentSelection = state.selectedTherapistId;
    final selected =
        currentSelection != null && list.any((t) => t.id == currentSelection)
        ? currentSelection
        : list.isEmpty
        ? null
        : list.first.id;
    emit(
      state.copyWith(
        therapists: list,
        selectedTherapistId: selected,
        availability: selected != null && selected == currentSelection
            ? null
            : <AvailabilitySlot>[],
      ),
    );
  }

  Future<void> _loadAppointmentsBody(final int requestId) async {
    final list = await _appointments.listAppointmentsForCurrentRole();
    if (!_isRequestStillActive(requestId)) return;
    emit(state.copyWith(appointments: list));
  }

  Future<void> _loadSelectedAvailabilityBody(final int requestId) async {
    final selected = state.selectedTherapistId;
    if (selected == null) return;
    final slots = await _therapists.listAvailability(
      therapistId: selected,
      date: ClientBookingCubit._demoAvailabilityDate,
    );
    if (!_isRequestStillActive(requestId)) return;
    if (state.selectedTherapistId != selected) return;
    emit(state.copyWith(availability: slots, clearErrorMessage: true));
  }
}
