import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/call_cubit.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';

class OnlineTherapyCallView extends StatelessWidget {
  const OnlineTherapyCallView({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final viewState = context
        .selectState<
          CallCubit,
          CallState,
          ({
            bool isBusy,
            bool cameraPermissionGranted,
            bool microphonePermissionGranted,
            List<Appointment> appointments,
            String? selectedAppointmentId,
            CallSession? session,
            String? errorMessage,
          })
        >(
          selector: (final state) => (
            isBusy: state.isBusy,
            cameraPermissionGranted: state.cameraPermissionGranted,
            microphonePermissionGranted: state.microphonePermissionGranted,
            appointments: state.appointments,
            selectedAppointmentId: state.selectedAppointmentId,
            session: state.session,
            errorMessage: state.errorMessage,
          ),
        );
    final cubit = context.cubit<CallCubit>();

    final apptId = viewState.selectedAppointmentId;
    final session = viewState.session;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DropdownButton<String>(
          isExpanded: true,
          value: apptId,
          hint: Text(l10n.selectAppointmentHintLabel),
          onChanged: viewState.isBusy
              ? null
              : (final v) => v == null ? null : cubit.selectAppointment(v),
          items: viewState.appointments
              .map(
                (a) => DropdownMenuItem<String>(
                  value: a.id,
                  child: Text(
                    a.id,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          value: viewState.cameraPermissionGranted,
          onChanged: viewState.isBusy
              ? null
              : (final v) =>
                    v == null ? null : cubit.toggleCameraPermission(granted: v),
          title: Text(l10n.cameraPermissionGrantedLabel),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          value: viewState.microphonePermissionGranted,
          onChanged: viewState.isBusy
              ? null
              : (final v) => v == null
                    ? null
                    : cubit.toggleMicrophonePermission(granted: v),
          title: Text(l10n.microphonePermissionGrantedLabel),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: <Widget>[
            ElevatedButton(
              onPressed: viewState.isBusy || apptId == null
                  ? null
                  : () => cubit.createSession(),
              child: Text(l10n.createSessionButtonLabel),
            ),
            ElevatedButton(
              onPressed: viewState.isBusy || session == null
                  ? null
                  : () => cubit.join(),
              child: Text(l10n.joinButtonLabel),
            ),
          ],
        ),
        if (viewState.errorMessage case final String errorMessage?)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorMessage,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: 12),
        Text('Session: ${session?.id ?? '-'}'),
        Text('Join status: ${session?.joinStatus.name ?? '-'}'),
        if (session?.joinStatus == CallJoinStatus.failed)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Fallback: join failed — simulated provider.',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
}

// eof
// end
//
