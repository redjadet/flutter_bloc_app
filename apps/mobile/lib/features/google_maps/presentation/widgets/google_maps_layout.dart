// coverage:ignore-file
// Simple layout wrapper widget, tested indirectly via google_maps_sample_page tests

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

class GoogleMapsContentLayout extends StatelessWidget {
  const GoogleMapsContentLayout({
    required this.map,
    required this.controls,
    required this.locations,
    super.key,
  });

  final Widget map;
  final Widget controls;
  final Widget locations;

  @override
  Widget build(final BuildContext context) => LayoutBuilder(
    builder: (final context, final constraints) {
      final bool useHorizontalLayout = constraints.maxWidth >= 900;
      final Widget mapSection = SizedBox(
        height: useHorizontalLayout ? double.infinity : 320,
        child: map,
      );
      final Widget detailsSection = ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: useHorizontalLayout ? 360 : double.infinity,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            controls,
            SizedBox(height: context.responsiveGapM),
            locations,
          ],
        ),
      );

      if (useHorizontalLayout) {
        return Padding(
          padding: context.allGapL,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: mapSection),
              SizedBox(width: context.responsiveGapL),
              Flexible(child: detailsSection),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        padding: context.allGapL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            mapSection,
            SizedBox(height: context.responsiveGapL),
            detailsSection,
          ],
        ),
      );
    },
  );
}
