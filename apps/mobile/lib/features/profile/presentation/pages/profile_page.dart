import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/app/widgets/view_status_switcher.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_user.dart';
import 'package:flutter_bloc_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_bloc_app/features/profile/presentation/cubit/profile_state.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_action_buttons.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_bottom_nav.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_button_styles.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_gallery.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_header.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';
import 'package:material_ui/material_ui.dart';

part 'profile_page.freezed.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
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
        selector: (state) => _ProfileBodyData(
          isLoading: state.isLoading,
          hasError: state.hasError,
          hasUser: state.hasUser,
          user: state.user,
          errorMessage: state.errorMessage,
        ),
        isLoading: (data) => data.isLoading && !data.hasUser,
        isError: (data) => data.hasError && !data.hasUser,
        loadingBuilder: (context) {
          final colors = Theme.of(context).colorScheme;
          return CommonLoadingWidget(color: colors.onSurface);
        },
        errorBuilder: (context, data) => CommonErrorView(
          message: data.errorMessage ?? context.l10n.featureLoadError,
          onRetry: () => context.cubit<ProfileCubit>().loadProfile(),
        ),
        builder: (context, bodyData) {
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
    required bool isLoading,
    required bool hasError,
    required bool hasUser,
    required ProfileUser? user,
    String? errorMessage,
  }) = __ProfileBodyData;
}
