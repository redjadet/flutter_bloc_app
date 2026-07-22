import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/app_check_attestation_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_security_showcase_cubit.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_security_showcase_state.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/widgets/native_security_outcome_text.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';

typedef _AppCheckSlice = ({AppCheckAttestationResult? result, bool busy});

/// App Check cached-token evidence card (never shows token material).
///
/// Missing Firebase Console registration is an expected demo state: the card
/// shows a calm "Setup needed" outcome with Console guidance, not an error.
class NativeSecurityAppCheckCard extends StatelessWidget {
  const NativeSecurityAppCheckCard({super.key});

  static const Set<String> _allowedProviderLabels = <String>{
    'debug',
    'play_integrity',
    'app_attest',
    'app_attest_with_devicecheck_fallback',
    'none',
    'unknown',
  };

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return TypeSafeBlocSelector<
      NativeSecurityShowcaseCubit,
      NativeSecurityShowcaseState,
      _AppCheckSlice
    >(
      selector: (final state) =>
          (result: state.appCheckResult, busy: state.isBusy),
      builder: (final context, final slice) => KeyedSubtree(
        key: const ValueKey<String>('native-security-card-app-check'),
        child: CommonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                l10n.nativeSecurityCardAppCheckTitle,
                style: theme.textTheme.titleMedium,
              ),
              SizedBox(height: context.responsiveGapXS),
              Text(
                l10n.nativeSecurityCardAppCheckDescription,
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: context.responsiveGapXS),
              Text(
                l10n.nativeSecurityAppCheckDisclaimer,
                style: theme.textTheme.bodySmall,
              ),
              SizedBox(height: context.responsiveGapS),
              FilledButton.tonal(
                key: const ValueKey<String>('native-security-run-app-check'),
                onPressed: slice.busy
                    ? null
                    : () => context
                          .cubit<NativeSecurityShowcaseCubit>()
                          .runAppCheck(),
                child: Text(l10n.nativeSecurityRunAppCheckLabel),
              ),
              SizedBox(height: context.responsiveGapS),
              _AppCheckOutcomePanel(result: slice.result),
            ],
          ),
        ),
      ),
    );
  }

  static String sanitizedProviderLabel(final String raw) =>
      _allowedProviderLabels.contains(raw) ? raw : 'unknown';
}

class _AppCheckOutcomePanel extends StatelessWidget {
  const _AppCheckOutcomePanel({required this.result});

  final AppCheckAttestationResult? result;

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final AppCheckAttestationResult? outcome = result;

    if (outcome == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            l10n.nativeSecurityOutcomeIdle,
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: context.responsiveGapXS),
          Text(
            l10n.nativeSecurityAppCheckIdleHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    final bool setupNeeded =
        outcome.status == AppCheckAttestationStatus.unavailable ||
        outcome.reasonCode == 'not_configured_or_token_null';
    final bool failed = outcome.status == AppCheckAttestationStatus.failed;
    final bool issued = outcome.status == AppCheckAttestationStatus.issued;

    final Color accent = setupNeeded
        ? theme.colorScheme.tertiary
        : failed
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    final Color surface = setupNeeded
        ? theme.colorScheme.tertiaryContainer.withValues(alpha: 0.45)
        : failed
        ? theme.colorScheme.errorContainer.withValues(alpha: 0.45)
        : theme.colorScheme.primaryContainer.withValues(alpha: 0.45);

    final String statusLabel = setupNeeded
        ? l10n.nativeSecurityAppCheckStatusSetupNeeded
        : issued
        ? l10n.nativeSecurityStatusSuccess
        : l10n.nativeSecurityStatusFailed;

    final String guidance = setupNeeded
        ? l10n.nativeSecurityAppCheckSetupGuidance
        : failed
        ? l10n.nativeSecurityAppCheckErrorGuidance
        : l10n.nativeSecurityAppCheckIssuedDetail(
            NativeSecurityAppCheckCard.sanitizedProviderLabel(
              outcome.providerLabel,
            ),
          );

    return KeyedSubtree(
      key: ValueKey<String>(
        setupNeeded
            ? 'native-security-app-check-setup-needed'
            : failed
            ? 'native-security-app-check-failed'
            : 'native-security-app-check-issued',
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Padding(
          padding: EdgeInsets.all(context.responsiveGapS),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                '$statusLabel • ${nativeSecurityReasonLabel(outcome.reasonCode, l10n)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: context.responsiveGapXS),
              Text(
                guidance,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
