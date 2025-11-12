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
    final gridLayout = context.calculateGridLayout(
      mobileColumns: 2,
      tabletColumns: 3,
      desktopColumns: 4,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: gridLayout.horizontalPadding),
      child: GridView.builder(
        gridDelegate: context.createResponsiveGridDelegate(
          mobileColumns: 2,
          tabletColumns: 3,
          desktopColumns: 4,
        ),
        itemCount: results.length,
        itemBuilder: (final context, final index) {
          final result = results[index];
          return ClipRect(
            child: SizedBox(
              width: gridLayout.itemWidth,
              height: gridLayout.itemWidth,
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
