import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/shared/widgets/root_aware_back_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Helper widget to load PNG background with error handling
class _BackgroundImage extends StatelessWidget {
  const _BackgroundImage({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/figma/Logged_out_0-2/Rectangle_0-42.png',
    width: width,
    height: height,
    fit: BoxFit.fill,
    errorBuilder: (context, error, stackTrace) => Container(
      width: width,
      height: height,
      color: const Color(0xFF0B0C0D),
    ),
  );
}

/// Helper widget to load SVG shape with error handling
class _ShapeIndicator extends StatelessWidget {
  const _ShapeIndicator({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'assets/figma/Logged_out_0-2/Shape_0-115.svg',
    width: width,
    height: height,
    fit: BoxFit.fill,
    placeholderBuilder: (context) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}

/// Logged out page generated from Figma design Logged_out_0-2
class LoggedOutPage extends StatelessWidget {
  const LoggedOutPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Base design size from Figma
    const double baseWidth = 375;
    const double baseHeight = 812;

    return Scaffold(
      appBar: AppBar(
        leading: const RootAwareBackButton(homeTooltip: 'Home'),
        title: const Text('Logged Out'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate scale factors for responsive design
          final double widthScale = constraints.maxWidth / baseWidth;
          final double heightScale = constraints.maxHeight / baseHeight;
          final double scale = widthScale < heightScale
              ? widthScale
              : heightScale;

          // Calculate centered horizontal offset
          final double scaledWidth = baseWidth * scale;
          final double horizontalOffset =
              (constraints.maxWidth - scaledWidth) / 2;

          return Stack(
            children: [
              // Background Rectangle (with image) - fills horizontal space
              Positioned(
                left: 0,
                top: 0 * scale,
                right: 0,
                height: 707 * scale,
                child: _BackgroundImage(
                  width: constraints.maxWidth,
                  height: 707 * scale,
                ),
              ),

              // "photo" text with icon graphics (Group)
              Positioned(
                left: horizontalOffset + 84 * scale,
                top: 307 * scale,
                width: 206 * scale,
                height: 54 * scale,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Plus icon (simplified as Container with gradient)
                    Container(
                      width: 38 * scale,
                      height: 38 * scale,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4 * scale),
                        gradient: const LinearGradient(
                          begin: Alignment(0.296, -0.064),
                          end: Alignment(0.704, 1.064),
                          colors: [
                            Color(0xFFFF00D7), // r: 1, g: 0, b: 0.84
                            Color(0xFFFF4D00), // r: 1, g: 0.3, b: 0
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
                    // "photo" text
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

              // User Component - Avatar, Name, Username
              Positioned(
                left: horizontalOffset + 16 * scale,
                right: horizontalOffset + 16 * scale,
                top: 659 * scale,
                height: 28 * scale,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar Circle with PNG
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
                    // Name and Username Column - uses available space
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
              ),

              // LOG IN Button
              Positioned(
                left: horizontalOffset + 16 * scale,
                top: 727 * scale,
                width: 167 * scale,
                height: 52 * scale,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to sign in page
                    context.go(AppRoutes.authPath);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: const BorderSide(width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6 * scale),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'LOG IN',
                    style: GoogleFonts.roboto(
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.52 * scale,
                      height: 15.234 / 13,
                    ),
                  ),
                ),
              ),

              // REGISTER Button
              Positioned(
                left: horizontalOffset + 192 * scale,
                top: 727 * scale,
                width: 167 * scale,
                height: 52 * scale,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to register page
                    context.go(AppRoutes.registerPath);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6 * scale),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'REGISTER',
                    style: GoogleFonts.roboto(
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.52 * scale,
                      height: 15.234 / 13,
                    ),
                  ),
                ),
              ),

              // Bottom Shape Indicator (from Shape_0-115.svg)
              Positioned(
                left: horizontalOffset + 120 * scale,
                top: 799 * scale,
                width: 135 * scale,
                height: 5 * scale,
                child: _ShapeIndicator(
                  width: 135 * scale,
                  height: 5 * scale,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
