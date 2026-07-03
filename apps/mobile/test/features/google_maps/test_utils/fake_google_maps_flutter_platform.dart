import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

class FakeGoogleMapsFlutterPlatform extends GoogleMapsFlutterPlatform {
  @override
  Future<void> init(final int mapId) async {}
  @override
  void dispose({required final int mapId}) {}

  @override
  Future<void> updateMapConfiguration(
    final MapConfiguration configuration, {
    required final int mapId,
  }) async {}
  @override
  Future<void> updateMarkers(
    final MarkerUpdates markerUpdates, {
    required final int mapId,
  }) async {}
  @override
  Future<void> updatePolygons(
    final PolygonUpdates polygonUpdates, {
    required final int mapId,
  }) async {}
  @override
  Future<void> updatePolylines(
    final PolylineUpdates polylineUpdates, {
    required final int mapId,
  }) async {}
  @override
  Future<void> updateCircles(
    final CircleUpdates circleUpdates, {
    required final int mapId,
  }) async {}
  @override
  Future<void> updateHeatmaps(
    final HeatmapUpdates heatmapUpdates, {
    required final int mapId,
  }) async {}
  @override
  Future<void> updateTileOverlays({
    required final Set<TileOverlay> newTileOverlays,
    required final int mapId,
  }) async {}
  @override
  Future<void> updateClusterManagers(
    final ClusterManagerUpdates clusterManagerUpdates, {
    required final int mapId,
  }) async {}
  @override
  Future<void> updateGroundOverlays(
    final GroundOverlayUpdates groundOverlayUpdates, {
    required final int mapId,
  }) async {}
  @override
  Future<void> clearTileCache(
    final TileOverlayId tileOverlayId, {
    required final int mapId,
  }) async {}

  @override
  Future<void> animateCamera(
    final CameraUpdate cameraUpdate, {
    required final int mapId,
  }) async {}
  @override
  Future<void> moveCamera(
    final CameraUpdate cameraUpdate, {
    required final int mapId,
  }) async {}
  @override
  Future<void> setMapStyle(
    final String? mapStyle, {
    required final int mapId,
  }) async {}
  @override
  Future<LatLngBounds> getVisibleRegion({required final int mapId}) async =>
      LatLngBounds(southwest: LatLng(0, 0), northeast: LatLng(0, 0));
  @override
  Future<ScreenCoordinate> getScreenCoordinate(
    final LatLng latLng, {
    required final int mapId,
  }) async => ScreenCoordinate(x: 0, y: 0);
  @override
  Future<LatLng> getLatLng(
    final ScreenCoordinate screenCoordinate, {
    required final int mapId,
  }) async => LatLng(0, 0);
  @override
  Future<void> showMarkerInfoWindow(
    final MarkerId markerId, {
    required final int mapId,
  }) async {}
  @override
  Future<void> hideMarkerInfoWindow(
    final MarkerId markerId, {
    required final int mapId,
  }) async {}
  @override
  Future<bool> isMarkerInfoWindowShown(
    final MarkerId markerId, {
    required final int mapId,
  }) async => false;
  @override
  Future<double> getZoomLevel({required final int mapId}) async => 10;
  @override
  Future<Uint8List?> takeSnapshot({required final int mapId}) async => null;

