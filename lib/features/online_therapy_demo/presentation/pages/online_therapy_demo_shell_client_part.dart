part of 'online_therapy_demo_shell_page.dart';

class _ClientBookingPanel extends StatelessWidget {
  const _ClientBookingPanel();

  @override
  Widget build(final BuildContext context) {
    final state = context.watchBloc<ClientBookingCubit>().state;
    final cubit = context.cubit<ClientBookingCubit>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool wide = constraints.maxWidth >= 900;
        final therapistList = _TherapistList(
          therapists: state.therapists,
          selectedId: state.selectedTherapistId,
          onSelect: cubit.selectTherapist,
        );
        final details = _TherapistDetails(
          therapist: state.selectedTherapist,
          availability: state.availability,
          appointments: state.appointments,
          isBusy: state.isBusy,
          error: state.errorMessage,
          onBook: cubit.createAppointmentFromSlot,
          onCancel: cubit.cancelAppointment,
          onRefresh: cubit.refresh,
        );

        if (wide) {
          return Row(
            children: <Widget>[
              SizedBox(width: 320, child: therapistList),
              const VerticalDivider(width: 1),
              Expanded(child: details),
            ],
          );
        }
        final List<Widget> items = <Widget>[
          SizedBox(height: 360, child: therapistList),
          const Divider(height: 1),
          const SizedBox(height: 16),
          SizedBox(height: 720, child: details),
        ];
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => items[index],
        );
      },
    );
  }
}
// eof
// end

class _TherapistList extends StatelessWidget {
  const _TherapistList({
    required this.therapists,
    required this.selectedId,
    required this.onSelect,
  });

  final List<TherapistProfile> therapists;
  final String? selectedId;
  final Future<void> Function(String therapistId) onSelect;

  @override
  Widget build(final BuildContext context) {
    if (therapists.isEmpty) {
      return const Center(child: Text('No therapists found.'));
    }
    return ListView.separated(
      itemCount: therapists.length,
      separatorBuilder: (final _, final index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final t = therapists[index];
        final selected = t.id == selectedId;
        return ListTile(
          selected: selected,
          title: Text(t.title),
          subtitle: Text(
            '${t.specialties.join(', ')} • ${t.languages.join(', ')}',
          ),
          trailing: Text(t.rating.toStringAsFixed(1)),
          onTap: () => onSelect(t.id),
        );
      },
    );
  }
}

class _TherapistDetails extends StatelessWidget {
  const _TherapistDetails({
    required this.therapist,
    required this.availability,
    required this.appointments,
    required this.isBusy,
    required this.error,
    required this.onBook,
    required this.onCancel,
    required this.onRefresh,
  });

  final TherapistProfile? therapist;
  final List<AvailabilitySlot> availability;
  final List<Appointment> appointments;
  final bool isBusy;
  final String? error;
  final Future<void> Function(AvailabilitySlot slot) onBook;
  final Future<void> Function(String appointmentId) onCancel;
  final Future<void> Function() onRefresh;

  @override
  Widget build(final BuildContext context) {
    final t = therapist;
    if (t == null) {
      return const Center(child: Text('Select a therapist.'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  t.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: isBusy ? null : () => onRefresh(),
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(t.bio),
          const SizedBox(height: 12),
          if (error case final String errorMessage?)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: CustomScrollView(
              slivers: <Widget>[
                const SliverToBoxAdapter(
                  child: Text(
                    'Availability (today)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                SliverList.separated(
                  itemCount: availability.length,
                  itemBuilder: (context, index) {
                    final slot = availability[index];
                    final canBook =
                        slot.status == AvailabilitySlotStatus.available;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(formatDeviceDateTime(context, slot.startAt)),
                      subtitle: Text(formatDeviceDateTime(context, slot.endAt)),
                      trailing: ElevatedButton(
                        onPressed: isBusy || !canBook
                            ? null
                            : () => onBook(slot),
                        child: Text(canBook ? 'Book' : 'Booked'),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                const SliverToBoxAdapter(
                  child: Text(
                    'My appointments',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                if (appointments.isEmpty)
                  const SliverToBoxAdapter(child: Text('No appointments yet.'))
                else
                  SliverList.separated(
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final a = appointments[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(formatDeviceDateTime(context, a.startAt)),
                        subtitle: Text('Status: ${a.status.name}'),
                        trailing: a.status == AppointmentStatus.cancelled
                            ? const Text('Cancelled')
                            : TextButton(
                                onPressed: isBusy ? null : () => onCancel(a.id),
                                child: const Text('Cancel'),
                              ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                const SliverToBoxAdapter(
                  child: Text(
                    'Messaging',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 320, child: _MessagingPanel()),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                const SliverToBoxAdapter(
                  child: Text(
                    'Video (pre-call + join/fallback)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 280, child: _CallPanel()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
