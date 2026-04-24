import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/online_therapy_network_mode.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

class OnlineTherapyDemoControlsPage extends StatelessWidget {
  const OnlineTherapyDemoControlsPage({super.key});

  String _explain(final OnlineTherapyNetworkMode mode) => switch (mode) {
    OnlineTherapyNetworkMode.normal => 'Baseline success.',
    OnlineTherapyNetworkMode.slow =>
      'Adds delay so loading states are visible.',
    OnlineTherapyNetworkMode.offline => 'Throws Offline errors for failure UX.',
    OnlineTherapyNetworkMode.messageFailure =>
      'First message send fails (failed), retry succeeds (sent).',
    OnlineTherapyNetworkMode.callFailure =>
      'Video join fails and shows fallback state.',
  };

  @override
  Widget build(final BuildContext context) {
    final state = context.watchBloc<OnlineTherapyDemoSessionCubit>().state;
    final session = context.cubit<OnlineTherapyDemoSessionCubit>();
    final List<Widget> items = <Widget>[
      const Text(
        'Failure injection (demo-friendly). Changes affect the fake API behavior.',
      ),
      const SizedBox(height: 12),
      DropdownButton<OnlineTherapyNetworkMode>(
        isExpanded: true,
        value: state.networkMode,
        onChanged: state.isBusy
            ? null
            : (v) => v == null ? null : session.setNetworkMode(v),
        items: OnlineTherapyNetworkMode.values
            .map(
              (m) => DropdownMenuItem<OnlineTherapyNetworkMode>(
                value: m,
                child: Text('Mode: ${m.name}'),
              ),
            )
            .toList(growable: false),
      ),
      const SizedBox(height: 8),
      Text(
        _explain(state.networkMode),
        style: const TextStyle(color: Colors.black54),
      ),
    ];

    return CommonPageLayout(
      title: 'Demo controls',
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
//
