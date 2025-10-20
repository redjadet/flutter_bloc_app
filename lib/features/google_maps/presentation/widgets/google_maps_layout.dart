import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

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
    builder: (final BuildContext context, final BoxConstraints constraints) {
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
            SizedBox(height: UI.gapM),
            locations,
          ],
        ),
      );

      if (useHorizontalLayout) {
        return Padding(
          padding: EdgeInsets.all(UI.gapL),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: mapSection),
              SizedBox(width: UI.gapL),
              Flexible(child: detailsSection),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        padding: EdgeInsets.all(UI.gapL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            mapSection,
            SizedBox(height: UI.gapL),
            detailsSection,
          ],
        ),
      );
    },
  );
}
