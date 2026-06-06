import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/online_therapy_fake_api.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/online_therapy_network_mode.dart';
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
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/date_time_formatting.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

part 'online_therapy_demo_shell_client_details.part.dart';
part 'online_therapy_demo_shell_client_part.dart';
part 'online_therapy_demo_shell_controls.part.dart';
part 'online_therapy_demo_shell_messaging_call.part.dart';
part 'online_therapy_demo_shell_therapist_admin_part.dart';

/// Sidebar width for wide online-therapy demo split layouts.
double _onlineTherapySidebarWidth(final double maxWidth) =>
    math.min(320, maxWidth * 0.35).clamp(240, 320).toDouble();

/// Height for embedded messaging/call panels inside scrollable demo shells.
double _onlineTherapyEmbeddedPanelHeight({
  required final double referenceHeight,
  required final double viewportFraction,
  final double minHeight = 220,
  final double maxHeight = 420,
}) {
  return (referenceHeight * viewportFraction).clamp(minHeight, maxHeight);
}

class OnlineTherapyDemoShellPage extends StatelessWidget {
  const OnlineTherapyDemoShellPage({super.key});

  @override
  Widget build(final BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider>[
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
        child: const _OnlineTherapyDemoBody(),
      ),
    );
  }
}
// eof
// end

class _OnlineTherapyDemoBody extends StatelessWidget {
  const _OnlineTherapyDemoBody();

  @override
  Widget build(final BuildContext context) {
    final role = context
        .selectState<
          OnlineTherapyDemoSessionCubit,
          OnlineTherapyDemoSessionState,
          TherapyRole
        >(
          selector: (final state) => state.role,
        );
    final user = context
        .selectState<
          OnlineTherapyDemoSessionCubit,
          OnlineTherapyDemoSessionState,
          TherapyUser?
        >(
          selector: (final state) => state.user,
        );
    final errorMessage = context
        .selectState<
          OnlineTherapyDemoSessionCubit,
          OnlineTherapyDemoSessionState,
          String?
        >(
          selector: (final state) => state.errorMessage,
        );

    return CommonPageLayout(
      title: 'Online Therapy Demo',
      body: Column(
        children: <Widget>[
          const _TopControls(),
          if (errorMessage case final String message?)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: user == null
                ? const _LoginPanel()
                : switch (role) {
                    TherapyRole.client => const _ClientBookingPanel(),
                    TherapyRole.therapist => const _TherapistPanel(),
                    TherapyRole.admin => const _AdminPanel(),
                  },
          ),
        ],
      ),
    );
  }
}
