import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/app/widgets/type_safe_bloc_selector.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_call_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_status.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_platform_showcase_cubit.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_platform_showcase_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

class _ActionUiSnapshot {
  const _ActionUiSnapshot({
    required this.busy,
    required this.lastAction,
    required this.lastActionResult,
  });

  final bool busy;
  final NativePlatformShowcaseAction? lastAction;
  final NativeInteropCallResult? lastActionResult;
}

class NativePlatformShowcaseActionSection extends StatelessWidget {
  const NativePlatformShowcaseActionSection({super.key});

  @override
  Widget build(final BuildContext context) {
    return TypeSafeBlocSelector<
      NativePlatformShowcaseCubit,
      NativePlatformShowcaseState,
      _ActionUiSnapshot?
    >(
      selector: (final state) => state.mapOrNull(
        loaded: (final loaded) => _ActionUiSnapshot(
          busy: loaded.actionInFlight != null,
          lastAction: loaded.lastAction,
          lastActionResult: loaded.lastActionResult,
        ),
      ),
      builder: (final context, final snapshot) {
        final AppLocalizations l10n = AppLocalizations.of(context);
        final ThemeData theme = Theme.of(context);
        final bool enabled = snapshot != null && !snapshot.busy;
        final NativeInteropCallResult? lastResult = snapshot?.lastActionResult;
        final NativePlatformShowcaseAction? lastAction = snapshot?.lastAction;

        return CommonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                l10n.nativePlatformShowcaseActionsTitle,
                style: theme.textTheme.titleMedium,
              ),
              SizedBox(height: context.responsiveGapS),
              Text(
                l10n.nativePlatformShowcaseActionsSubtitle,
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: context.responsiveGapM),
              Wrap(
                spacing: context.responsiveGapS,
                runSpacing: context.responsiveGapS,
                children: <Widget>[
                  FilledButton(
                    key: const ValueKey<String>(
                      'native-platform-showcase-haptic-button',
                    ),
                    onPressed: enabled
                        ? () => context
                              .cubit<NativePlatformShowcaseCubit>()
                              .triggerHaptic()
                        : null,
                    child: Text(l10n.nativePlatformShowcaseHapticButton),
                  ),
                  FilledButton.tonal(
                    key: const ValueKey<String>(
                      'native-platform-showcase-share-button',
                    ),
                    onPressed: enabled
                        ? () => context
                              .cubit<NativePlatformShowcaseCubit>()
                              .shareDemoText(
                                l10n.nativePlatformShowcaseShareDemoText,
                              )
                        : null,
                    child: Text(l10n.nativePlatformShowcaseShareButton),
                  ),
                ],
              ),
              if (lastResult != null) ...<Widget>[
                SizedBox(height: context.responsiveGapM),
                KeyedSubtree(
                  key: const ValueKey<String>(
                    'native-platform-showcase-last-action',
                  ),
                  child: Text(
                    _lastActionLabel(
                      l10n: l10n,
                      action: lastAction,
                      result: lastResult,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _statusColor(theme, lastResult.status),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static String _lastActionLabel({
    required final AppLocalizations l10n,
    required final NativePlatformShowcaseAction? action,
    required final NativeInteropCallResult result,
  }) {
    final String actionLabel = switch (action) {
      NativePlatformShowcaseAction.haptic =>
        l10n.nativePlatformShowcaseHapticButton,
      NativePlatformShowcaseAction.share =>
        l10n.nativePlatformShowcaseShareButton,
      null => l10n.nativePlatformShowcaseLastActionLabel,
    };
    final String statusLabel = switch (result.status) {
      NativeInteropStatus.success => l10n.nativePlatformShowcaseActionSuccess,
      NativeInteropStatus.unavailable =>
        l10n.nativePlatformShowcaseActionUnavailable,
      NativeInteropStatus.failed => l10n.nativePlatformShowcaseActionFailed,
    };
    return '$actionLabel · $statusLabel · ${result.message}';
  }

  static Color _statusColor(
    final ThemeData theme,
    final NativeInteropStatus status,
  ) => switch (status) {
    NativeInteropStatus.success => theme.colorScheme.primary,
    NativeInteropStatus.unavailable => theme.colorScheme.outline,
    NativeInteropStatus.failed => theme.colorScheme.error,
  };
}
