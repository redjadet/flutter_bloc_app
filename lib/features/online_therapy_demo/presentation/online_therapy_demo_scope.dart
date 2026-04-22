import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/online_therapy_fake_api.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/appointment_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/audit_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/therapist_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/therapy_admin_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/therapy_auth_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/therapy_call_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/therapy_messaging_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/admin_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/call_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/client_booking_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/messaging_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/therapist_home_cubit.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';

/// Owns all Online Therapy demo Cubits for the full `/online-therapy-demo/**` subtree.
///
/// Hard rule: child pages must not create demo Cubits; they must read them
/// from this scope under a ShellRoute.
class OnlineTherapyDemoScope extends StatelessWidget {
  const OnlineTherapyDemoScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(final BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<OnlineTherapyDemoSessionCubit>(
          create: (_) => OnlineTherapyDemoSessionCubit(
            auth: getIt<TherapyAuthRepository>(),
            api: getIt<OnlineTherapyFakeApi>(),
          ),
        ),
        BlocProvider<ClientBookingCubit>(
          create: (_) => ClientBookingCubit(
            therapists: getIt<TherapistRepository>(),
            appointments: getIt<AppointmentRepository>(),
          ),
        ),
        BlocProvider<TherapistHomeCubit>(
          create: (_) => TherapistHomeCubit(
            appointments: getIt<AppointmentRepository>(),
          ),
        ),
        BlocProvider<AdminCubit>(
          create: (_) => AdminCubit(
            admin: getIt<TherapyAdminRepository>(),
            audit: getIt<AuditRepository>(),
          ),
        ),
        BlocProvider<MessagingCubit>(
          create: (_) => MessagingCubit(
            messaging: getIt<TherapyMessagingRepository>(),
          ),
        ),
        BlocProvider<CallCubit>(
          create: (_) => CallCubit(
            appointments: getIt<AppointmentRepository>(),
            calls: getIt<TherapyCallRepository>(),
          ),
        ),
      ],
      child: BlocListener<OnlineTherapyDemoSessionCubit, OnlineTherapyDemoSessionState>(
        listenWhen: (prev, next) =>
            prev.user != next.user || prev.role != next.role,
        listener: (context, state) {
          if (state.user != null && state.role == TherapyRole.client) {
            // check-ignore: side_effects_build - BlocListener listener is event-driven.
            unawaited(context.cubit<ClientBookingCubit>().refresh());
          }
          if (state.user != null && state.role == TherapyRole.therapist) {
            // check-ignore: side_effects_build - BlocListener listener is event-driven.
            unawaited(context.cubit<TherapistHomeCubit>().refresh());
          }
          if (state.user != null && state.role == TherapyRole.admin) {
            // check-ignore: side_effects_build - BlocListener listener is event-driven.
            unawaited(context.cubit<AdminCubit>().refresh());
          }
          if (state.user != null) {
            // check-ignore: side_effects_build - BlocListener listener is event-driven.
            unawaited(context.cubit<MessagingCubit>().refresh());
            // check-ignore: side_effects_build - BlocListener listener is event-driven.
            unawaited(context.cubit<CallCubit>().refresh());
          }
        },
        child: child,
      ),
    );
  }
}

// eof
// end
//
