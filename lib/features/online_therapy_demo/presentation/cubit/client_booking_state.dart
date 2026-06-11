import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';

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
    bool clearErrorMessage = false,
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
    errorMessage: clearErrorMessage
        ? null
        : (errorMessage ?? this.errorMessage),
  );
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
