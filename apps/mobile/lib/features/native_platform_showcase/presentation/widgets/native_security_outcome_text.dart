import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_operation_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_status.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

/// Renders a native security operation outcome as `status • reason`.
///
/// Never renders raw byte payloads, keys, tokens, or certificates — only the
/// [NativeSecurityStatus] enum, a locked l10n-mapped reason code, and optional
/// allowlisted metadata (algorithm / residency / hw / verified / counts).
class NativeSecurityOutcomeText extends StatelessWidget {
  const NativeSecurityOutcomeText({required this.result, super.key});

  final NativeSecurityOperationResult? result;

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final NativeSecurityOperationResult? outcome = result;

    if (outcome == null) {
      return Text(
        l10n.nativeSecurityOutcomeIdle,
        style: theme.textTheme.bodyMedium,
      );
    }

    final String? detail = nativeSecurityOutcomeDetail(outcome);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          '${nativeSecurityStatusLabel(outcome.status, l10n)} • '
          '${nativeSecurityReasonLabel(outcome.reasonCode, l10n)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: nativeSecurityStatusColor(outcome.status, theme),
          ),
        ),
        if (detail != null) ...<Widget>[
          const SizedBox(height: 2),
          Text(detail, style: theme.textTheme.bodySmall),
        ],
      ],
    );
  }
}

/// Maps [NativeSecurityStatus] to its l10n label.
String nativeSecurityStatusLabel(
  final NativeSecurityStatus status,
  final AppLocalizations l10n,
) => switch (status) {
  NativeSecurityStatus.success => l10n.nativeSecurityStatusSuccess,
  NativeSecurityStatus.unavailable => l10n.nativeSecurityStatusUnavailable,
  NativeSecurityStatus.denied => l10n.nativeSecurityStatusDenied,
  NativeSecurityStatus.failed => l10n.nativeSecurityStatusFailed,
};

/// Maps [NativeSecurityStatus] to a themed emphasis color.
Color nativeSecurityStatusColor(
  final NativeSecurityStatus status,
  final ThemeData theme,
) => switch (status) {
  NativeSecurityStatus.success => theme.colorScheme.primary,
  NativeSecurityStatus.unavailable => theme.colorScheme.onSurfaceVariant,
  NativeSecurityStatus.denied => theme.colorScheme.error,
  NativeSecurityStatus.failed => theme.colorScheme.error,
};

/// Shared reason-code → l10n mapping for native security + App Check cards.
///
/// Unknown codes never render raw channel text (zero-secrets UI contract);
/// they fall back to the locked `platform_error` label.
String nativeSecurityReasonLabel(
  final String reasonCode,
  final AppLocalizations l10n,
) => switch (reasonCode) {
  'ok' => l10n.nativeSecurityReasonOk,
  'mobile_only' => l10n.nativeSecurityReasonMobileOnly,
  'missing_plugin' => l10n.nativeSecurityReasonMissingPlugin,
  'timeout' => l10n.nativeSecurityReasonTimeout,
  'malformed_reply' => l10n.nativeSecurityReasonMalformedReply,
  'platform_error' => l10n.nativeSecurityReasonPlatformError,
  'secure_enclave_unavailable' =>
    l10n.nativeSecurityReasonSecureEnclaveUnavailable,
  'keystore_unavailable' => l10n.nativeSecurityReasonKeystoreUnavailable,
  'biometric_not_enrolled' => l10n.nativeSecurityReasonBiometricNotEnrolled,
  'biometric_lockout' => l10n.nativeSecurityReasonBiometricLockout,
  'biometric_canceled' => l10n.nativeSecurityReasonBiometricCanceled,
  'biometric_unsupported' => l10n.nativeSecurityReasonBiometricUnsupported,
  'concurrent_prompt' => l10n.nativeSecurityReasonConcurrentPrompt,
  'not_configured_or_token_null' =>
    l10n.nativeSecurityReasonNotConfiguredOrTokenNull,
  'app_check_error' => l10n.nativeSecurityReasonAppCheckError,
  _ => l10n.nativeSecurityReasonPlatformError,
};

/// Compact allowlisted metadata line (never channel-raw strings).
String? nativeSecurityOutcomeDetail(
  final NativeSecurityOperationResult result,
) {
  final List<String> parts = <String>[];
  final String? algorithm = result.algorithm;
  if (algorithm != null) {
    parts.add(algorithm);
  }
  final NativeSecurityKeyResidency? residency = result.keyResidency;
  if (residency != null) {
    parts.add(_residencyWireLabel(residency));
  }
  final bool? hardwareBacked = result.hardwareBacked;
  if (hardwareBacked != null) {
    parts.add(hardwareBacked ? 'hw' : 'sw');
  }
  final bool? verified = result.verified;
  if (verified != null) {
    parts.add(verified ? 'verified' : 'unverified');
  }
  if (result.wrote != null ||
      result.readMatched != null ||
      result.deleted != null) {
    parts.add(
      'w=${result.wrote == true} r=${result.readMatched == true} '
      'd=${result.deleted == true}',
    );
  }
  final int? challenge = result.challengeByteCount;
  if (challenge != null) {
    parts.add('${challenge}B challenge');
  }
  final int? ciphertext = result.ciphertextByteCount;
  if (ciphertext != null) {
    parts.add('${ciphertext}B ct');
  }
  if (parts.isEmpty) {
    return null;
  }
  return parts.join(' · ');
}

String _residencyWireLabel(final NativeSecurityKeyResidency residency) =>
    switch (residency) {
      NativeSecurityKeyResidency.secureEnclave => 'secure_enclave',
      NativeSecurityKeyResidency.androidKeystore => 'android_keystore',
      NativeSecurityKeyResidency.keychain => 'keychain',
      NativeSecurityKeyResidency.software => 'software',
      NativeSecurityKeyResidency.unknown => 'unknown',
    };
