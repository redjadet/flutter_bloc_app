import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/call_cubit.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';

class OnlineTherapyCallView extends StatelessWidget {
  const OnlineTherapyCallView({super.key});

  @override
  Widget build(final BuildContext context) {
    final state = context.watchBloc<CallCubit>().state;
    final cubit = context.cubit<CallCubit>();

    final apptId = state.selectedAppointmentId;
    final session = state.session;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DropdownButton<String>(
          isExpanded: true,
          value: apptId,
          hint: const Text('Select appointment'),
          onChanged: state.isBusy
              ? null
              : (final v) => v == null ? null : cubit.selectAppointment(v),
          items: state.appointments
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
          value: state.cameraPermissionGranted,
          onChanged: state.isBusy
              ? null
              : (final v) =>
                    v == null ? null : cubit.toggleCameraPermission(granted: v),
          title: const Text('Camera permission granted'),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          value: state.microphonePermissionGranted,
          onChanged: state.isBusy
              ? null
              : (final v) => v == null
                    ? null
                    : cubit.toggleMicrophonePermission(granted: v),
          title: const Text('Microphone permission granted'),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: <Widget>[
            ElevatedButton(
              onPressed: state.isBusy || apptId == null
                  ? null
                  : () => cubit.createSession(),
              child: const Text('Create session'),
            ),
            ElevatedButton(
              onPressed: state.isBusy || session == null
                  ? null
                  : () => cubit.join(),
              child: const Text('Join'),
            ),
          ],
        ),
        if (state.errorMessage case final String errorMessage?)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        const SizedBox(height: 12),
        Text('Session: ${session?.id ?? '-'}'),
        Text('Join status: ${session?.joinStatus.name ?? '-'}'),
        if (session?.joinStatus == CallJoinStatus.failed)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Fallback: join failed — simulated provider.',
              style: TextStyle(color: Colors.orange),
            ),
          ),
      ],
    );
  }
}

// eof
// end
//
