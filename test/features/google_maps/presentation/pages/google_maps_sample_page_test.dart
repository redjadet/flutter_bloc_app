import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_cubit.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/cubit/map_sample_state.dart';
import 'package:flutter_bloc_app/features/google_maps/presentation/pages/google_maps_sample_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/platform/native_platform_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:mocktail/mocktail.dart';

class MockMapSampleCubit extends MockCubit<MapSampleState>
    implements MapSampleCubit {}

class MockNativePlatformService extends Mock implements NativePlatformService {}

class _FakeGoogleMapsFlutterPlatform extends GoogleMapsFlutterPlatform {
  @override
  Future<void> init(int mapId) async {}

  @override
  Future<void> updateMapConfiguration(
    MapConfiguration configuration, {
    required int mapId,
  }) async {}

  @override
  Future<void> updateMarkers(
    MarkerUpdates markerUpdates, {
    required int mapId,
  }) async {}

  @override
  Future<void> updatePolygons(
    PolygonUpdates polygonUpdates, {
    required int mapId,
  }) async {}

  @override
  Future<void> updatePolylines(
    PolylineUpdates polylineUpdates, {
    required int mapId,
  }) async {}

  @override
  Future<void> updateCircles(
    CircleUpdates circleUpdates, {
    required int mapId,
  }) async {}

  @override
  Future<void> updateHeatmaps(
    HeatmapUpdates heatmapUpdates, {
    required int mapId,
  }) async {}

  @override
  Future<void> updateTileOverlays({
    required Set<TileOverlay> newTileOverlays,
    required int mapId,
  }) async {}

  @override
  Future<void> updateClusterManagers(
    ClusterManagerUpdates clusterManagerUpdates, {
    required int mapId,
  }) async {}

  @override
  Future<void> updateGroundOverlays(
    GroundOverlayUpdates groundOverlayUpdates, {
    required int mapId,
  }) async {}

  @override
  Future<void> clearTileCache(
    TileOverlayId tileOverlayId, {
    required int mapId,
  }) async {}

  @override
  Future<void> animateCamera(
    CameraUpdate cameraUpdate, {
    required int mapId,
  }) async {}

  @override
  Future<void> moveCamera(
    CameraUpdate cameraUpdate, {
    required int mapId,
  }) async {}

  @override
  Future<void> setMapStyle(String? mapStyle, {required int mapId}) async {}

  @override
  Future<LatLngBounds> getVisibleRegion({required int mapId}) async {
    return LatLngBounds(
      southwest: const LatLng(0, 0),
      northeast: const LatLng(1, 1),
    );
  }

  @override
  Future<ScreenCoordinate> getScreenCoordinate(
    LatLng latLng, {
    required int mapId,
  }) async {
    return const ScreenCoordinate(x: 0, y: 0);
  }

  @override
  Future<LatLng> getLatLng(
    ScreenCoordinate screenCoordinate, {
    required int mapId,
  }) async {
    return const LatLng(0, 0);
  }

  @override
  Future<void> showMarkerInfoWindow(
    MarkerId markerId, {
    required int mapId,
  }) async {}

  @override
  Future<void> hideMarkerInfoWindow(
    MarkerId markerId, {
    required int mapId,
  }) async {}

  @override
  Future<bool> isMarkerInfoWindowShown(
    MarkerId markerId, {
    required int mapId,
  }) async {
    return false;
  }

  @override
  Future<double> getZoomLevel({required int mapId}) async => 10;

  @override
  Future<Uint8List?> takeSnapshot({required int mapId}) async => Uint8List(0);

  @override
  Stream<CameraMoveStartedEvent> onCameraMoveStarted({required int mapId}) {
    return Stream<CameraMoveStartedEvent>.empty();
  }

  @override
  Stream<CameraMoveEvent> onCameraMove({required int mapId}) {
    return Stream<CameraMoveEvent>.empty();
  }

  @override
  Stream<CameraIdleEvent> onCameraIdle({required int mapId}) {
    return Stream<CameraIdleEvent>.empty();
  }

  @override
  Stream<MarkerTapEvent> onMarkerTap({required int mapId}) {
    return Stream<MarkerTapEvent>.empty();
  }

  @override
  Stream<InfoWindowTapEvent> onInfoWindowTap({required int mapId}) {
    return Stream<InfoWindowTapEvent>.empty();
  }

  @override
  Stream<MarkerDragStartEvent> onMarkerDragStart({required int mapId}) {
    return Stream<MarkerDragStartEvent>.empty();
  }

  @override
  Stream<MarkerDragEvent> onMarkerDrag({required int mapId}) {
    return Stream<MarkerDragEvent>.empty();
  }

  @override
  Stream<MarkerDragEndEvent> onMarkerDragEnd({required int mapId}) {
    return Stream<MarkerDragEndEvent>.empty();
  }

