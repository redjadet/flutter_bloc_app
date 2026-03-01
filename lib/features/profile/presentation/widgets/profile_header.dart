import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_user.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.user, super.key});

  final ProfileUser user;

  @override
  Widget build(final BuildContext context) {
    // Responsive avatar size using existing responsive utilities
    final avatarSize = context.isDesktop
        ? 160.0
        : context.isTabletOrLarger
        ? 144.0
        : 128.0;

    // Font sizes - keeping Figma design but scaling responsively
    const baseNameFontSize = 36.0;
    final nameFontSize = context.isDesktop
        ? baseNameFontSize *
              1.17 // ~42px
        : context.isTabletOrLarger
        ? baseNameFontSize *
              1.06 // ~38px
        : baseNameFontSize;
    const baseLocationFontSize = 13.0;
    final locationFontSize = context.isDesktop
        ? baseLocationFontSize *
              1.08 // ~14px
        : context.isTabletOrLarger
        ? baseLocationFontSize *
              1.04 // ~13.5px
        : baseLocationFontSize;

    // Use existing responsive gap utilities with multipliers
    final topSpacing = context.pageVerticalPadding * 1.33; // Approx UI.gapL
    final nameSpacing =
        topSpacing *
        (context.isDesktop
            ? 3
            : context.isTabletOrLarger
            ? 2.5
            : 2);
    final locationSpacing =
        topSpacing *
        (context.isDesktop
            ? 2
            : context.isTabletOrLarger
            ? 1.75
            : 1.5);

    return Padding(
      padding: context.pageHorizontalPaddingInsets,
      child: Column(
        children: [
          SizedBox(height: topSpacing),
          ClipOval(
            child: Image.asset(
              'assets/images/profile_avatar.jpg',
              width: avatarSize,
              height: avatarSize,
              fit: BoxFit.cover,
              errorBuilder: (final context, final error, final stackTrace) {
                final theme = Theme.of(context);
                final colors = theme.colorScheme;
                AppLogger.error(
                  'Profile avatar image failed to load',
                  error,
                  stackTrace,
                );
                return Container(
                  width: avatarSize,
                  height: avatarSize,
                  color: colors.surfaceContainerHighest,
                  child: Icon(
                    Icons.error,
                    size: avatarSize * 0.5,
                    color: colors.error,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: nameSpacing),
          // Responsive name text style
          Text(
            user.name,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: nameFontSize,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.54 * (nameFontSize / 36),
              color: Theme.of(context).colorScheme.onSurface,
              height: 40.14 / 36, // Maintain aspect ratio
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: locationSpacing),
          // Responsive location text style
          Text(
            user.location.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: locationFontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.52 * (locationFontSize / 13),
              color: Theme.of(context).colorScheme.onSurface,
              height: 15.234375 / 13, // Maintain aspect ratio
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
