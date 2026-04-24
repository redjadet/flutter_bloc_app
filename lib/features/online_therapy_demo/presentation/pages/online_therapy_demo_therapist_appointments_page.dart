import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/therapist_home_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/widgets/online_therapy_logged_out_prompt.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/date_time_formatting.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

class OnlineTherapyDemoTherapistAppointmentsPage extends StatefulWidget {
  const OnlineTherapyDemoTherapistAppointmentsPage({super.key});

  @override
  State<OnlineTherapyDemoTherapistAppointmentsPage> createState() =>
      _OnlineTherapyDemoTherapistAppointmentsPageState();
}

class _OnlineTherapyDemoTherapistAppointmentsPageState
    extends State<OnlineTherapyDemoTherapistAppointmentsPage> {
  @override
  void initState() {
    super.initState();
    unawaited(context.cubit<TherapistHomeCubit>().refresh());
  }

  @override
  Widget build(final BuildContext context) {
    final session = context.watchBloc<OnlineTherapyDemoSessionCubit>().state;
    final state = context.watchBloc<TherapistHomeCubit>().state;
    final cubit = context.cubit<TherapistHomeCubit>();
    final appointments = List<Appointment>.unmodifiable(state.appointments);

    return CommonPageLayout(
      title: 'Appointments',
      actions: <Widget>[
        IconButton(
          onPressed: state.isBusy ? null : () => cubit.refresh(),
          icon: const Icon(Icons.refresh),
        ),
      ],
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length + 1,
        separatorBuilder: (final context, final index) =>
            const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index == 0) {
            if (session.user == null) {
              return const KeyedSubtree(
                key: ValueKey(
                  'online-therapy-therapist-appointments-header-logged-out',
                ),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: OnlineTherapyLoggedOutPrompt(),
                ),
              );
            }
            if (state.errorMessage case final String errorMessage?) {
              return KeyedSubtree(
                key: const ValueKey(
                  'online-therapy-therapist-appointments-header-error',
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }
            return KeyedSubtree(
              key: const ValueKey(
                'online-therapy-therapist-appointments-header-ok',
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  state.isBusy ? 'Loading…' : 'Your upcoming sessions.',
                ),
              ),
            );
          }
          final appointmentIndex = index - 1;
          if (appointmentIndex >= appointments.length) {
            return const SizedBox.shrink();
          }
          final a = appointments[appointmentIndex];
          return ListTile(
            key: ValueKey<String>(
              'online-therapy-therapist-appointment-${a.id}',
            ),
            title: Text(
              formatDeviceDateTime(context, a.startAt),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              'Client: ${a.clientId} • Status: ${a.status.name}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
    );
  }
}

// eof
// end
//
