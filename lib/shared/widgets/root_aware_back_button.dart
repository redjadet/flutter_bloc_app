import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';

/// Displays a back button when the navigator can pop, otherwise a home button.
class RootAwareBackButton extends StatelessWidget {
  const RootAwareBackButton({super.key, required this.homeTooltip});

  final String homeTooltip;

  @override
  Widget build(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    if (navigator.canPop()) {
      return BackButton(onPressed: () => NavigationUtils.popOrGoHome(context));
    }
    return IconButton(
      icon: const Icon(Icons.home_outlined),
      tooltip: homeTooltip,
      onPressed: () => NavigationUtils.popOrGoHome(context),
    );
  }
}
