import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoggedOutPhotoHeader extends StatelessWidget {
  const LoggedOutPhotoHeader({
    required this.scale,
    required this.horizontalOffset,
    super.key,
  });

  final double scale;
  final double horizontalOffset;

  @override
  Widget build(final BuildContext context) => Positioned(
    left: horizontalOffset + 84 * scale,
    top: 307 * scale,
    width: 206 * scale,
    height: 54 * scale,
    child: ClipRect(
      child: OverflowBox(
        alignment: Alignment.centerLeft,
        minWidth: 206 * scale,
        maxWidth: double.infinity,
        minHeight: 54 * scale,
        maxHeight: 54 * scale,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38 * scale,
              height: 38 * scale,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4 * scale),
                gradient: const LinearGradient(
                  begin: Alignment(0.296, -0.064),
                  end: Alignment(0.704, 1.064),
                  colors: [
                    Color(0xFFFF00D7),
                    Color(0xFFFF4D00),
                  ],
                ),
              ),
              child: Icon(
                Icons.add,
                size: 24 * scale,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8 * scale),
            Text(
              'photo',
              style: GoogleFonts.comfortaa(
                fontSize: 48 * scale,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                letterSpacing: -0.72 * scale,
                height: 53.52 / 48,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
