import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/utils/date_time_formatting.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/client_booking_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/widgets/online_therapy_logged_out_prompt.dart';
import 'package:go_router/go_router.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';

class OnlineTherapyDemoClientTherapistDetailPage extends StatefulWidget {
  const OnlineTherapyDemoClientTherapistDetailPage({
    required this.therapistId,
    super.key,
  });

  final String therapistId;

  @override
  State<OnlineTherapyDemoClientTherapistDetailPage> createState() =>
      _OnlineTherapyDemoClientTherapistDetailPageState();
}

class _OnlineTherapyDemoClientTherapistDetailPageState
    extends State<OnlineTherapyDemoClientTherapistDetailPage> {
  String? _lastLoadedTherapistId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_lastLoadedTherapistId == widget.therapistId) return;
    _lastLoadedTherapistId = widget.therapistId;
    unawaited(
      context.cubit<ClientBookingCubit>().selectTherapist(widget.therapistId),
    );
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
    final therapist = context
        .selectState<ClientBookingCubit, ClientBookingState, TherapistProfile?>(
          selector: (final state) => state.therapistById(widget.therapistId),
        );
    final availability = context
        .selectState<
          ClientBookingCubit,
          ClientBookingState,
          List<AvailabilitySlot>
        >(
          selector: (final state) => state.availability,
        );
    final isBusy = context
        .selectState<ClientBookingCubit, ClientBookingState, bool>(
          selector: (final state) => state.isBusy,
        );
    final cubit = context.cubit<ClientBookingCubit>();
    final List<Widget> items = <Widget>[
      if (!isLoggedIn) const OnlineTherapyLoggedOutPrompt(),
      if (!isLoggedIn) const SizedBox(height: 12),
      if (therapist == null)
        Text(
          'Therapist not found.',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        )
      else ...<Widget>[
        Text(
          'Rating: ${therapist.rating.toStringAsFixed(1)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(therapist.bio),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            ...therapist.specialties.map((s) => Chip(label: Text(s))),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Languages: ${therapist.languages.join(', ')}',
        ),
      ],
      const Divider(height: 24),
      Row(
        children: <Widget>[
          const Expanded(
            child: Text(
              'Availability',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            onPressed: isBusy
                ? null
                : () {
                    // check-ignore: side_effects_build - user gesture (refresh).
                    unawaited(
                      cubit.loadAvailability(therapistId: widget.therapistId),
                    );
                  },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      if (availability.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(isBusy ? 'Loading…' : 'No slots for today.'),
        )
      else
        ...availability.map(
          (slot) => Card(
            child: ListTile(
              title: Text(
                formatDeviceTimeRange(context, slot.startAt, slot.endAt),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text('Status: ${slot.status.name}'),
              trailing: slot.status == AvailabilitySlotStatus.available
                  ? ElevatedButton(
                      onPressed: isBusy
                          ? null
                          : () {
                              cubit.setPendingBookingSlot(slot);
                              // check-ignore: side_effects_build - user gesture (book).
                              unawaited(
                                context.pushNamed(
                                  AppRoutes
                                      .onlineTherapyDemoClientBookingConfirm,
                                ),
                              );
                            },
                      child: Text(l10n.bookButtonLabel),
                    )
                  : Text(l10n.bookedLabel),
            ),
          ),
        ),
    ];

    return CommonPageLayout(
      title: therapist?.title ?? 'Therapist',
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
