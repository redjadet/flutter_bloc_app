import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileActionButtons extends StatelessWidget {
  const ProfileActionButtons({super.key});

  @override
  Widget build(final BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: context.pageHorizontalPadding),
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
    final maxWidth = context.clampWidthTo(500);
    final buttonHeight = context.responsiveValue<double>(
      mobile: 52,
      tablet: 56,
      desktop: 56,
    );

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: isPrimary ? Colors.black : Colors.white,
            side: const BorderSide(width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 13, // Match Figma: fontSize 13
              fontWeight: FontWeight.w900,
              letterSpacing: 0.52,
              color: isPrimary ? Colors.white : Colors.black,
              height: 15.234375 / 13, // lineHeightPx / fontSize from Figma
            ),
          ),
        ),
      ),
    );
  }
}
