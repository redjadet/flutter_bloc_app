import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/vocabulary_item.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/widgets/listen_button.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Card showing a vocabulary word with tap-to-hear (kid-friendly).
class WordCard extends StatelessWidget {
  const WordCard({
    required this.item,
    required this.onListen,
    super.key,
  });

  final VocabularyItem item;
  final VoidCallback onListen;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final gapM = context.responsiveGapM;
    final imageSize = context.responsiveGapL * 4; // ~80–100px, kid-friendly
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: context.pageHorizontalPadding,
        vertical: context.responsiveGapS,
      ),
      child: Padding(
        padding: EdgeInsets.all(gapM),
        child: LayoutBuilder(
          builder: (final context, final constraints) {
            final maxW = constraints.maxWidth;
            final bool isCompact = maxW < 260;
            const minSpaceForTextAndButton = 140.0;
            final size =
                (maxW > minSpaceForTextAndButton && imageSize > maxW - minSpaceForTextAndButton)
                ? maxW - minSpaceForTextAndButton
                : imageSize;
            if (isCompact) {
              final double compactSize = math.min(imageSize, maxW);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (item.imageAssetPath != null)
                    Center(
                      child: SizedBox(
                        width: compactSize,
                        height: compactSize,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildImage(
                            context,
                            item.imageAssetPath!,
                            compactSize,
                            theme,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: gapM),
                  Text(
                    item.wordEn,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  SizedBox(height: gapM),
                  Align(
                    child: ListenButton(
                      onPressed: onListen,
                      compact: true,
                    ),
                  ),
                ],
              );
            }
            return Row(
              children: <Widget>[
                if (item.imageAssetPath != null)
                  Padding(
                    padding: EdgeInsets.only(right: gapM),
                    child: SizedBox(
                      width: size,
                      height: size,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildImage(context, item.imageAssetPath!, size, theme),
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    item.wordEn,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                ListenButton(onPressed: onListen),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildImage(
    final BuildContext context,
    final String path,
    final double size,
    final ThemeData theme,
  ) {
    final fallback = SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Icon(
          Icons.pets,
          size: size * 0.5,
          color: theme.colorScheme.outline,
        ),
      ),
    );
    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        width: size,
        height: size,
        placeholderBuilder: (_) => fallback,
      );
    }
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (final c, final e, final s) => fallback,
    );
  }
}
