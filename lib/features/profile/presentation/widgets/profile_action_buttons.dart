import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

class ProfileActionButtons extends StatelessWidget {
  const ProfileActionButtons({super.key});

  @override
  Widget build(final BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: context.pageHorizontalPadding),
    child: Column(
      children: [
        SizedBox(height: UI.gapL * 2),
        _ProfileButton(
          label: 'FOLLOW JANE',
          isPrimary: true,
          onPressed: () {},
        ),
        SizedBox(height: UI.gapL),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth.clamp(0.0, 500.0);

    return SizedBox(
      width: double.infinity,
      height: context.isMobile ? 52 : 56,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: isPrimary ? Colors.black : Colors.white,
            side: const BorderSide(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: context.responsiveCaptionSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.52,
              color: isPrimary ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
