import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
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
    final double headlineSize = context.responsiveHeadlineSize;
    final double backIconSize = context.responsiveIconSize;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.pageHorizontalPadding,
        vertical: UI.gapM,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.black,
            iconSize: backIconSize,
            onPressed: () => NavigationUtils.popOrGoHome(context),
          ),
          SizedBox(width: UI.horizontalGapS),
          Text('Search', style: _titleStyle.copyWith(fontSize: headlineSize)),
        ],
      ),
    );
  }
}