  @override
  Stream<CameraMoveStartedEvent> onCameraMoveStarted({
    required final int mapId,
  }) => Stream<CameraMoveStartedEvent>.empty();
  @override
  Stream<CameraMoveEvent> onCameraMove({required final int mapId}) =>
      Stream<CameraMoveEvent>.empty();
  @override
  Stream<CameraIdleEvent> onCameraIdle({required final int mapId}) =>
      Stream<CameraIdleEvent>.empty();
  @override
  Stream<MarkerTapEvent> onMarkerTap({required final int mapId}) =>
      Stream<MarkerTapEvent>.empty();
  @override
  Stream<InfoWindowTapEvent> onInfoWindowTap({required final int mapId}) =>
      Stream<InfoWindowTapEvent>.empty();
  @override
  Stream<MarkerDragStartEvent> onMarkerDragStart({required final int mapId}) =>
      Stream<MarkerDragStartEvent>.empty();
  @override
  Stream<MarkerDragEvent> onMarkerDrag({required final int mapId}) =>
      Stream<MarkerDragEvent>.empty();
  @override
  Stream<MarkerDragEndEvent> onMarkerDragEnd({required final int mapId}) =>
      Stream<MarkerDragEndEvent>.empty();
  @override
  Stream<PolylineTapEvent> onPolylineTap({required final int mapId}) =>
      Stream<PolylineTapEvent>.empty();
  @override
  Stream<PolygonTapEvent> onPolygonTap({required final int mapId}) =>
      Stream<PolygonTapEvent>.empty();
  @override
  Stream<CircleTapEvent> onCircleTap({required final int mapId}) =>
      Stream<CircleTapEvent>.empty();
  @override
  Stream<MapTapEvent> onTap({required final int mapId}) =>
      Stream<MapTapEvent>.empty();
  @override
  Stream<MapLongPressEvent> onLongPress({required final int mapId}) =>
      Stream<MapLongPressEvent>.empty();
  @override
  Stream<ClusterTapEvent> onClusterTap({required final int mapId}) =>
      Stream<ClusterTapEvent>.empty();
  @override
  Stream<GroundOverlayTapEvent> onGroundOverlayTap({
    required final int mapId,
  }) => Stream<GroundOverlayTapEvent>.empty();

  @override
  Widget buildView(
    final int creationId,
    final PlatformViewCreatedCallback onPlatformViewCreated, {
    required final CameraPosition initialCameraPosition,
    final Set<Marker> markers = const <Marker>{},
    final Set<Polygon> polygons = const <Polygon>{},
    final Set<Polyline> polylines = const <Polyline>{},
    final Set<Circle> circles = const <Circle>{},
    final Set<TileOverlay> tileOverlays = const <TileOverlay>{},
    final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers =
        const <Factory<OneSequenceGestureRecognizer>>{},
    final Map<String, dynamic> mapOptions = const <String, dynamic>{},
  }) {
    onPlatformViewCreated(creationId);
    return const SizedBox.shrink();
  }

  @override
  Widget buildViewWithTextDirection(
    final int creationId,
    final PlatformViewCreatedCallback onPlatformViewCreated, {
    required final CameraPosition initialCameraPosition,
    required final TextDirection textDirection,
    final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
    final Set<Marker> markers = const <Marker>{},
    final Set<Polygon> polygons = const <Polygon>{},
    final Set<Polyline> polylines = const <Polyline>{},
    final Set<Circle> circles = const <Circle>{},
    final Set<TileOverlay> tileOverlays = const <TileOverlay>{},
    final Map<String, dynamic> mapOptions = const <String, dynamic>{},
  }) => buildView(
    creationId,
    onPlatformViewCreated,
    initialCameraPosition: initialCameraPosition,
    markers: markers,
    polygons: polygons,
    polylines: polylines,
    circles: circles,
    tileOverlays: tileOverlays,
    gestureRecognizers: gestureRecognizers,
    mapOptions: mapOptions,
  );
  @override
  Widget buildViewWithConfiguration(
    final int creationId,
    final PlatformViewCreatedCallback onPlatformViewCreated, {
    required final MapWidgetConfiguration widgetConfiguration,
    final MapConfiguration mapConfiguration = const MapConfiguration(),
    final MapObjects mapObjects = const MapObjects(),
  }) {
    onPlatformViewCreated(creationId);
    return const SizedBox.shrink();
  }

  @override
  Future<bool> isAdvancedMarkersAvailable({required final int mapId}) async =>
      true;
  @override
  Future<String?> getStyleError({required final int mapId}) async => null;
  @override
  void enableDebugInspection() {}
}
