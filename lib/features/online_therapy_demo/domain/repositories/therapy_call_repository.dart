import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';

abstract interface class TherapyCallRepository {
  Future<CallSession> createSession({
    required String appointmentId,
  });

  Future<CallSession> join({
    required String callSessionId,
  });
}
