import 'package:flutter_bloc_app/features/online_therapy_demo/domain/appointment_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/audit_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/online_therapy_network_mode_controller.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/therapist_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/therapy_admin_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/therapy_auth_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/therapy_call_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/therapy_messaging_repository.dart';

/// Composition-root dependencies for the Online Therapy demo subtree.
class OnlineTherapyDemoDependencies {
  const OnlineTherapyDemoDependencies({
    required this.auth,
    required this.networkModeController,
    required this.therapists,
    required this.appointments,
    required this.admin,
    required this.audit,
    required this.messaging,
    required this.calls,
  });

  final TherapyAuthRepository auth;
  final OnlineTherapyNetworkModeController networkModeController;
  final TherapistRepository therapists;
  final AppointmentRepository appointments;
  final TherapyAdminRepository admin;
  final AuditRepository audit;
  final TherapyMessagingRepository messaging;
  final TherapyCallRepository calls;
}
