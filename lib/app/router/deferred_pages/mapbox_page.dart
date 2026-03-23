/// Deferred library for Mapbox feature.
///
/// Loaded on-demand to reduce initial app bundle size.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location_repository.dart';
import 'package:flutter_bloc_app/features/mapbox_demo/presentation/cubit/mapbox_sample_cubit.dart';
import 'package:flutter_bloc_app/features/mapbox_demo/presentation/pages/mapbox_sample_page.dart';
import 'package:flutter_bloc_app/shared/utils/bloc_provider_helpers.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Builds the Mapbox sample page with lazy-loaded Cubit initialization.
Widget buildMapboxPage() {
  final TargetPlatform platform = defaultTargetPlatform;
  final bool isMapboxSupported =
      !kIsWeb &&
      (platform == TargetPlatform.iOS || platform == TargetPlatform.android);

  final String token = SecretConfig.mapboxAccessToken?.trim() ?? '';
  if (isMapboxSupported && token.isNotEmpty) {
    MapboxOptions.setAccessToken(token);
  }

  return BlocProviderHelpers.withAsyncInit<MapboxSampleCubit>(
    create: () => MapboxSampleCubit(
      repository: getIt<MapLocationRepository>(),
    ),
    init: (final cubit) => cubit.loadLocations(),
    child: const MapboxSamplePage(),
  );
}
