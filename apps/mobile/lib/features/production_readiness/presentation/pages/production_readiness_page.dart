import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/production_readiness/presentation/cubit/production_readiness_cubit.dart';
import 'package:flutter_bloc_app/features/production_readiness/presentation/cubit/production_readiness_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:utilities/utilities.dart';

part 'production_readiness_page.part.dart';

class ProductionReadinessPage extends StatelessWidget {
  const ProductionReadinessPage({
    this.showSimulatedNotificationButton = false,
    super.key,
  });

  /// When true, shows the emit-simulated-notification action (simulated FCM).
  final bool showSimulatedNotificationButton;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.productionReadinessPageTitle,
      body: BlocBuilder<ProductionReadinessCubit, ProductionReadinessState>(
        builder: (final context, final state) {
          if (state.status == ProductionReadinessStatus.loading ||
              state.status == ProductionReadinessStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ProductionReadinessStatus.error) {
            return Center(
              child: Text(
                state.errorMessage ?? l10n.productionReadinessPageTitle,
              ),
            );
          }
          return SingleChildScrollView(
            key: const ValueKey('production-readiness-list'),
            padding: EdgeInsets.all(context.responsiveGapM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (state.errorMessage case final String errorMessage)
                  Padding(
                    padding: EdgeInsets.only(bottom: context.responsiveGapM),
                    child: CommonCard(
                      key: const ValueKey('production-readiness-error-banner'),
                      child: ListTile(
                        leading: Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        title: Text(errorMessage),
                      ),
                    ),
                  ),
                if (!state.releaseFlagEnabled)
                  Padding(
                    padding: EdgeInsets.only(bottom: context.responsiveGapM),
                    child: CommonCard(
                      key: const ValueKey('production-readiness-kill-switch'),
                      child: ListTile(
                        leading: Icon(
                          Icons.warning_amber_rounded,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        title: Text(l10n.productionReadinessKillSwitchBanner),
                      ),
                    ),
                  ),
                _StatusCard(
                  key: const ValueKey('production-readiness-mode-card'),
                  title: l10n.productionReadinessModeLabel,
                  value: state.mode == ProductionReadinessMode.live
                      ? l10n.productionReadinessModeLive
                      : l10n.productionReadinessModeSimulated,
                ),
                SizedBox(height: context.responsiveGapM),
                _StatusCard(
                  key: const ValueKey('production-readiness-crashlytics-card'),
                  title: l10n.productionReadinessCrashlyticsLabel,
                  value: state.crashlyticsAvailable
                      ? l10n.productionReadinessCrashlyticsActive
                      : l10n.productionReadinessCrashlyticsUnavailable,
                ),
                SizedBox(height: context.responsiveGapM),
                _FcmCard(
                  key: const ValueKey('production-readiness-fcm-card'),
                  state: state,
                  showSimulatedButton: showSimulatedNotificationButton,
                ),
                SizedBox(height: context.responsiveGapM),
                _FrameTimingCard(
                  key: const ValueKey('production-readiness-frame-card'),
                  state: state,
                ),
                SizedBox(height: context.responsiveGapM),
                _ConsentCard(
                  key: const ValueKey('production-readiness-consent-card'),
                  enabled: state.analyticsConsentEnabled,
                  onChanged: (final value) => context
                      .read<ProductionReadinessCubit>()
                      .setAnalyticsConsent(enabled: value),
                ),
                SizedBox(height: context.responsiveGapS),
                Text(
                  '${l10n.productionReadinessEventCountLabel}: ${state.localEventCount}',
                  key: const ValueKey('production-readiness-event-count'),
                ),
                SizedBox(height: context.responsiveGapM),
                _ReleaseFlagCard(
                  key: const ValueKey('production-readiness-release-card'),
                  state: state,
                  onRefresh: () => context
                      .read<ProductionReadinessCubit>()
                      .refreshReleaseFlag(),
                ),
                SizedBox(height: context.responsiveGapL),
                Wrap(
                  spacing: context.responsiveGapS,
                  runSpacing: context.responsiveGapS,
                  children: <Widget>[
                    KeyedSubtree(
                      key: const ValueKey('production-readiness-settings-link'),
                      child: PlatformAdaptive.textButton(
                        context: context,
                        onPressed: () => context.push(AppRoutes.settingsPath),
                        child: Text(l10n.productionReadinessSettingsLink),
                      ),
                    ),
                    KeyedSubtree(
                      key: const ValueKey(
                        'production-readiness-native-showcase-link',
                      ),
                      child: PlatformAdaptive.textButton(
                        context: context,
                        onPressed: () => context.pushNamed(
                          AppRoutes.nativePlatformShowcase,
                        ),
                        child: Text(l10n.productionReadinessNativeShowcaseLink),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
