import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/fake/online_therapy_network_mode.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

class OnlineTherapyDemoControlsPage extends StatelessWidget {
  const OnlineTherapyDemoControlsPage({super.key});

  String _explain({
    required final OnlineTherapyNetworkMode mode,
    required final AppLocalizations l10n,
  }) => switch (mode) {
    OnlineTherapyNetworkMode.normal =>
      l10n.onlineTherapyDemoControlsExplainNormal,
    OnlineTherapyNetworkMode.slow => l10n.onlineTherapyDemoControlsExplainSlow,
    OnlineTherapyNetworkMode.offline =>
      l10n.onlineTherapyDemoControlsExplainOffline,
    OnlineTherapyNetworkMode.messageFailure =>
      l10n.onlineTherapyDemoControlsExplainMessageFailure,
    OnlineTherapyNetworkMode.callFailure =>
      l10n.onlineTherapyDemoControlsExplainCallFailure,
  };

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final session = context.cubit<OnlineTherapyDemoSessionCubit>();
    final controls = context
        .selectState<
          OnlineTherapyDemoSessionCubit,
          OnlineTherapyDemoSessionState,
          ({OnlineTherapyNetworkMode networkMode, bool isBusy})
        >(
          selector: (final state) => (
            networkMode: state.networkMode,
            isBusy: state.isBusy,
          ),
        );
    final List<Widget> items = <Widget>[
      Text(l10n.onlineTherapyDemoControlsIntro),
      const SizedBox(height: 12),
      DropdownButton<OnlineTherapyNetworkMode>(
        isExpanded: true,
        value: controls.networkMode,
        onChanged: controls.isBusy
            ? null
            : (v) => v == null ? null : session.setNetworkMode(v),
        items: OnlineTherapyNetworkMode.values
            .map(
              (m) => DropdownMenuItem<OnlineTherapyNetworkMode>(
                value: m,
                child: Text(
                  l10n.onlineTherapyDemoControlsModeLabel(m.name),
                ),
              ),
            )
            .toList(growable: false),
      ),
      const SizedBox(height: 8),
      Text(
        _explain(mode: controls.networkMode, l10n: l10n),
        style: const TextStyle(color: Colors.black54),
      ),
    ];

    return CommonPageLayout(
      title: l10n.onlineTherapyDemoControlsTitle,
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
