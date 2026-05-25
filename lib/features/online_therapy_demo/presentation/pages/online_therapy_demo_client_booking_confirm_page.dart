import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/client_booking_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/widgets/online_therapy_logged_out_prompt.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/date_time_formatting.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/shared/widgets/responsive_action_bar.dart';
import 'package:go_router/go_router.dart';

class OnlineTherapyDemoClientBookingConfirmPage extends StatelessWidget {
  const OnlineTherapyDemoClientBookingConfirmPage({super.key});

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
    final slot = context
        .selectState<ClientBookingCubit, ClientBookingState, AvailabilitySlot?>(
          selector: (final state) => state.pendingBookingSlot,
        );
    final isBusy = context
        .selectState<ClientBookingCubit, ClientBookingState, bool>(
          selector: (final state) => state.isBusy,
        );
    final cubit = context.cubit<ClientBookingCubit>();
    final List<Widget> items = <Widget>[
      if (!isLoggedIn) const OnlineTherapyLoggedOutPrompt(),
      if (!isLoggedIn) const SizedBox(height: 12),
      if (slot == null)
        const Card(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'No pending slot selected. Go back and pick a time.',
            ),
          ),
        )
      else
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Booking summary',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text('Therapist: ${slot.therapistId}'),
                Text(
                  'Start: ${formatDeviceDateTime(context, slot.startAt)}',
                ),
                Text('End: ${formatDeviceDateTime(context, slot.endAt)}'),
              ],
            ),
          ),
        ),
      const SizedBox(height: 12),
      ResponsiveDualCtaRow(
        start: OutlinedButton(
          onPressed: isBusy
              ? null
              : () {
                  cubit.clearPendingBookingSlot();
                  context.pop();
                },
          child: Text(l10n.cancelButtonLabel),
        ),
        end: ElevatedButton(
          onPressed: isBusy || slot == null
              ? null
              : () async {
                  await cubit.createAppointmentFromSlot(slot);
                  if (!context.mounted) return;
                  context.goNamed(
                    AppRoutes.onlineTherapyDemoClientAppointments,
                  );
                },
          child: Text(isBusy ? 'Booking…' : 'Confirm'),
        ),
      ),
      const SizedBox(height: 12),
      const Text(
        'This is a demo flow. In production you would also confirm payment, consent, and policy acknowledgements here.',
      ),
    ];

    return CommonPageLayout(
      title: 'Confirm booking',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: items,
      ),
    );
  }
}

// eof
// end
//
