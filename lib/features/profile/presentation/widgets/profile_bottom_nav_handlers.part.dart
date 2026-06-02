part of 'profile_bottom_nav.dart';

Future<void> _handleTap(
  final BuildContext context,
  final _NavItem item,
  final String currentLocation,
) async {
  final _NavDestination? destination = item.destination;
  if (destination == null) {
    await _pushRoute(
      context,
      AppRoutes.registerPath,
      logContext: 'ProfileBottomNav._handleTap.action',
    );
    return;
  }

  if (destination.route == AppRoutes.profilePath) {
    return;
  }

  if (destination.matches(currentLocation)) {
    return;
  }

  if (destination.route == AppRoutes.examplePath) {
    _goToExample(context);
    return;
  }

  await _pushRoute(
    context,
    destination.route,
    logContext: 'ProfileBottomNav._handleTap.navigate',
  );
}

void _goToExample(final BuildContext context) {
  if (!_ensureMounted(context, 'ProfileBottomNav._handleTap.example')) {
    return;
  }
  if (!NavigationUtils.maybePop(context)) {
    context.go(AppRoutes.examplePath);
  }
}

Future<void> _pushRoute(
  final BuildContext context,
  final String route, {
  required final String logContext,
}) async {
  if (!_ensureMounted(context, logContext)) {
    return;
  }
  await context.push(route);
}

bool _ensureMounted(final BuildContext context, final String logContext) {
  if (context.mounted) {
    return true;
  }
  ContextUtils.logNotMounted(logContext);
  return false;
}
