import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';

abstract interface class TherapyAuthRepository {
  TherapyUser? get currentUser;

  Future<TherapyUser> login({
    required String email,
    required TherapyRole role,
  });

  Future<void> logout();
}
