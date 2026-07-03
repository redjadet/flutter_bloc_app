/// Deferred library for Google Maps feature.
///
/// This library is loaded on-demand to reduce initial app bundle size.
/// The Google Maps and Apple Maps packages are heavy and only needed
/// when the user navigates to the maps page.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/google_maps/google_maps.dart';
import 'package:flutter_bloc_app/shared/utils/bloc_provider_helpers.dart';

/// Builds the Google Maps sample page with lazy-loaded cubit initialization.
///
/// This function is called after the deferred library is loaded.
/// It creates a [MapSampleCubit] and initializes it with location data.
Widget buildGoogleMapsPage() =>
    BlocProviderHelpers.withAsyncInit<MapSampleCubit>(
      create: () => MapSampleCubit(
        repository: getIt<MapLocationRepository>(),
      ),
      init: (final cubit) => cubit.loadLocations(),
      child: const GoogleMapsSamplePage(),
    );
