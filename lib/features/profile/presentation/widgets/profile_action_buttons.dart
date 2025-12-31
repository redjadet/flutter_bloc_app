import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_button_styles.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_max_width.dart';

class ProfileActionButtons extends StatelessWidget {
  const ProfileActionButtons({super.key});

  @override
  Widget build(final BuildContext context) => Padding(
    padding: context.pageHorizontalPaddingInsets,
    child: CommonMaxWidth(
      maxWidth: context.clampWidthTo(500),
      child: Column(
        children: [
          SizedBox(height: context.responsiveGapL * 2),
          _ProfileButton(
            label: 'FOLLOW JANE',
            isPrimary: true,
            onPressed: () {},
          ),
          SizedBox(height: context.responsiveGapL),
          _ProfileButton(
            label: 'MESSAGE',
            isPrimary: false,
            onPressed: () {},
          ),
        ],
      ),
    ),
  );
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({
    required this.label,
    required this.isPrimary,
    required this.onPressed,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback onPressed;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final buttonHeight = context.responsiveValue<double>(
      mobile: 52,
      tablet: 56,
      desktop: 56,
    );

    final backgroundColor = isPrimary ? colors.primary : colors.surface;
    final foregroundColor = isPrimary ? colors.onPrimary : colors.onSurface;

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: PlatformAdaptive.outlinedButton(
        context: context,
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        borderRadius: BorderRadius.circular(context.responsiveCardRadius),
        materialStyle: profileOutlinedButtonStyle(
          context,
          backgroundColor: backgroundColor,
        ),
        child: Text(
          label,
          style: profileButtonTextStyle(
            context,
            fontSize: 13, // Match Figma: fontSize 13
            color: foregroundColor,
          ),
        ),
      ),
    );
  }
}
