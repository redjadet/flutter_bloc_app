import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_platform_showcase_cubit.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_platform_showcase_state.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/widgets/native_platform_showcase_capability_list.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/widgets/native_platform_showcase_interop_section.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/widgets/native_platform_showcase_lesson_cards.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/widgets/native_platform_showcase_platform_summary_card.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/widgets/native_platform_showcase_telemetry_section.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';

class NativePlatformShowcasePage extends StatelessWidget {
  const NativePlatformShowcasePage({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.nativePlatformShowcaseTitle,
      body:
          TypeSafeBlocBuilder<
            NativePlatformShowcaseCubit,
            NativePlatformShowcaseState
          >(
            builder: (context, state) => state.when(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (final data, final telemetry) => ListView(
                padding: context.pagePadding,
                children: <Widget>[
                  Text(
                    l10n.nativePlatformShowcaseIntro,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: context.responsiveGapM),
                  NativePlatformShowcasePlatformSummaryCard(
                    platform: data.platform,
                  ),
                  SizedBox(height: context.responsiveGapM),
                  const NativePlatformShowcaseTelemetrySection(),
                  SizedBox(height: context.responsiveGapM),
                  NativePlatformShowcaseInteropSection(
                    results: data.interopResults,
                  ),
                  SizedBox(height: context.responsiveGapM),
                  const NativePlatformShowcaseLessonCards(),
                  SizedBox(height: context.responsiveGapM),
                  NativePlatformShowcaseCapabilityList(
                    capabilities: data.capabilities,
                  ),
                ],
              ),
              error: (_) => Center(
                child: CommonErrorView(
                  message: l10n.nativePlatformShowcaseLoadError,
                  retryLabel: l10n.nativePlatformShowcaseRetry,
                  retryButtonKey: const ValueKey<String>(
                    'native-platform-showcase-retry',
                  ),
                  onRetry: () =>
                      context.cubit<NativePlatformShowcaseCubit>().load(),
                ),
              ),
            ),
          ),
    );
  }
}
