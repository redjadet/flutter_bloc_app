import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_bloc_app/features/profile/presentation/cubit/profile_state.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_action_buttons.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_bottom_nav.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_gallery.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_header.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(final BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Profile',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    bottomNavigationBar: const ProfileBottomNav(),
    body: BlocBuilder<ProfileCubit, ProfileState>(
      builder: (final context, final state) {
        if (state.isLoading && !state.hasUser) {
          return const _ProfileLoadingView();
        }

        if (state.hasError && !state.hasUser) {
          return _ProfileErrorView(
            onRetry: () => context.read<ProfileCubit>().loadProfile(),
          );
        }

        if (!state.hasUser) {
          return const _ProfileErrorView(); // Fallback if state is unexpected
        }

        final profile = state.user!;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: context.contentMaxWidth,
                  ),
                  child: Column(
                    children: [
                      ProfileHeader(user: profile),
                      const ProfileActionButtons(),
                      SizedBox(
                        height:
                            context.pageVerticalPadding *
                            (context.isDesktop
                                ? 3
                                : context.isTabletOrLarger
                                ? 2.5
                                : 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: context.contentMaxWidth,
                  ),
                  child: ProfileGallery(images: profile.galleryImages),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: context.contentMaxWidth,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.pageHorizontalPadding,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height:
                              context.pageVerticalPadding *
                              (context.isDesktop
                                  ? 3
                                  : context.isTabletOrLarger
                                  ? 2.5
                                  : 2),
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: context.responsiveButtonHeight,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: context.isDesktop
                                  ? 600
                                  : context.isTabletOrLarger
                                  ? 500
                                  : double.infinity,
                            ),
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                'SEE MORE',
                                style: GoogleFonts.roboto(
                                  fontSize:
                                      context.responsiveBodySize *
                                      (context.isDesktop
                                          ? 0.875
                                          : context.isTabletOrLarger
                                          ? 0.844
                                          : 0.813),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.52,
                                  color: Colors.black,
                                  height: 15.234375 / 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height:
                              context.pageVerticalPadding *
                                  (context.isDesktop
                                      ? 3
                                      : context.isTabletOrLarger
                                      ? 2.5
                                      : 2) +
                              context.safeAreaInsets.bottom,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _ProfileLoadingView extends StatelessWidget {
  const _ProfileLoadingView();

  @override
  Widget build(final BuildContext context) => const Center(
    child: CircularProgressIndicator(color: Colors.black),
  );
}

class _ProfileErrorView extends StatelessWidget {
  const _ProfileErrorView({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: context.responsiveStatePadding,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: context.responsiveErrorIconSize,
          color: Colors.black54,
        ),
        SizedBox(height: context.responsiveGapL),
        Text(
          'Failed to load profile',
          style: TextStyle(
            fontSize: context.responsiveTitleSize,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        if (onRetry != null) ...[
          SizedBox(height: context.responsiveGapL * 1.5),
          SizedBox(
            height: context.responsiveButtonHeight,
            child: _RetryButton(onPressed: onRetry!),
          ),
        ],
      ],
    ),
  );
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(final BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: const Color(0xFF050505), width: 1.5),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onPressed,
        child: const Center(
          child: Text(
            'TRY AGAIN',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.black,
            ),
          ),
        ),
      ),
    ),
  );
}
