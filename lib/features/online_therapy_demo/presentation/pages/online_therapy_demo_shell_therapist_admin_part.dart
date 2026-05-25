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
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: CustomScrollView(
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
                const SliverToBoxAdapter(
                  child: SizedBox(height: 360, child: _MessagingPanel()),
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
                  child: SizedBox(height: 320, child: _CallPanel()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// eof
// end

class _AdminPanel extends StatelessWidget {
  const _AdminPanel();

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final isBusy = context.selectState<AdminCubit, AdminState, bool>(
      selector: (final state) => state.isBusy,
    );
    final errorMessage = context.selectState<AdminCubit, AdminState, String?>(
      selector: (final state) => state.errorMessage,
    );
    final pendingTherapists = context
        .selectState<AdminCubit, AdminState, List<TherapistProfile>>(
          selector: (final state) => state.pendingTherapists,
        );
    final auditEvents = context
        .selectState<AdminCubit, AdminState, List<AuditEvent>>(
          selector: (final state) => state.auditEvents,
        );
    final cubit = context.cubit<AdminCubit>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Admin — Therapist Verification',
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
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: Builder(
              builder: (context) {
                final List<Widget> items = <Widget>[
                  if (pendingTherapists.isEmpty)
                    const ListTile(title: Text('No pending therapists.'))
                  else
                    ...pendingTherapists.map(
                      (t) => ListTile(
                        title: Text(t.title),
                        subtitle: Text(t.bio),
                        trailing: ElevatedButton(
                          onPressed: isBusy ? null : () => cubit.approve(t.id),
                          child: Text(l10n.approveButtonLabel),
                        ),
                      ),
                    ),
                  const Divider(height: 24),
                  const Text(
                    'Security / audit proof',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  if (auditEvents.isEmpty)
                    const ListTile(title: Text('No audit events yet.'))
                  else
                    ...auditEvents.reversed
                        .take(8)
                        .map(
                          (event) => ListTile(
                            dense: true,
                            title: Text(event.action),
                            subtitle: Text(
                              'actor=${event.actorId} target=${event.targetId}',
                            ),
                          ),
                        ),
                ];
                return ListView(children: items);
              },
            ),
          ),
        ],
      ),
    );
  }
}
