import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/cubit/realtime_market_cubit.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/cubit/realtime_market_state.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/widgets/realtime_market_page_body.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/widgets/realtime_market_ui_tokens.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RealtimeMarketPage extends StatelessWidget {
  const RealtimeMarketPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final ThemeData marketTheme = theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        tertiary: kRealtimeMarketBidGreen,
      ),
    );
    return Theme(
      data: marketTheme,
      child: CommonPageLayout(
        title: l10n.realtimeMarketTitle,
        body: RefreshIndicator(
          onRefresh: () => context.cubit<RealtimeMarketCubit>().reconnect(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child:
                    BlocSelector<
                      RealtimeMarketCubit,
                      RealtimeMarketState,
                      bool
                    >(
                      selector: (final s) => s.loadErrorMessage != null,
                      builder: (final context, final hasError) {
                        if (!hasError) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: context.responsiveGapS,
                          ),
                          child: RealtimeMarketLoadErrorBanner(l10n: l10n),
                        );
                      },
                    ),
              ),
              SliverToBoxAdapter(
                child: BlocBuilder<RealtimeMarketCubit, RealtimeMarketState>(
                  buildWhen: (final a, final b) =>
                      a.snapshot != b.snapshot ||
                      a.bootstrapComplete != b.bootstrapComplete ||
                      a.sideTab != b.sideTab,
                  builder: (final context, final state) {
                    final bool showSkeleton =
                        !state.bootstrapComplete && state.snapshot == null;
                    final snap = state.snapshot;
                    final Widget inner = showSkeleton
                        ? const RealtimeMarketSkeletonPlaceholder()
                        : snap == null
                        ? RealtimeMarketEmptyOrErrorBody(l10n: l10n)
                        : RealtimeMarketLoadedBody(
                            snapshot: snap,
                            sideTab: state.sideTab,
                            l10n: l10n,
                          );
                    return Skeletonizer(
                      enabled: showSkeleton,
                      effect: ShimmerEffect(
                        baseColor: theme.colorScheme.surfaceContainerHighest,
                        highlightColor: theme.colorScheme.surface,
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: context.responsiveGapL,
                        ),
                        child: inner,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
