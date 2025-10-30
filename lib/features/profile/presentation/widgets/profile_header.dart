import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_user.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.user, super.key});

  final ProfileUser user;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    // Match Figma: 128x128 avatar
    const avatarSize = 128.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.pageHorizontalPadding),
      child: Column(
        children: [
          SizedBox(height: UI.gapL),
          ClipOval(
            child: SizedBox(
              width: avatarSize,
              height: avatarSize,
              child: FancyShimmerImage(
                imageUrl: user.avatarUrl,
                boxFit: BoxFit.cover,
                shimmerBaseColor: theme.colorScheme.surfaceContainerHighest,
                shimmerHighlightColor: theme.colorScheme.surface,
                errorWidget: Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.person,
                    size: 64,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: UI.gapL * 2),
          // Match Figma: fontSize 36, Comfortaa Regular, letterSpacing -0.54
          Text(
            user.name,
            style: GoogleFonts.comfortaa(
              fontSize: 36,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.54,
              color: Colors.black,
              height: 40.14 / 36, // lineHeightPx / fontSize from Figma
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: UI.gapL * 1.5),
          // Match Figma: fontSize 13, Roboto Black, letterSpacing 0.52, uppercase
          Text(
            user.location.toUpperCase(),
            style: GoogleFonts.roboto(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.52,
              color: Colors.black,
              height: 15.234375 / 13, // lineHeightPx / fontSize from Figma
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
