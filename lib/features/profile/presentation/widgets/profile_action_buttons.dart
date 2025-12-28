import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_button_styles.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_max_width.dart';

class ProfileActionButtons extends StatelessWidget {
  const ProfileActionButtons({super.key});

  @override
  Widget build(final BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: context.pageHorizontalPadding),
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
    final buttonHeight = context.responsiveValue<double>(
      mobile: 52,
      tablet: 56,
      desktop: 56,
    );

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: profileOutlinedButtonStyle(
          context,
          backgroundColor: isPrimary ? Colors.black : Colors.white,
        ),
        child: Text(
          label,
          style: profileButtonTextStyle(
            fontSize: 13, // Match Figma: fontSize 13
            color: isPrimary ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
