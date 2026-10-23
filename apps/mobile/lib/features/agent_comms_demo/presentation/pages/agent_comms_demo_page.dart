import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/agent_comms_demo/presentation/cubit/agent_comms_cubit.dart';
import 'package:flutter_bloc_app/features/agent_comms_demo/presentation/cubit/agent_comms_state.dart';
import 'package:material_ui/material_ui.dart';

/// Developer-only screen: connect / ping / stream against the agent process.
class AgentCommsDemoPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonPageLayout(
      title: 'Agent communication layer',
      body: BlocBuilder<AgentCommsCubit, AgentCommsState>(
        builder: (context, state) {
          final AgentCommsCubit cubit = context.read<AgentCommsCubit>();
          final bool connected =
              state.status == AgentCommsStatus.connected ||
              state.status == AgentCommsStatus.busy;
          final bool busy =
              state.status == AgentCommsStatus.busy ||
              state.status == AgentCommsStatus.connecting;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(
                'JSON-RPC client → separate agent process. '
                'Untrusted agent work stays out of the Flutter process. '
                'FRB is only for trusted in-process helpers '
                '(see TrustedNativeHelper).',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text('Status: ${state.status.name}'),
              if (state.launcherDescription != null)
                Text('Launcher: ${state.launcherDescription}'),
              if (state.trustedHelperIdentity != null)
                Text('Trusted helper: ${state.trustedHelperIdentity}'),
              if (state.engineInfo case final engineInfo?)
                Text(
                  'Engine: ${engineInfo.engine} '
                  'v${engineInfo.version} pid=${engineInfo.pid}',
                ),
              if (state.failure case final failure?)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Error: ${failure.message}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  FilledButton(
                    onPressed: busy || connected ? null : cubit.connect,
                    child: const Text('Connect'),
                  ),
                  FilledButton.tonal(
                    onPressed: busy || !connected ? null : cubit.ping,
                    child: const Text('Ping'),
                  ),
                  FilledButton.tonal(
                    onPressed: busy || !connected ? null : cubit.streamDemo,
                    child: const Text('Stream demo'),
                  ),
                  OutlinedButton(
                    onPressed: busy || !connected ? null : cubit.disconnect,
                    child: const Text('Disconnect'),
                  ),
                  TextButton(
                    onPressed: cubit.clearLog,
                    child: const Text('Clear log'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Event log', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...state.eventLog.reversed.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    line,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
