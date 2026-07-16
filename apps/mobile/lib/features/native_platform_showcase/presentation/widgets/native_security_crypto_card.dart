import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/app/widgets/type_safe_bloc_selector.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_operation_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_security_showcase_cubit.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_security_showcase_state.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/widgets/native_security_outcome_text.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

typedef _CryptoSlice = ({
  NativeSecurityOperationResult? p256,
  NativeSecurityOperationResult? aes,
  bool busy,
});

/// Crypto card: separate P-256 and AES-GCM run buttons.
class NativeSecurityCryptoCard extends StatelessWidget {
  const NativeSecurityCryptoCard({super.key});

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return TypeSafeBlocSelector<
      NativeSecurityShowcaseCubit,
      NativeSecurityShowcaseState,
      _CryptoSlice
    >(
      selector: (final state) => (
        p256: state.p256Result,
        aes: state.aesResult,
        busy: state.isBusy,
      ),
      builder: (final context, final slice) {
        final bool busy = slice.busy;
        return KeyedSubtree(
          key: const ValueKey<String>('native-security-card-crypto'),
          child: CommonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  l10n.nativeSecurityCardCryptoTitle,
                  style: theme.textTheme.titleMedium,
                ),
                SizedBox(height: context.responsiveGapXS),
                Text(
                  l10n.nativeSecurityCardCryptoDescription,
                  style: theme.textTheme.bodyMedium,
                ),
                SizedBox(height: context.responsiveGapS),
                Wrap(
                  spacing: context.responsiveGapS,
                  runSpacing: context.responsiveGapXS,
                  children: <Widget>[
                    PlatformAdaptive.filledButton(
                      context: context,
                      key: const ValueKey<String>('native-security-run-crypto'),
                      onPressed: busy
                          ? null
                          : () => context
                                .cubit<NativeSecurityShowcaseCubit>()
                                .runP256(),
                      child: Text(l10n.nativeSecurityRunP256Label),
                    ),
                    KeyedSubtree(
                      key: const ValueKey<String>('native-security-run-aes'),
                      child: PlatformAdaptive.outlinedButton(
                        context: context,
                        onPressed: busy
                            ? null
                            : () => context
                                  .cubit<NativeSecurityShowcaseCubit>()
                                  .runAesGcm(),
                        child: Text(l10n.nativeSecurityRunAesLabel),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.responsiveGapS),
                NativeSecurityOutcomeText(result: slice.p256),
                SizedBox(height: context.responsiveGapXS),
                NativeSecurityOutcomeText(result: slice.aes),
              ],
            ),
          ),
        );
      },
    );
  }
}
