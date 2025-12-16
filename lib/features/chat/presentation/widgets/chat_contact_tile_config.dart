import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

class ChatContactTileConfig {
  ChatContactTileConfig({
    required this.profileImageSize,
    required this.nameFontSize,
    required this.messageFontSize,
    required this.messageLineHeight,
    required this.timeFontSize,
    required this.textColor,
    required this.subtleTextColor,
    required this.unreadBackgroundColor,
    required this.unreadTextColor,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.horizontalGap,
    required this.responsiveGap,
    required this.isTabletOrLarger,
  }) {
    nameTextStyle = TextStyle(
      fontSize: nameFontSize,
      fontWeight: FontWeight.bold,
      color: textColor,
      fontFamily: 'Roboto',
    );
    unreadTextStyle = TextStyle(
      color: unreadTextColor,
      fontSize: isTabletOrLarger ? 13 : 12,
      fontWeight: FontWeight.bold,
      fontFamily: 'Roboto',
    );
    messageTextStyle = TextStyle(
      fontSize: messageFontSize,
      height: messageLineHeight / messageFontSize,
      color: subtleTextColor,
      fontFamily: 'Roboto',
    );
    timeTextStyle = TextStyle(
      fontSize: timeFontSize,
      color: subtleTextColor,
      fontFamily: 'Roboto',
    );
  }

  factory ChatContactTileConfig.fromContext(BuildContext context) {
    final isDesktopLayout = context.isDesktop;
    final isTabletOrLarger = context.isTabletOrLarger;
    final usesTabletTypography = isTabletOrLarger && !isDesktopLayout;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final subtleTextColor =
        theme.textTheme.bodyMedium?.color ?? colors.onSurfaceVariant;

    final profileImageSize = isDesktopLayout
        ? 60.0
        : usesTabletTypography
        ? 55.0
        : 64.0;
    final nameFontSize = isDesktopLayout
        ? 18.0
        : usesTabletTypography
        ? 17.0
        : 13.0;
    final messageFontSize = isDesktopLayout
        ? 15.0
        : usesTabletTypography
        ? 14.5
        : 13.0;
    final messageLineHeight = isDesktopLayout
        ? 20.0
        : usesTabletTypography
        ? 19.0
        : 18.0;
    final timeFontSize = isDesktopLayout
        ? 13.0
        : usesTabletTypography
        ? 12.5
        : 13.0;

    final horizontalPadding =
        context.pageHorizontalPadding -
        (isDesktopLayout
            ? 8
            : usesTabletTypography
            ? 4
            : 0);
    final verticalPadding =
        context.pageVerticalPadding +
        (context.isMobile
            ? 4
            : usesTabletTypography
            ? -2
            : 0);
    final horizontalGap =
        context.responsiveGap +
        (isDesktopLayout
            ? 4
            : usesTabletTypography
            ? 2
            : 4);

    return ChatContactTileConfig(
      profileImageSize: profileImageSize,
      nameFontSize: nameFontSize,
      messageFontSize: messageFontSize,
      messageLineHeight: messageLineHeight,
      timeFontSize: timeFontSize,
      textColor: colors.onSurface,
      subtleTextColor: subtleTextColor,
      unreadBackgroundColor: colors.primary,
      unreadTextColor: colors.onPrimary,
      horizontalPadding: horizontalPadding,
      verticalPadding: verticalPadding,
      horizontalGap: horizontalGap,
      responsiveGap: context.responsiveGap,
      isTabletOrLarger: isTabletOrLarger,
    );
  }

  final double profileImageSize;
  final double nameFontSize;
  final double messageFontSize;
  final double messageLineHeight;
  final double timeFontSize;
  final Color textColor;
  final Color subtleTextColor;
  final Color unreadBackgroundColor;
  final Color unreadTextColor;
  final double horizontalPadding;
  final double verticalPadding;
  final double horizontalGap;
  final double responsiveGap;
  final bool isTabletOrLarger;

  late final TextStyle nameTextStyle;
  late final TextStyle unreadTextStyle;
  late final TextStyle messageTextStyle;
  late final TextStyle timeTextStyle;

  double get messageTimeSpacing => 8;
  double get unreadMinSize => isTabletOrLarger ? 28 : 24;
}
