import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_user.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.user, super.key});

  final ProfileUser user;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final avatarSize = context.isMobile ? 128.0 : 160.0;
    final nameFontSize = context.isMobile ? 32.0 : 40.0;

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
                  child: Icon(
                    Icons.person,
                    size: avatarSize * 0.5,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: UI.gapL * 2),
          Text(
            user.name,
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: nameFontSize,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.54,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: UI.gapL * 1.5),
          Text(
            user.location.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: context.responsiveCaptionSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.52,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
