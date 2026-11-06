import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/presentation/cubit/carrier_line_cubit.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/presentation/cubit/carrier_line_state.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/presentation/widgets/carrier_connection_banner.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/presentation/widgets/carrier_inbox_list.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/presentation/widgets/carrier_line_status_cards.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Thin business-line surface: local activity, simulated realtime, status cards.
class CarrierLineDemoPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.carrierLineTitle,
      body: BlocBuilder<CarrierLineCubit, CarrierLineState>(
        builder: (BuildContext context, CarrierLineState state) {
          final CarrierLineCubit cubit = context.read<CarrierLineCubit>();
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  l10n.carrierLineIntro,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                CarrierConnectionBanner(
                  status: state.connection,
                  endpoint: cubit.realtimeClient.endpoint,
                  errorMessage: state.connectionError,
                  onConnect: cubit.connectRealtime,
                  onDisconnect: cubit.disconnectRealtime,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.carrierLineStatusSection,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                CarrierLineStatusCards(snapshot: state.lineStatus),
                const SizedBox(height: 16),
                Text(
                  l10n.carrierLinePushComposedNote,
                  key: const ValueKey<String>(
                    'carrier-line-push-composed-note',
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.carrierLineInboxSection,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                CarrierInboxList(
                  items: state.inbox,
                  onMarkRead: cubit.markRead,
                ),
                if (state.errorMessage case final String message) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    message,
                    key: const ValueKey<String>('carrier-line-error'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
