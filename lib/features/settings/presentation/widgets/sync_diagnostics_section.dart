import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/settings_section.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_helpers.dart';

class SyncDiagnosticsSection extends StatefulWidget {
  const SyncDiagnosticsSection({super.key});

  @override
  State<SyncDiagnosticsSection> createState() => _SyncDiagnosticsSectionState();
}

class _SyncDiagnosticsSectionState extends State<SyncDiagnosticsSection> {
  @override
  void initState() {
    super.initState();
    if (CubitHelpers.isCubitAvailable<SyncStatusCubit, SyncStatusState>(
      context,
    )) {
      context.read<SyncStatusCubit>().ensureStarted();
    }
  }

  @override
  Widget build(final BuildContext context) {
    final double gap = context.responsiveGapS;
    final double cardPadding = context.responsiveCardPadding;
    final l10n = context.l10n;

    return SettingsSection(
      title: l10n.settingsSyncDiagnosticsTitle,
      child: Card(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: cardPadding,
            vertical: context.responsiveGapM,
          ),
          child: BlocBuilder<SyncStatusCubit, SyncStatusState>(
            buildWhen: (final previous, final current) =>
                previous.history != current.history,
            builder: (final context, final state) {
              final List<SyncCycleSummary> history = state.history.reversed
                  .toList(growable: false);
              if (history.isEmpty) {
                return Text(
                  l10n.settingsSyncDiagnosticsEmpty,
                  style: Theme.of(context).textTheme.bodyMedium,
                );
              }
              final MaterialLocalizations material = MaterialLocalizations.of(
                context,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.settingsSyncHistoryTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: gap),
                  ...history.map(
                    (final summary) {
                      final DateTime local = summary.recordedAt.toLocal();
                      final String timestamp =
                          '${material.formatShortDate(local)} · ${material.formatTimeOfDay(
                            TimeOfDay.fromDateTime(local),
                          )}';
                      final List<MapEntry<String, int>> pendingEntries =
                          summary.pendingByEntity.entries.toList()..sort(
                            (
                              final a,
                              final b,
                            ) => a.key.compareTo(b.key),
                          );
                      final List<Widget> pendingChips = pendingEntries
                          .map(
                            (final entry) => Chip(
                              label: Text('${entry.key}: ${entry.value}'),
                            ),
                          )
                          .toList(growable: false);
                      return Padding(
                        padding: EdgeInsets.only(bottom: gap),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.settingsSyncLastRunLabel(timestamp),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            SizedBox(height: gap),
                            Text(
                              l10n.settingsSyncOperationsLabel(
                                summary.operationsProcessed,
                                summary.operationsFailed,
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            SizedBox(height: gap),
                            Text(
                              l10n.settingsSyncPendingLabel(
                                summary.pendingAtStart,
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (summary.prunedCount > 0) ...<Widget>[
                              SizedBox(height: gap),
                              Text(
                                l10n.settingsSyncPrunedLabel(
                                  summary.prunedCount,
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                            if (pendingChips.isNotEmpty) ...<Widget>[
                              SizedBox(height: gap),
                              Wrap(
                                spacing: gap,
                                runSpacing: gap,
                                children: pendingChips,
                              ),
                            ],
                            SizedBox(height: gap),
                            Text(
                              l10n.settingsSyncDurationLabel(
                                summary.durationMs,
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
