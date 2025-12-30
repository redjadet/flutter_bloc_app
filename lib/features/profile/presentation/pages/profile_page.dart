import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_user.dart';
import 'package:flutter_bloc_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_bloc_app/features/profile/presentation/cubit/profile_state.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_action_buttons.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_bottom_nav.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_button_styles.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_gallery.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_header.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_sync_banner.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_app_bar.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_loading_widget.dart';
import 'package:flutter_bloc_app/shared/widgets/common_max_width.dart';
import 'package:flutter_bloc_app/shared/widgets/view_status_switcher.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(final BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: const CommonAppBar(
      title: 'Profile',
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      cupertinoBackgroundColor: Colors.white,
      cupertinoTitleStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBar: const ProfileBottomNav(),
    body: ViewStatusSwitcher<ProfileCubit, ProfileState, _ProfileBodyData>(
      selector: (final state) => _ProfileBodyData(
        isLoading: state.isLoading,
        hasError: state.hasError,
        hasUser: state.hasUser,
        user: state.user,
      ),
      isLoading: (final data) => data.isLoading && !data.hasUser,
      isError: (final data) => data.hasError && !data.hasUser,
      loadingBuilder: (final _) =>
          const CommonLoadingWidget(color: Colors.black),
      errorBuilder: (final context, final _) => CommonErrorView(
        message: 'Failed to load profile',
        onRetry: () => context.read<ProfileCubit>().loadProfile(),
      ),
      builder: (final context, final bodyData) {
        if (!bodyData.hasUser) {
          return const CommonErrorView(
            message: 'Failed to load profile',
          ); // Fallback if state is unexpected
        }

        final profile = bodyData.user!;
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
                      const ProfileSyncBanner(),
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
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              borderRadius: BorderRadius.circular(
                                context.responsiveCardRadius,
                              ),
                              materialStyle: profileOutlinedButtonStyle(
                                context,
                                backgroundColor: Colors.white,
                              ),
                              child: Text(
                                'SEE MORE',
                                style: profileButtonTextStyle(
                                  context,
                                  color: Colors.black,
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

@immutable
class _ProfileBodyData {
  const _ProfileBodyData({
    required this.isLoading,
    required this.hasError,
    required this.hasUser,
    required this.user,
  });

  final bool isLoading;
  final bool hasError;
  final bool hasUser;
  final ProfileUser? user;
}
