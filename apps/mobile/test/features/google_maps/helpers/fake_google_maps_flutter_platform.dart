import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

class FakeGoogleMapsFlutterPlatform extends GoogleMapsFlutterPlatform {
  @override
  Future<void> init(int mapId) async {}
  @override
  void dispose({required int mapId}) {}

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
  Future<LatLngBounds> getVisibleRegion({required int mapId}) async =>
      LatLngBounds(southwest: LatLng(0, 0), northeast: LatLng(0, 0));
  @override
  Future<ScreenCoordinate> getScreenCoordinate(
    LatLng latLng, {
    required int mapId,
  }) async => ScreenCoordinate(x: 0, y: 0);
  @override
  Future<LatLng> getLatLng(
    ScreenCoordinate screenCoordinate, {
    required int mapId,
  }) async => LatLng(0, 0);
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
  }) async => false;
  @override
  Future<double> getZoomLevel({required int mapId}) async => 10;
  @override
  Future<Uint8List?> takeSnapshot({required int mapId}) async => null;

  @override
  Stream<CameraMoveStartedEvent> onCameraMoveStarted({required int mapId}) =>
      Stream<CameraMoveStartedEvent>.empty();
  @override
  Stream<CameraMoveEvent> onCameraMove({required int mapId}) =>
      Stream<CameraMoveEvent>.empty();
  @override
  Stream<CameraIdleEvent> onCameraIdle({required int mapId}) =>
      Stream<CameraIdleEvent>.empty();
  @override
  Stream<MarkerTapEvent> onMarkerTap({required int mapId}) =>
      Stream<MarkerTapEvent>.empty();
  @override
  Stream<InfoWindowTapEvent> onInfoWindowTap({required int mapId}) =>
      Stream<InfoWindowTapEvent>.empty();
  @override
  Stream<MarkerDragStartEvent> onMarkerDragStart({required int mapId}) =>
      Stream<MarkerDragStartEvent>.empty();
  @override
  Stream<MarkerDragEvent> onMarkerDrag({required int mapId}) =>
      Stream<MarkerDragEvent>.empty();
  @override
  Stream<MarkerDragEndEvent> onMarkerDragEnd({required int mapId}) =>
      Stream<MarkerDragEndEvent>.empty();
  @override
  Stream<PolylineTapEvent> onPolylineTap({required int mapId}) =>
      Stream<PolylineTapEvent>.empty();
  @override
  Stream<PolygonTapEvent> onPolygonTap({required int mapId}) =>
      Stream<PolygonTapEvent>.empty();
  @override
  Stream<CircleTapEvent> onCircleTap({required int mapId}) =>
      Stream<CircleTapEvent>.empty();
  @override
  Stream<MapTapEvent> onTap({required int mapId}) =>
      Stream<MapTapEvent>.empty();
  @override
  Stream<MapLongPressEvent> onLongPress({required int mapId}) =>
      Stream<MapLongPressEvent>.empty();
  @override
  Stream<ClusterTapEvent> onClusterTap({required int mapId}) =>
      Stream<ClusterTapEvent>.empty();
  @override
  Stream<GroundOverlayTapEvent> onGroundOverlayTap({required int mapId}) =>
      Stream<GroundOverlayTapEvent>.empty();

  @override
  Widget buildView(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required CameraPosition initialCameraPosition,
    Set<Marker> markers = const <Marker>{},
    Set<Polygon> polygons = const <Polygon>{},
    Set<Polyline> polylines = const <Polyline>{},
    Set<Circle> circles = const <Circle>{},
    Set<TileOverlay> tileOverlays = const <TileOverlay>{},
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers =
        const <Factory<OneSequenceGestureRecognizer>>{},
    Map<String, dynamic> mapOptions = const <String, dynamic>{},
  }) {
    onPlatformViewCreated(creationId);
    return const SizedBox.shrink();
  }

  @override
  Widget buildViewWithTextDirection(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required CameraPosition initialCameraPosition,
    required TextDirection textDirection,
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
    Set<Marker> markers = const <Marker>{},
    Set<Polygon> polygons = const <Polygon>{},
    Set<Polyline> polylines = const <Polyline>{},
    Set<Circle> circles = const <Circle>{},
    Set<TileOverlay> tileOverlays = const <TileOverlay>{},
    Map<String, dynamic> mapOptions = const <String, dynamic>{},
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
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required MapWidgetConfiguration widgetConfiguration,
    MapConfiguration mapConfiguration = const MapConfiguration(),
    MapObjects mapObjects = const MapObjects(),
  }) {
    onPlatformViewCreated(creationId);
    return const SizedBox.shrink();
  }

  @override
  Future<bool> isAdvancedMarkersAvailable({required int mapId}) async => true;
  @override
  Future<String?> getStyleError({required int mapId}) async => null;
  @override
  void enableDebugInspection() {}
}
