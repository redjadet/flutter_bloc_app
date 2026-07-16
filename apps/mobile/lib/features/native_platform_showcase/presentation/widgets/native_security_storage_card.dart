import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/app/widgets/type_safe_bloc_selector.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_operation_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_security_showcase_cubit.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_security_showcase_state.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/widgets/native_security_outcome_text.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

typedef _StorageSlice = ({NativeSecurityOperationResult? result, bool busy});

/// Secure-storage write/read/delete demo card.
class NativeSecurityStorageCard extends StatelessWidget {
  const NativeSecurityStorageCard({super.key});

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return TypeSafeBlocSelector<
      NativeSecurityShowcaseCubit,
      NativeSecurityShowcaseState,
      _StorageSlice
    >(
      selector: (final state) =>
          (result: state.storageResult, busy: state.isBusy),
      builder: (final context, final slice) => KeyedSubtree(
        key: const ValueKey<String>('native-security-card-storage'),
        child: CommonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                l10n.nativeSecurityCardStorageTitle,
                style: theme.textTheme.titleMedium,
              ),
              SizedBox(height: context.responsiveGapXS),
              Text(
                l10n.nativeSecurityCardStorageDescription,
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: context.responsiveGapS),
              FilledButton.tonal(
                key: const ValueKey<String>('native-security-run-storage'),
                onPressed: slice.busy
                    ? null
                    : () => context
                          .cubit<NativeSecurityShowcaseCubit>()
                          .runSecureStorage(),
                child: Text(l10n.nativeSecurityRunStorageLabel),
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
