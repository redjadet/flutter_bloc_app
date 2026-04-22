import 'package:flutter_bloc_app/features/online_therapy_demo/domain/entities/therapy_role.dart';

class TherapyUser {
  const TherapyUser({
    required this.id,
    required this.role,
    required this.displayName,
    required this.maskedEmail,
    required this.createdAt,
  });

  final String id;
  final TherapyRole role;
  final String displayName;
  final String maskedEmail;
  final DateTime createdAt;
}
