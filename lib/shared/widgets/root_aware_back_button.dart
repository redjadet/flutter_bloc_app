import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:go_router/go_router.dart';

/// Displays a back button when the navigator can pop, otherwise a home button.
class RootAwareBackButton extends StatelessWidget {
  const RootAwareBackButton({super.key, required this.homeTooltip});

  final String homeTooltip;

  @override
  Widget build(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    if (navigator.canPop()) {
      return const BackButton();
    }
    return IconButton(
      icon: const Icon(Icons.home_outlined),
      tooltip: homeTooltip,
      onPressed: () => context.go(AppRoutes.counterPath),
    );
  }
}
