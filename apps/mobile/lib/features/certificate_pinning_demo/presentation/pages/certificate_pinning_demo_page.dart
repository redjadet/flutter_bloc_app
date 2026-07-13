import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/certificate_pinning_demo_failure.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/presentation/cubit/certificate_pinning_demo_cubit.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/presentation/cubit/certificate_pinning_demo_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:networking/networking.dart';

class CertificatePinningDemoPage extends StatelessWidget {
  const CertificatePinningDemoPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.certificatePinningDemoTitle)),
      body: SafeArea(
        child:
            BlocBuilder<
              CertificatePinningDemoCubit,
              CertificatePinningDemoState
            >(
              builder: (final context, final state) {
                final CertificatePinningDemoCubit cubit = context
                    .read<CertificatePinningDemoCubit>();
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    Text(
                      l10n.certificatePinningDemoModeLabel(state.mode.name),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.certificatePinningDemoDisabledHint,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.certificatePinningDemoScenarioLabel,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<MockCertificateScenario>(
                      key: const ValueKey('certificate-pinning-scenario'),
                      // ignore: deprecated_member_use - DropdownButtonFormField still uses value
                      value: state.scenario,
                      items: MockCertificateScenario.values
                          .map(
                            (final s) =>
                                DropdownMenuItem<MockCertificateScenario>(
                                  value: s,
                                  child: Text(s.name),
                                ),
                          )
                          .toList(growable: false),
                      onChanged:
                          state.status ==
                              CertificatePinningDemoStatus.validating
                          ? null
                          : (final value) {
                              if (value != null) {
                                cubit.selectScenario(value);
                              }
                            },
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        FilledButton(
                          key: const ValueKey('certificate-pinning-probe'),
                          onPressed:
                              state.status ==
                                  CertificatePinningDemoStatus.validating
                              ? null
                              : cubit.triggerProbe,
                          child: Text(l10n.certificatePinningDemoProbeButton),
                        ),
                        OutlinedButton(
                          key: const ValueKey('certificate-pinning-reset'),
                          onPressed: cubit.resetScenario,
                          child: Text(l10n.certificatePinningDemoResetButton),
                        ),
                        OutlinedButton(
                          key: const ValueKey('certificate-pinning-clear-logs'),
                          onPressed: cubit.clearLogs,
                          child: Text(
                            l10n.certificatePinningDemoClearLogsButton,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _StatusBanner(state: state, l10n: l10n),
                    const SizedBox(height: 16),
                    Text(
                      l10n.certificatePinningDemoLogsTitle,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    if (state.logLines.isEmpty)
                      Text(l10n.certificatePinningDemoLogsEmpty)
                    else
                      ...state.logLines.map(
                        (final line) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: SelectableText(
                            line,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.state, required this.l10n});

  final CertificatePinningDemoState state;
  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    switch (state.status) {
      case CertificatePinningDemoStatus.initial:
        return Text(l10n.certificatePinningDemoStatusInitial);
      case CertificatePinningDemoStatus.validating:
        return Row(
          children: <Widget>[
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(l10n.certificatePinningDemoStatusValidating),
          ],
        );
      case CertificatePinningDemoStatus.success:
        return Text(
          l10n.certificatePinningDemoStatusSuccess(
            state.matchKind?.name ?? 'primary',
          ),
          style: TextStyle(color: colors.primary),
        );
      case CertificatePinningDemoStatus.failure:
        return Text(
          _failureMessage(state.failure, l10n),
          style: TextStyle(color: colors.error),
        );
    }
  }

  String _failureMessage(
    final CertificatePinningDemoFailure? failure,
    final AppLocalizations l10n,
  ) {
    final String code = failure?.l10nCode ?? 'unknown';
    return switch (code) {
      'pinMismatch' => l10n.certificatePinningDemoFailurePinMismatch,
      'missingPin' => l10n.certificatePinningDemoFailureMissingPin,
      'unsupportedHost' => l10n.certificatePinningDemoFailureUnsupportedHost,
      'expired' => l10n.certificatePinningDemoFailureExpired,
      'timeout' => l10n.certificatePinningDemoFailureTimeout,
      'malformed' => l10n.certificatePinningDemoFailureMalformed,
      'networkUnavailable' =>
        l10n.certificatePinningDemoFailureNetworkUnavailable,
      'validation' => l10n.certificatePinningDemoFailureValidation,
      _ => l10n.certificatePinningDemoFailureUnknown,
    };
  }
}
