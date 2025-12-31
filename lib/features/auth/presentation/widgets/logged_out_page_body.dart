import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/logged_out_action_buttons.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/logged_out_background_layer.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/logged_out_bottom_indicator.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/logged_out_photo_header.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/logged_out_user_info.dart';

class LoggedOutPageBody extends StatelessWidget {
  const LoggedOutPageBody({super.key});

  static const double _baseWidth = 375;
  static const double _baseHeight = 812;

  @override
  Widget build(final BuildContext context) {
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);
    final EdgeInsets safePadding = MediaQuery.paddingOf(context);
    final double textScale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (final context, final constraints) {
        final scale = _resolveScale(constraints);
        final double verticalScale = scale * textScale;
        final double contentHeight = math.max(
          constraints.maxHeight,
          _baseHeight * verticalScale,
        );
        final double contentWidth = _baseWidth * scale;
        final double horizontalPadding = contentWidth * (16 / _baseWidth);
        final EdgeInsets contentPadding = EdgeInsets.fromLTRB(
          horizontalPadding,
          safePadding.top,
          horizontalPadding,
          safePadding.bottom + viewInsets.bottom,
        );
        const double baseTopGap = 307;
        const double baseGapAfterPhoto = 298;
        const double baseGapAfterUser = 39;
        const double baseGapAfterButtons = 20;
        const double baseGapTotal =
            baseTopGap +
            baseGapAfterPhoto +
            baseGapAfterUser +
            baseGapAfterButtons;
        final double photoHeaderHeight = 54 * verticalScale;
        const double nameLineHeight = 15.234;
        const double handleLineHeight = 12.891;
        const double avatarSize = 28;
        final double avatarExtent = avatarSize * scale;
        final double textExtent =
            (nameLineHeight + handleLineHeight) * verticalScale;
        final double userInfoHeight =
            math.max(avatarExtent, textExtent) + verticalScale;
        final double buttonsHeight = 52 * verticalScale;
        final double indicatorHeight = 5 * verticalScale;
        final double availableHeight = contentHeight - contentPadding.vertical;
        final double remaining = math.max(
          0,
          availableHeight -
              (photoHeaderHeight +
                  userInfoHeight +
                  buttonsHeight +
                  indicatorHeight),
        );
        final double topGap = remaining * (baseTopGap / baseGapTotal);
        final double gapAfterPhoto =
            remaining * (baseGapAfterPhoto / baseGapTotal);
        final double gapAfterUser =
            remaining * (baseGapAfterUser / baseGapTotal);
        final double gapAfterButtons =
            remaining * (baseGapAfterButtons / baseGapTotal);
        final double backgroundBottomGap = math.max(
          8 * verticalScale,
          remaining * 0.04,
        );
        final double backgroundHeight = math.max(
          0,
          topGap +
              photoHeaderHeight +
              gapAfterPhoto +
              userInfoHeight +
              gapAfterUser -
              backgroundBottomGap,
        );

        final Widget layout = Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: contentWidth,
            height: contentHeight,
            child: Stack(
              children: [
                LoggedOutBackgroundLayer(
                  height: backgroundHeight,
                ),
                Padding(
                  padding: contentPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: topGap),
                      LoggedOutPhotoHeader(
                        scale: scale,
                        verticalScale: verticalScale,
                      ),
                      SizedBox(height: gapAfterPhoto),
                      LoggedOutUserInfo(
                        scale: scale,
                        verticalScale: verticalScale,
                      ),
                      SizedBox(height: gapAfterUser),
                      LoggedOutActionButtons(
                        scale: scale,
                        verticalScale: verticalScale,
                      ),
                      SizedBox(height: gapAfterButtons),
                      Align(
                        child: LoggedOutBottomIndicator(
                          scale: scale,
                          verticalScale: verticalScale,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

        if (contentHeight <= constraints.maxHeight) {
          return layout;
        }

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: layout,
        );
      },
    );
  }

  double _resolveScale(final BoxConstraints constraints) {
    final widthScale = constraints.maxWidth / _baseWidth;
    final heightScale = constraints.maxHeight / _baseHeight;
    return widthScale < heightScale ? widthScale : heightScale;
  }
}
