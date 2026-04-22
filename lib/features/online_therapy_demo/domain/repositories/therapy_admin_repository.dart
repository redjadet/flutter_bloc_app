import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';

abstract interface class TherapyAdminRepository {
  Future<List<TherapistProfile>> listPendingTherapists();

  Future<TherapistProfile> approveTherapist({
    required String therapistId,
  });
}
