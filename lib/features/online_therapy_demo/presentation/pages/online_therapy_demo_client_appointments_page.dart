import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/client_booking_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/widgets/online_therapy_logged_out_prompt.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/date_time_formatting.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

class OnlineTherapyDemoClientAppointmentsPage extends StatefulWidget {
  const OnlineTherapyDemoClientAppointmentsPage({super.key});

  @override
  State<OnlineTherapyDemoClientAppointmentsPage> createState() =>
      _OnlineTherapyDemoClientAppointmentsPageState();
}

class _OnlineTherapyDemoClientAppointmentsPageState
    extends State<OnlineTherapyDemoClientAppointmentsPage> {
  @override
  void initState() {
    super.initState();
    unawaited(context.cubit<ClientBookingCubit>().loadAppointments());
  }

  @override
  Widget build(final BuildContext context) {
    final session = context.watchBloc<OnlineTherapyDemoSessionCubit>().state;
    final state = context.watchBloc<ClientBookingCubit>().state;
    final cubit = context.cubit<ClientBookingCubit>();
    final appointments = List<Appointment>.unmodifiable(state.appointments);

    return CommonPageLayout(
      title: 'My appointments',
      body: RefreshIndicator(
        onRefresh: cubit.loadAppointments,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: session.user == null ? 1 : appointments.length + 1,
          separatorBuilder: (final context, final index) =>
              const Divider(height: 1),
          itemBuilder: (context, index) {
            if (index == 0) {
              if (session.user == null) {
                return const KeyedSubtree(
                  key: ValueKey(
                    'online-therapy-client-appointments-logged-out',
                  ),
                  child: OnlineTherapyLoggedOutPrompt(),
                );
              }
              return KeyedSubtree(
                key: const ValueKey(
                  'online-therapy-client-appointments-header',
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    state.isBusy ? 'Loading…' : 'Your booked sessions.',
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
                'online-therapy-client-appointment-${a.id}',
              ),
              title: Text(
                formatDeviceDateTime(context, a.startAt),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                'Therapist: ${a.therapistId} • Status: ${a.status.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: a.status == AppointmentStatus.cancelled
                  ? null
                  : TextButton(
                      onPressed: state.isBusy
                          ? null
                          : () => cubit.cancelAppointment(a.id),
                      child: const Text('Cancel'),
                    ),
            );
          },
        ),
      ),
    );
  }
}

// eof
// end
//
