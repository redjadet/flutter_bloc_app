part of 'online_therapy_demo_shell_page.dart';

class _TherapistPanel extends StatelessWidget {
  const _TherapistPanel();

  @override
  Widget build(final BuildContext context) {
    final isBusy = context
        .selectState<TherapistHomeCubit, TherapistHomeState, bool>(
          selector: (final state) => state.isBusy,
        );
    final errorMessage = context
        .selectState<TherapistHomeCubit, TherapistHomeState, String?>(
          selector: (final state) => state.errorMessage,
        );
    final selectedAppointments = context
        .selectState<TherapistHomeCubit, TherapistHomeState, List<Appointment>>(
          selector: (final state) => state.appointments,
        );
    final cubit = context.cubit<TherapistHomeCubit>();
    final appointments = List<Appointment>.unmodifiable(selectedAppointments);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Therapist — Appointments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: isBusy ? null : () => cubit.refresh(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          if (errorMessage case final String message?)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double messagingHeight =
                    _onlineTherapyEmbeddedPanelHeight(
                      referenceHeight: constraints.maxHeight,
                      viewportFraction: 0.38,
                    );
                final double callHeight = _onlineTherapyEmbeddedPanelHeight(
                  referenceHeight: constraints.maxHeight,
                  viewportFraction: 0.32,
                );
                return CustomScrollView(
                  slivers: <Widget>[
                    if (appointments.isEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('No appointments yet.'),
                        ),
                      )
                    else
                      SliverList.builder(
                        itemCount: appointments.length,
                        itemBuilder: (context, index) {
                          if (index >= appointments.length) {
                            return const SizedBox.shrink();
                          }
                          final a = appointments[index];
                          return ListTile(
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
                    const SliverToBoxAdapter(child: Divider(height: 24)),
                    const SliverToBoxAdapter(
                      child: Text(
                        'Messaging',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: messagingHeight,
                        child: const _MessagingPanel(),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    const SliverToBoxAdapter(
                      child: Text(
                        'Video (pre-call + join/fallback)',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: callHeight,
                        child: const _CallPanel(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