  @override
  Stream<PolylineTapEvent> onPolylineTap({required int mapId}) {
    return Stream<PolylineTapEvent>.empty();
  }

  @override
  Stream<PolygonTapEvent> onPolygonTap({required int mapId}) {
    return Stream<PolygonTapEvent>.empty();
  }

  @override
  Stream<CircleTapEvent> onCircleTap({required int mapId}) {
    return Stream<CircleTapEvent>.empty();
  }

  @override
  Stream<MapTapEvent> onTap({required int mapId}) {
    return Stream<MapTapEvent>.empty();
  }

  @override
  Stream<MapLongPressEvent> onLongPress({required int mapId}) {
    return Stream<MapLongPressEvent>.empty();
  }

  @override
  Stream<ClusterTapEvent> onClusterTap({required int mapId}) {
    return Stream<ClusterTapEvent>.empty();
  }

  @override
  Stream<GroundOverlayTapEvent> onGroundOverlayTap({required int mapId}) {
    return Stream<GroundOverlayTapEvent>.empty();
  }

  @override
  void dispose({required int mapId}) {}

  @override
  void enableDebugInspection() {}

  @override
  Widget buildViewWithConfiguration(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required MapWidgetConfiguration widgetConfiguration,
    MapConfiguration mapConfiguration = const MapConfiguration(),
    MapObjects mapObjects = const MapObjects(),
  }) {
    Future<void>.microtask(() => onPlatformViewCreated(creationId));
    return const SizedBox.shrink();
  }
}

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
    registerFallbackValue(MapSampleState.initial());
  });

  group('GoogleMapsSamplePage', () {
    late MockMapSampleCubit mockMapSampleCubit;
    late MockNativePlatformService mockNativePlatformService;
    late GoogleMapsFlutterPlatform originalPlatform;

    setUp(() {
      mockMapSampleCubit = MockMapSampleCubit();
      mockNativePlatformService = MockNativePlatformService();
      whenListen<MapSampleState>(
        mockMapSampleCubit,
        Stream<MapSampleState>.empty(),
        initialState: MapSampleState.initial(),
      );

      originalPlatform = GoogleMapsFlutterPlatform.instance;
      GoogleMapsFlutterPlatform.instance = _FakeGoogleMapsFlutterPlatform();
    });

    tearDown(() {
      GoogleMapsFlutterPlatform.instance = originalPlatform;
      debugDefaultTargetPlatformOverride = null;
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        localizationsDelegates: const [AppLocalizations.delegate],
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<MapSampleCubit>(
          create: (_) => mockMapSampleCubit,
          child: GoogleMapsSamplePage(
            platformService: mockNativePlatformService,
          ),
        ),
      );
    }

    testWidgets('renders unsupported message when maps is not supported', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      addTearDown(() {
        debugDefaultTargetPlatformOverride = null;
      });
      when(
        () => mockNativePlatformService.hasGoogleMapsApiKey(),
      ).thenAnswer((_) async => true);
      when(() => mockMapSampleCubit.state).thenReturn(MapSampleState.initial());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(
        find.text(l10n.googleMapsPageUnsupportedDescription),
        findsOneWidget,
      );
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('renders missing key message when api key is missing', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() {
        debugDefaultTargetPlatformOverride = null;
      });
      when(
        () => mockNativePlatformService.hasGoogleMapsApiKey(),
      ).thenAnswer((_) async => false);
      when(() => mockMapSampleCubit.state).thenReturn(MapSampleState.initial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text(l10n.googleMapsPageMissingKeyTitle), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('renders loading indicator when loading', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() {
        debugDefaultTargetPlatformOverride = null;
      });
      when(
        () => mockNativePlatformService.hasGoogleMapsApiKey(),
      ).thenAnswer((_) async => true);
      when(
        () => mockMapSampleCubit.state,
      ).thenReturn(MapSampleState.initial().copyWith(isLoading: true));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('renders error message when there is an error', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() {
        debugDefaultTargetPlatformOverride = null;
      });
      when(
        () => mockNativePlatformService.hasGoogleMapsApiKey(),
      ).thenAnswer((_) async => true);
      when(() => mockMapSampleCubit.state).thenReturn(
        MapSampleState.initial().copyWith(
          isLoading: false,
          errorMessage: 'Error',
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Error'), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('renders map content when there is data', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() {
        debugDefaultTargetPlatformOverride = null;
      });
      when(
        () => mockNativePlatformService.hasGoogleMapsApiKey(),
      ).thenAnswer((_) async => true);
      when(() => mockMapSampleCubit.state).thenReturn(
        MapSampleState.initial().copyWith(isLoading: false, markers: {}),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump();

      expect(find.byType(GoogleMap), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
