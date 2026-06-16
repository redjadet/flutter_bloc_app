import 'package:flutter/material.dart';

/// Root navigator key assigned to the app GoRouter's `navigatorKey`.
///
/// Staff and case-study demo shells live in the demo route tail while the
/// counter home route is appended last in `createAppRoutes()`. Demo shells use
/// `ShellRoute.builder` (not `parentNavigatorKey`) so `pushNamed` from the
/// example hub updates the browser URL on web.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
