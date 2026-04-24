import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/client_booking_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/widgets/online_therapy_logged_out_prompt.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/date_time_formatting.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:go_router/go_router.dart';

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
    final session = context.watchBloc<OnlineTherapyDemoSessionCubit>().state;
    final state = context.watchBloc<ClientBookingCubit>().state;
    final cubit = context.cubit<ClientBookingCubit>();

    final therapist = state.therapists
        .where((t) => t.id == widget.therapistId)
        .cast<TherapistProfile?>()
        .firstOrNull;
    final List<Widget> items = <Widget>[
      if (session.user == null) const OnlineTherapyLoggedOutPrompt(),
      if (session.user == null) const SizedBox(height: 12),
      if (therapist == null)
        const Text(
          'Therapist not found.',
          style: TextStyle(color: Colors.red),
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
            onPressed: state.isBusy
                ? null
                : () => unawaited(
                    cubit.loadAvailability(therapistId: widget.therapistId),
                  ),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      if (state.availability.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(state.isBusy ? 'Loading…' : 'No slots for today.'),
        )
      else
        ...state.availability.map(
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
                      onPressed: state.isBusy
                          ? null
                          : () {
                              cubit.setPendingBookingSlot(slot);
                              unawaited(
                                context.pushNamed(
                                  AppRoutes
                                      .onlineTherapyDemoClientBookingConfirm,
                                ),
                              );
                            },
                      child: const Text('Book'),
                    )
                  : const Text('Booked'),
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

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

// eof
// end
//
