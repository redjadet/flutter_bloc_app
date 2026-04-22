import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';

abstract interface class AuditRepository {
  Future<List<AuditEvent>> listEvents();
}
