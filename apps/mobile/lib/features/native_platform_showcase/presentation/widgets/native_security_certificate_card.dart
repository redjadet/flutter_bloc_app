import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/widgets/type_safe_bloc_selector.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/certificate_pin_policy_summary.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_security_showcase_cubit.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_security_showcase_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// Certificate pin policy summary + optional mutable demo navigation.
class NativeSecurityCertificateCard extends StatelessWidget {
  const NativeSecurityCertificateCard({super.key});

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return TypeSafeBlocSelector<
      NativeSecurityShowcaseCubit,
      NativeSecurityShowcaseState,
      CertificatePinPolicySummary
    >(
      selector: (final state) => state.certificateSummary,
      builder: (final context, final summary) => KeyedSubtree(
        key: const ValueKey<String>('native-security-card-certificate'),
        child: CommonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                l10n.nativeSecurityCardCertificateTitle,
                style: theme.textTheme.titleMedium,
              ),
              SizedBox(height: context.responsiveGapXS),
              Text(
                l10n.nativeSecurityCardCertificateDescription,
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: context.responsiveGapS),
              _SummaryRow(
                label: l10n.nativeSecurityCertificateModeLabel,
                value: summary.modeName,
              ),
              _SummaryRow(
                label: l10n.nativeSecurityCertificatePinHashLabel,
                value: summary.pinHashKindName,
              ),
              _SummaryRow(
                label: l10n.nativeSecurityCertificateHostCountLabel,
                value: '${summary.configuredHostCount}',
              ),
              _SummaryRow(
                label: l10n.nativeSecurityCertificatePrimaryPinCountLabel,
                value: '${summary.primaryPinCount}',
              ),
              SizedBox(height: context.responsiveGapS),
              if (summary.canOpenMutableDemo)
                FilledButton.tonal(
                  key: const ValueKey<String>(
                    'native-security-open-certificate-demo',
                  ),
                  onPressed: () =>
                      context.push(AppRoutes.certificatePinningDemoPath),
                  child: Text(l10n.nativeSecurityOpenCertificateDemoLabel),
                )
              else
                Text(
                  l10n.nativeSecurityCertificateMutableDemoUnavailable,
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: context.responsiveGapXS),
    child: Row(
      children: <Widget>[
        Expanded(child: Text(label)),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}
