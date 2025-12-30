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
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: LayoutBuilder(
          builder: (final context, final constraints) {
            final scale = _resolveScale(constraints);
            final horizontalOffset = _horizontalOffset(
              constraints.maxWidth,
              scale,
            );

            return Stack(
              children: [
                LoggedOutBackgroundLayer(
                  scale: scale,
                  constraints: constraints,
                ),
                LoggedOutPhotoHeader(
                  scale: scale,
                  horizontalOffset: horizontalOffset,
                ),
                LoggedOutUserInfo(
                  scale: scale,
                  horizontalOffset: horizontalOffset,
                ),
                LoggedOutActionButtons(
                  scale: scale,
                  horizontalOffset: horizontalOffset,
                ),
                LoggedOutBottomIndicator(
                  scale: scale,
                  horizontalOffset: horizontalOffset,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  double _resolveScale(final BoxConstraints constraints) {
    final widthScale = constraints.maxWidth / _baseWidth;
    final heightScale = constraints.maxHeight / _baseHeight;
    return widthScale < heightScale ? widthScale : heightScale;
  }

  double _horizontalOffset(final double maxWidth, final double scale) {
    final scaledWidth = _baseWidth * scale;
    return (maxWidth - scaledWidth) / 2;
  }
}
