import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_user.dart';
import 'package:flutter_bloc_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_bloc_app/features/profile/presentation/cubit/profile_state.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_action_buttons.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_bottom_nav.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_button_styles.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_gallery.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_header.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_loading_widget.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/shared/widgets/view_status_switcher.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_page.freezed.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.profilePageTitle,
      appBarBackgroundColor: colors.surface,
      appBarForegroundColor: colors.onSurface,
      cupertinoTitleStyle: TextStyle(
        color: colors.onSurface,
        fontWeight: FontWeight.w600,
      ),
      useResponsiveBody: false,
      bottomNavigationBar: const ProfileBottomNav(),
      body: ViewStatusSwitcher<ProfileCubit, ProfileState, _ProfileBodyData>(
        selector: (final state) => _ProfileBodyData(
          isLoading: state.isLoading,
          hasError: state.hasError,
          hasUser: state.hasUser,
          user: state.user,
          errorMessage: state.errorMessage,
        ),
        isLoading: (final data) => data.isLoading && !data.hasUser,
        isError: (final data) => data.hasError && !data.hasUser,
        loadingBuilder: (final context) {
          final colors = Theme.of(context).colorScheme;
          return CommonLoadingWidget(color: colors.onSurface);
        },
        errorBuilder: (final context, final data) => CommonErrorView(
          message: data.errorMessage ?? context.l10n.featureLoadError,
          onRetry: () => context.cubit<ProfileCubit>().loadProfile(),
        ),
        builder: (final context, final bodyData) {
          final colors = Theme.of(context).colorScheme;
          final profile = bodyData.user;
          if (!bodyData.hasUser || profile == null) {
            return CommonErrorView(
              message: context.l10n.featureLoadError,
            ); // Fallback if state is unexpected
          }
          final double sectionSpacing =
              context.pageVerticalPadding *
              (context.isDesktop
                  ? 3
                  : context.isTabletOrLarger
                  ? 2.5
                  : 2);
          final double buttonMaxWidth = context.clampWidthTo(500);

          return RepaintBoundary(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: CommonMaxWidth(
                    child: Column(
                      children: [
                        ProfileHeader(user: profile),
                        const ProfileActionButtons(),
                        SizedBox(height: sectionSpacing),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: CommonMaxWidth(
                    child: ProfileGallery(images: profile.galleryImages),
                  ),
                ),
                SliverToBoxAdapter(
                  child: CommonMaxWidth(
                    child: Padding(
                      padding: context.pageHorizontalPaddingInsets,
                      child: Column(
                        children: [
                          SizedBox(height: sectionSpacing),
                          CommonMaxWidth(
                            maxWidth: buttonMaxWidth,
                            child: SizedBox(
                              width: double.infinity,
                              height: context.responsiveButtonHeight,
                              child: PlatformAdaptive.outlinedButton(
                                context: context,
                                onPressed: () {},
                                backgroundColor: colors.surface,
                                foregroundColor: colors.onSurface,
                                borderRadius: BorderRadius.circular(
                                  context.responsiveCardRadius,
                                ),
                                materialStyle: profileOutlinedButtonStyle(
                                  context,
                                  backgroundColor: colors.surface,
                                ),
                                child: Text(
                                  context.l10n.profileSeeMore,
                                  style: profileButtonTextStyle(
                                    context,
                                    color: colors.onSurface,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height:
                                sectionSpacing + context.safeAreaInsets.bottom,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

@freezed
abstract class _ProfileBodyData with _$ProfileBodyData {
  const factory _ProfileBodyData({
    required final bool isLoading,
    required final bool hasError,
    required final bool hasUser,
    required final ProfileUser? user,
    final String? errorMessage,
  }) = __ProfileBodyData;
}
