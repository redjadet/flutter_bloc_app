import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoggedOutUserInfo extends StatelessWidget {
  const LoggedOutUserInfo({
    required this.scale,
    required this.horizontalOffset,
    super.key,
  });

  final double scale;
  final double horizontalOffset;

  @override
  Widget build(BuildContext context) => Positioned(
    left: horizontalOffset + 16 * scale,
    right: horizontalOffset + 16 * scale,
    top: 659 * scale,
    height: 28 * scale,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 28 * scale,
          height: 28 * scale,
          child: Image.asset(
            'assets/figma/Logged_out_0-2/loggedout_person.png',
            width: 28 * scale,
            height: 28 * scale,
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 28 * scale,
              height: 28 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              child: Icon(
                Icons.person,
                size: 20 * scale,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
        SizedBox(width: 8 * scale),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Pawel Czerwinski',
                style: GoogleFonts.roboto(
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  height: 15.234 / 13,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                '@pawel_czerwinski',
                style: GoogleFonts.roboto(
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w400,
                  color: Colors.black.withValues(alpha: 0.8),
                  height: 12.891 / 11,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
