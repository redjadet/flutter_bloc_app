import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_cubit.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_state.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/widgets/google_maps_controls.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/widgets/google_maps_layout.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/widgets/google_maps_location_list.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/widgets/google_maps_messages.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/widgets/map_sample_map_controller.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/widgets/map_sample_map_view.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

part 'google_maps_sample_page.freezed.dart';
part 'google_maps_sample_sections.dart';

@freezed
abstract class _MapBodyData with _$MapBodyData {
  const factory _MapBodyData({
    required final bool showLoading,
    required final bool hasError,
    required final String? errorMessage,
  }) = __MapBodyData;
}

@freezed
abstract class _ControlsViewModel with _$ControlsViewModel {
  const factory _ControlsViewModel({
    required final bool isHybridMapType,
    required final bool trafficEnabled,
  }) = __ControlsViewModel;
}

@freezed
abstract class _LocationListViewModel with _$LocationListViewModel {
  const factory _LocationListViewModel({
    required final List<MapLocation> locations,
    required final String? selectedMarkerId,
  }) = __LocationListViewModel;
}

class GoogleMapsSamplePage extends StatefulWidget {
  const GoogleMapsSamplePage({
    super.key,
    this.platformService,
    this.platformOverride,
  });

  final NativePlatformService? platformService;
  final TargetPlatform? platformOverride;

  @override
  State<GoogleMapsSamplePage> createState() => _GoogleMapsSamplePageState();
}

class _GoogleMapsSamplePageState extends State<GoogleMapsSamplePage> {
  late final MapSampleMapController _mapViewController;
  late final NativePlatformService _platformService;
  bool _hasRequiredApiKey = true;
  bool _isCheckingApiKey = false;
  late final TargetPlatform _platform;
  late final bool _useAppleMaps;

  MapSampleCubit get _cubit => context.cubit<MapSampleCubit>();

  @override
  void initState() {
    super.initState();
    _mapViewController = MapSampleMapController();
    _platform = widget.platformOverride ?? defaultTargetPlatform;
    _useAppleMaps = !kIsWeb && _platform == TargetPlatform.iOS;
    _platformService = widget.platformService ?? NativePlatformService();
    if (_isMapsSupported && !_useAppleMaps) {
      unawaited(_resolveApiKeyAvailability());
    }
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.googleMapsPageTitle,
      useResponsiveBody: false,
      body: _buildBody(context, l10n),
    );
  }

  Widget _buildBody(final BuildContext context, final AppLocalizations l10n) {
    if (!_isMapsSupported) {
      return GoogleMapsUnsupportedMessage(
        message: l10n.googleMapsPageUnsupportedDescription,
      );
    }
    if (!_useAppleMaps && _isCheckingApiKey) {
      return const CommonLoadingWidget();
    }
    if (!_useAppleMaps && !_hasRequiredApiKey) {
      return GoogleMapsMissingKeyMessage(
        title: l10n.googleMapsPageMissingKeyTitle,
        description: l10n.googleMapsPageMissingKeyDescription,
      );
    }
    return BlocSelector<MapSampleCubit, MapSampleState, _MapBodyData>(
      selector: (final state) => _MapBodyData(
        showLoading: state.isLoading && state.markers.isEmpty,
        hasError: state.hasError,
        errorMessage: state.errorMessage,
      ),
      builder: (final context, final data) {
        if (data.showLoading) {
          return const CommonLoadingWidget();
        }
        if (data.hasError) {
          return GoogleMapsErrorMessage(
            message: data.errorMessage ?? l10n.googleMapsPageGenericError,
          );
        }
        return GoogleMapsContentLayout(
          map: _GoogleMapsMapSection(
            controller: _mapViewController,
            cubit: _cubit,
            useAppleMaps: _useAppleMaps,
          ),
          controls: _GoogleMapsControlsSection(
            l10n: l10n,
            onToggleMapType: _cubit.toggleMapType,
            onToggleTraffic: (_) => _cubit.toggleTraffic(),
          ),
          locations: _GoogleMapsLocationListSection(
            l10n: l10n,
            onFocus: (final location) {
              unawaited(_mapViewController.focusOnLocation(location));
            },
          ),
        );
      },
    );
  }

  bool get _isMapsSupported =>
      !kIsWeb &&
      (_platform == TargetPlatform.iOS || _platform == TargetPlatform.android);

  Future<void> _resolveApiKeyAvailability() async {
    if (_useAppleMaps) {
      return;
    }
    setState(() {
      _isCheckingApiKey = true;
    });
    final bool hasKey = await _platformService.hasGoogleMapsApiKey();
    if (!mounted) {
      return;
    }
    setState(() {
      _hasRequiredApiKey = hasKey;
      _isCheckingApiKey = false;
    });
  }
}
