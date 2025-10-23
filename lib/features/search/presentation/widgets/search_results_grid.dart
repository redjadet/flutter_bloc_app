import 'dart:math' as math;

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/search/domain/search_result.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

class SearchResultsGrid extends StatelessWidget {
  const SearchResultsGrid({required this.results, super.key});

  final List<SearchResult> results;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = context.pageHorizontalPadding;
    final availableWidth = screenWidth - (horizontalPadding * 2);
    final int columns = math.max(3, context.gridColumns);
    final double spacing = context.responsiveGap;
    final double totalSpacing = spacing * (columns - 1);
    final double constrainedWidth = (availableWidth - totalSpacing)
        .clamp(0, double.maxFinite)
        .toDouble();
    final double itemWidth = constrainedWidth / columns;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        ),
        itemCount: results.length,
        itemBuilder: (final context, final index) {
          final result = results[index];
          return ClipRect(
            child: SizedBox(
              width: itemWidth,
              height: itemWidth,
              child: FancyShimmerImage(
                imageUrl: result.imageUrl,
                boxFit: BoxFit.cover,
                shimmerBaseColor: theme.colorScheme.surfaceContainerHighest,
                shimmerHighlightColor: theme.colorScheme.surface,
                errorWidget: Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.error_outline, color: Colors.black54),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
