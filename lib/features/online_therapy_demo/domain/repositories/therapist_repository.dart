import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';

abstract interface class TherapistRepository {
  Future<List<TherapistProfile>> listTherapists({
    String? query,
    String? specialty,
    String? language,
  });

  Future<TherapistProfile> getTherapist({
    required String therapistId,
  });

  Future<List<AvailabilitySlot>> listAvailability({
    required String therapistId,
    required DateTime date,
  });
}
