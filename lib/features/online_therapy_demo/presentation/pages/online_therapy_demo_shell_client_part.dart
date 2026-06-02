part of 'online_therapy_demo_shell_page.dart';

class _ClientBookingPanel extends StatelessWidget {
  const _ClientBookingPanel();

  @override
  Widget build(final BuildContext context) {
    final viewState = context
        .selectState<
          ClientBookingCubit,
          ClientBookingState,
          ({
            List<TherapistProfile> therapists,
            String? selectedTherapistId,
            TherapistProfile? selectedTherapist,
            List<AvailabilitySlot> availability,
            List<Appointment> appointments,
            bool isBusy,
            String? errorMessage,
          })
        >(
          selector: (final state) => (
            therapists: state.therapists,
            selectedTherapistId: state.selectedTherapistId,
            selectedTherapist: state.selectedTherapist,
            availability: state.availability,
            appointments: state.appointments,
            isBusy: state.isBusy,
            errorMessage: state.errorMessage,
          ),
        );
    final cubit = context.cubit<ClientBookingCubit>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool wide = constraints.maxWidth >= 900;
        final therapistList = _TherapistList(
          therapists: viewState.therapists,
          selectedId: viewState.selectedTherapistId,
          onSelect: cubit.selectTherapist,
        );
        final details = _TherapistDetails(
          therapist: viewState.selectedTherapist,
          availability: viewState.availability,
          appointments: viewState.appointments,
          isBusy: viewState.isBusy,
          error: viewState.errorMessage,
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
        return ListView(children: items);
      },
    );
  }
}

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
          key: ValueKey<String>('client-booking-therapist-${t.id}'),
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
