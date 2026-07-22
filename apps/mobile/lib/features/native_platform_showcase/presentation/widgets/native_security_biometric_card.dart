import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_operation_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_security_showcase_cubit.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_security_showcase_state.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/widgets/native_security_outcome_text.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';

typedef _BiometricSlice = ({NativeSecurityOperationResult? result, bool busy});

/// Biometric-gated protected crypto operation card.
class NativeSecurityBiometricCard extends StatelessWidget {
  const NativeSecurityBiometricCard({super.key});

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return TypeSafeBlocSelector<
      NativeSecurityShowcaseCubit,
      NativeSecurityShowcaseState,
      _BiometricSlice
    >(
      selector: (final state) =>
          (result: state.biometricResult, busy: state.isBusy),
      builder: (final context, final slice) => KeyedSubtree(
        key: const ValueKey<String>('native-security-card-biometric'),
        child: CommonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                l10n.nativeSecurityCardBiometricTitle,
                style: theme.textTheme.titleMedium,
              ),
              SizedBox(height: context.responsiveGapXS),
              Text(
                l10n.nativeSecurityCardBiometricDescription,
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: context.responsiveGapS),
              FilledButton.tonal(
                key: const ValueKey<String>('native-security-run-biometric'),
                onPressed: slice.busy
                    ? null
                    : () => context
                          .cubit<NativeSecurityShowcaseCubit>()
                          .runBiometric(),
                child: Text(l10n.nativeSecurityRunBiometricLabel),
              ),
              SizedBox(height: context.responsiveGapS),
              NativeSecurityOutcomeText(result: slice.result),
            ],
          ),
        ),
      ),
    );
  }
}
