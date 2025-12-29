import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_user.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:google_fonts/google_fonts.dart';

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
                debugPrint('Image Error: $error');
                return Container(
                  width: avatarSize,
                  height: avatarSize,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.error,
                    size: avatarSize * 0.5,
                    color: Colors.red,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: nameSpacing),
          // Responsive name text style
          Text(
            user.name,
            style: GoogleFonts.comfortaa(
              fontSize: nameFontSize,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.54 * (nameFontSize / 36),
              color: Colors.black,
              height: 40.14 / 36, // Maintain aspect ratio
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: locationSpacing),
          // Responsive location text style
          Text(
            user.location.toUpperCase(),
            style: GoogleFonts.roboto(
              fontSize: locationFontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.52 * (locationFontSize / 13),
              color: Colors.black,
              height: 15.234375 / 13, // Maintain aspect ratio
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
