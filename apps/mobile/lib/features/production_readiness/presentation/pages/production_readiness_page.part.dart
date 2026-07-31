part of 'production_readiness_page.dart';

class _FcmCard extends StatelessWidget {
  const _FcmCard({
    required this.state,
    required this.showSimulatedButton,
    super.key,
  });

  final ProductionReadinessState state;
  final bool showSimulatedButton;

  static String _permissionLabel(
    final FcmPermissionState? permission,
    final AppLocalizations l10n,
  ) {
    return switch (permission) {
      FcmPermissionState.authorized => l10n.fcmDemoPermissionAuthorized,
      FcmPermissionState.denied => l10n.fcmDemoPermissionDenied,
      FcmPermissionState.provisional => l10n.fcmDemoPermissionProvisional,
      FcmPermissionState.notDetermined ||
      null => l10n.fcmDemoPermissionNotDetermined,
    };
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final String modeLabel = state.fcmMode == FcmDemoMode.live
        ? l10n.productionReadinessFcmModeLive
        : l10n.productionReadinessFcmModeSimulated;
    final String? lastSource = state.fcmLastSource;
    final String summary = lastSource == null
        ? l10n.productionReadinessFcmNoMessage
        : '${l10n.productionReadinessFcmLastSource}: $lastSource · '
              '${l10n.productionReadinessFcmHasTitle}: ${state.fcmHasTitle} · '
              '${l10n.productionReadinessFcmHasBody}: ${state.fcmHasBody} · '
              '${l10n.productionReadinessFcmDataKeys}: ${state.fcmDataKeyCount}';

    return CommonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.productionReadinessFcmLabel),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('${l10n.productionReadinessFcmModeLabel}: $modeLabel'),
                Text(
                  '${l10n.productionReadinessFcmPermissionLabel}: '
                  '${_permissionLabel(state.fcmPermission, l10n)}',
                ),
                const SizedBox(height: 4),
                Text(summary),
              ],
            ),
          ),
          if (showSimulatedButton &&
              state.fcmMode == FcmDemoMode.simulated) ...<Widget>[
            SizedBox(height: context.responsiveGapS),
            PlatformAdaptive.filledButton(
              key: const ValueKey('production-readiness-emit-simulated'),
              context: context,
              onPressed: () => context
                  .read<ProductionReadinessCubit>()
                  .emitSimulatedNotification(),
              child: Text(l10n.productionReadinessEmitSimulatedButton),
            ),
          ],
        ],
      ),
    );
  }
}

class _FrameTimingCard extends StatelessWidget {
  const _FrameTimingCard({required this.state, super.key});

  final ProductionReadinessState state;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return _StatusCard(
      title: l10n.productionReadinessFrameTimingLabel,
      value:
          '${l10n.productionReadinessFrameSampleCount}: ${state.frameSampleCount}\n'
          '${l10n.productionReadinessFrameP90}: ${state.frameP90Ms.toStringAsFixed(1)} ms\n'
          '${l10n.productionReadinessFrameP99}: ${state.frameP99Ms.toStringAsFixed(1)} ms\n'
          '${l10n.productionReadinessFrameMissed}: ${state.framesMissedOver16_7Ms}',
    );
  }
}

class _ConsentCard extends StatelessWidget {
  const _ConsentCard({
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(l10n.productionReadinessConsentLabel)),
              Switch.adaptive(
                key: const ValueKey('production-readiness-consent-switch'),
                value: enabled,
                onChanged: onChanged,
              ),
            ],
          ),
          Text(
            enabled
                ? l10n.productionReadinessConsentOn
                : l10n.productionReadinessConsentOff,
          ),
        ],
      ),
    );
  }
}

class _ReleaseFlagCard extends StatelessWidget {
  const _ReleaseFlagCard({
    required this.state,
    required this.onRefresh,
    super.key,
  });

  final ProductionReadinessState state;
  final VoidCallback onRefresh;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(l10n.productionReadinessReleaseFlagLabel)),
              IconButton(
                key: const ValueKey('production-readiness-release-retry'),
                tooltip: l10n.productionReadinessReleaseFlagLabel,
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          Text(
            state.releaseFlagEnabled
                ? l10n.productionReadinessReleaseFlagEnabled
                : l10n.productionReadinessReleaseFlagDisabled,
          ),
          const SizedBox(height: 4),
          Text(
            '${l10n.productionReadinessVariantLabel}: ${state.releaseVariant}\n'
            '${l10n.productionReadinessSourceLabel}: ${state.configSource}',
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.value,
    super.key,
  });

  final String title;
  final String value;

  @override
  Widget build(final BuildContext context) => CommonCard(
    child: ListTile(
      title: Text(title),
      subtitle: Text(value),
    ),
  );
}
