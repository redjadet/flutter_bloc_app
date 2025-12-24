import 'dart:math' as math;

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
  Widget build(final BuildContext context) {
    const double nameLineHeight = 15.234;
    const double handleLineHeight = 12.891;
    const double avatarSize = 28;
    final double avatarExtent = avatarSize * scale;
    final double textExtent = (nameLineHeight + handleLineHeight) * scale;
    final double containerHeight = math.max(avatarExtent, textExtent) + scale;

    return Positioned(
      left: horizontalOffset + 16 * scale,
      right: horizontalOffset + 16 * scale,
      top: 659 * scale,
      height: containerHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: avatarExtent,
            height: avatarExtent,
            child: Image.asset(
              'assets/figma/Logged_out_0-2/loggedout_person.png',
              width: avatarExtent,
              height: avatarExtent,
              fit: BoxFit.fill,
              errorBuilder: (final context, final error, final stackTrace) =>
                  Container(
                    width: avatarExtent,
                    height: avatarExtent,
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
                    height: nameLineHeight / 13,
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
                    height: handleLineHeight / 11,
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
}
