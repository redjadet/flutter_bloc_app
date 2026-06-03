part of 'online_therapy_demo_shell_page.dart';

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
    final l10n = context.l10n;
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
                style: TextStyle(color: Theme.of(context).colorScheme.error),
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
                      key: ValueKey<String>(
                        'client-booking-availability-${slot.startAt.toIso8601String()}',
                      ),
                      contentPadding: EdgeInsets.zero,
                      title: Text(formatDeviceDateTime(context, slot.startAt)),
                      subtitle: Text(formatDeviceDateTime(context, slot.endAt)),
                      trailing: ElevatedButton(
                        onPressed: isBusy || !canBook
                            ? null
                            : () => onBook(slot),
                        child: Text(
                          canBook ? l10n.bookButtonLabel : l10n.bookedLabel,
                        ),
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
                        key: ValueKey<String>(
                          'client-booking-appointment-${a.id}',
                        ),
                        contentPadding: EdgeInsets.zero,
                        title: Text(formatDeviceDateTime(context, a.startAt)),
                        subtitle: Text('Status: ${a.status.name}'),
                        trailing: a.status == AppointmentStatus.cancelled
                            ? Text(l10n.cancelledLabel)
                            : TextButton(
                                onPressed: isBusy ? null : () => onCancel(a.id),
                                child: Text(l10n.cancelButtonLabel),
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
