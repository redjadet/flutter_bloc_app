import 'package:flutter_bloc_app/core/constants/app_constants.dart';
import 'package:flutter_bloc_app/core/flavor.dart';

/// Runtime configuration determined at app initialization.
///
/// Single source of truth for flavor, init-time feature toggles, and
/// endpoint base URLs. Built once during bootstrap and registered in DI.
/// Use this for compliance and a single place to control feature/endpoint
/// behavior; keep remote config (e.g. Firebase Remote Config) on-demand.
///
/// See [docs/app_initialization_and_feature_control.md](../../docs/app_initialization_and_feature_control.md).
class AppRuntimeConfig {
  AppRuntimeConfig({
    required this.flavor,
    required this.skeletonDelay,
    this.apiBaseUrl,
  });

  /// Builds config from current bootstrap state (flavor + env).
  ///
  /// Call after [FlavorManager.current] is set (e.g. in bootstrap).
  factory AppRuntimeConfig.fromBootstrap() {
    final Flavor flavor = FlavorManager.current;
    const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');
    final Duration skeletonDelay = flavor == Flavor.dev
        ? AppConstants.devSkeletonDelay
        : Duration.zero;
    return AppRuntimeConfig(
      flavor: flavor,
      apiBaseUrl: apiBaseUrl.isEmpty ? null : apiBaseUrl,
      skeletonDelay: skeletonDelay,
    );
  }

  final Flavor flavor;
  final String? apiBaseUrl;
  final Duration skeletonDelay;

  bool get isDev => flavor == Flavor.dev;
  bool get isStaging => flavor == Flavor.staging;
  bool get isQa => flavor == Flavor.qa;
  bool get isBeta => flavor == Flavor.beta;
  bool get isProd => flavor == Flavor.prod;

  String get name => switch (flavor) {
    Flavor.dev => 'dev',
    Flavor.staging => 'staging',
    Flavor.qa => 'qa',
    Flavor.beta => 'beta',
    Flavor.prod => 'prod',
  };
}
