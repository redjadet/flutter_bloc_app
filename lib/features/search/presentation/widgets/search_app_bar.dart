import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

class SearchAppBar extends StatelessWidget {
  const SearchAppBar({super.key});

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bool useCupertino =
        theme.platform == TargetPlatform.iOS ||
        theme.platform == TargetPlatform.macOS;
    final double headlineSize = context.responsiveHeadlineSize;
    final double backIconSize = context.responsiveIconSize;
    final Color titleColor = colors.onSurface;
    final TextStyle effectiveTitleStyle =
        (theme.textTheme.displaySmall ?? TextStyle(color: colors.onSurface))
            .copyWith(
              fontSize: headlineSize,
              color: titleColor,
            );

    return Padding(
      padding: context.pageHorizontalPaddingWithVertical(
        context.responsiveGapM,
      ),
      child: Row(
        children: [
          if (useCupertino)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => NavigationUtils.popOrGoHome(context),
              child: Icon(
                CupertinoIcons.left_chevron,
                color: titleColor,
                size: backIconSize,
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.arrow_back),
              color: titleColor,
              iconSize: backIconSize,
              onPressed: () => NavigationUtils.popOrGoHome(context),
            ),
          SizedBox(width: context.responsiveHorizontalGapS),
          Text(
            context.l10n.searchHint.replaceFirst('...', ''),
            style: effectiveTitleStyle,
          ),
        ],
      ),
    );
  }
}
