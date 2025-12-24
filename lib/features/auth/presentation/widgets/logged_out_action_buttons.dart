import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LoggedOutActionButtons extends StatelessWidget {
  const LoggedOutActionButtons({
    required this.scale,
    required this.horizontalOffset,
    super.key,
  });

  final double scale;
  final double horizontalOffset;

  @override
  Widget build(final BuildContext context) => Positioned(
    left: horizontalOffset + 16 * scale,
    right: horizontalOffset + 16 * scale,
    top: 727 * scale,
    height: 52 * scale,
    child: Row(
      children: [
        _LoggedOutActionButton(
          label: 'LOG IN',
          scale: scale,
          width: 167 * scale,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          border: const BorderSide(width: 2),
          onPressed: () => context.go(AppRoutes.authPath),
        ),
        SizedBox(width: 9 * scale),
        _LoggedOutActionButton(
          label: 'REGISTER',
          scale: scale,
          width: 167 * scale,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          onPressed: () => context.go(AppRoutes.registerPath),
        ),
      ],
    ),
  );
}

class _LoggedOutActionButton extends StatelessWidget {
  const _LoggedOutActionButton({
    required this.label,
    required this.scale,
    required this.width,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.border,
  });

  final String label;
  final double scale;
  final double width;
  final Color backgroundColor;
  final Color foregroundColor;
  final BorderSide? border;
  final VoidCallback onPressed;

  @override
  Widget build(final BuildContext context) => SizedBox(
    width: width,
    height: double.infinity,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        side: border,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6 * scale),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: GoogleFonts.roboto(
          fontSize: 13 * scale,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.52 * scale,
          height: 15.234 / 13,
        ),
      ),
    ),
  );
}
