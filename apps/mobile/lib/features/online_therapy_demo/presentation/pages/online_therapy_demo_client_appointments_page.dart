import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/utils/date_time_formatting.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/client_booking_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/widgets/online_therapy_logged_out_prompt.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.cubit<ClientBookingCubit>().loadAppointments());
    });
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final isLoggedIn = context
        .selectState<
          OnlineTherapyDemoSessionCubit,
          OnlineTherapyDemoSessionState,
          bool
        >(
          selector: (final state) => state.isLoggedIn,
        );
    final isBusy = context
        .selectState<ClientBookingCubit, ClientBookingState, bool>(
          selector: (final state) => state.isBusy,
        );
    final selectedAppointments = context
        .selectState<ClientBookingCubit, ClientBookingState, List<Appointment>>(
          selector: (final state) => state.appointments,
        );
    final cubit = context.cubit<ClientBookingCubit>();
    final appointments = List<Appointment>.unmodifiable(selectedAppointments);

    return CommonPageLayout(
      title: 'My appointments',
      body: RefreshIndicator(
        onRefresh: cubit.loadAppointments,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: !isLoggedIn ? 1 : appointments.length + 1,
          separatorBuilder: (final context, final index) =>
              const Divider(height: 1),
          itemBuilder: (context, index) {
            if (index == 0) {
              if (!isLoggedIn) {
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
                    isBusy ? 'Loading…' : 'Your booked sessions.',
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
                      onPressed: isBusy
                          ? null
                          : () => cubit.cancelAppointment(a.id),
                      child: Text(l10n.cancelButtonLabel),
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
