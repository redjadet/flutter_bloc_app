import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/widgets/native_security_action_cards.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/widgets/native_security_certificate_card.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/widgets/native_security_crypto_card.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

/// Five-card native security showcase, nested under
/// `/native-platform-showcase` (no route of its own).
///
/// Compact: single column. Tablet+: two-column wrap for the first four cards;
/// biometric stays full-width.
class NativeSecurityShowcaseSection extends StatelessWidget {
  const NativeSecurityShowcaseSection({super.key});

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final bool wide = context.isTabletOrLarger;
    final double gap = context.responsiveGapM;

    return KeyedSubtree(
      key: const ValueKey<String>('native-security-showcase-section'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            l10n.nativeSecurityShowcaseSectionTitle,
            style: theme.textTheme.titleLarge,
          ),
          SizedBox(height: context.responsiveGapS),
          Text(
            l10n.nativeSecurityShowcaseSectionSubtitle,
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: gap),
          if (wide) ...<Widget>[
            _WideCardRow(
              gap: gap,
              left: const NativeSecurityCryptoCard(),
              right: const NativeSecurityCertificateCard(),
            ),
            SizedBox(height: gap),
            _WideCardRow(
              gap: gap,
              left: const NativeSecurityStorageCard(),
              right: const NativeSecurityAppCheckCard(),
            ),
            SizedBox(height: gap),
            const NativeSecurityBiometricCard(),
          ] else ...<Widget>[
            const NativeSecurityCryptoCard(),
            SizedBox(height: gap),
            const NativeSecurityCertificateCard(),
            SizedBox(height: gap),
            const NativeSecurityStorageCard(),
            SizedBox(height: gap),
            const NativeSecurityAppCheckCard(),
            SizedBox(height: gap),
            const NativeSecurityBiometricCard(),
          ],
        ],
      ),
    );
  }
}

class _WideCardRow extends StatelessWidget {
  const _WideCardRow({
    required this.gap,
    required this.left,
    required this.right,
  });

  final double gap;
  final Widget left;
  final Widget right;

  @override
  Widget build(final BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Expanded(child: left),
      SizedBox(width: gap),
      Expanded(child: right),
    ],
  );
}
