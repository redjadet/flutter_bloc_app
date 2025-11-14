import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';

class SearchAppBar extends StatelessWidget {
  const SearchAppBar({super.key});

  static const TextStyle _titleStyle = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.54,
    color: Colors.black,
  );

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final bool useCupertino =
        theme.platform == TargetPlatform.iOS ||
        theme.platform == TargetPlatform.macOS;
    final double headlineSize = context.responsiveHeadlineSize;
    final double backIconSize = context.responsiveIconSize;
    final Color titleColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.onSurface
        : Colors.black;
    final TextStyle effectiveTitleStyle =
        (theme.textTheme.displaySmall ?? _titleStyle).copyWith(
          fontSize: headlineSize,
          color: titleColor,
        );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.pageHorizontalPadding,
        vertical: context.responsiveGapM,
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
          Text('Search', style: effectiveTitleStyle),
        ],
      ),
    );
  }
}
