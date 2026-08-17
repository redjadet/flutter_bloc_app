import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amap;
import 'package:flutter_bloc_app/features/google_maps/domain/map_location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

amap.MapType resolveAppleMapType(gmaps.MapType mapType) {
  switch (mapType) {
    case gmaps.MapType.hybrid:
      return amap.MapType.hybrid;
    case gmaps.MapType.satellite:
      return amap.MapType.satellite;
    default:
      return amap.MapType.standard;
  }
}

amap.CameraPosition appleCameraPositionFromGoogle(
  gmaps.CameraPosition position,
) => amap.CameraPosition(
  target: amap.LatLng(position.target.latitude, position.target.longitude),
  zoom: position.zoom,
  pitch: position.tilt,
  heading: position.bearing,
);

gmaps.CameraPosition googleCameraPositionFromApple(
  amap.CameraPosition position,
) => gmaps.CameraPosition(
  target: gmaps.LatLng(position.target.latitude, position.target.longitude),
  zoom: position.zoom,
  tilt: position.pitch,
  bearing: position.heading,
);

amap.CameraUpdate appleCameraUpdateForLocation(MapLocation location) =>
    amap.CameraUpdate.newCameraPosition(
      amap.CameraPosition(
        target: amap.LatLng(
          location.coordinate.latitude,
          location.coordinate.longitude,
        ),
        zoom: 16,
        pitch: 45,
      ),
    );

amap.CameraUpdate appleCameraUpdateForPosition(
  gmaps.CameraPosition position,
) => amap.CameraUpdate.newCameraPosition(
  amap.CameraPosition(
    target: amap.LatLng(
      position.target.latitude,
      position.target.longitude,
    ),
    zoom: position.zoom,
    pitch: position.tilt,
    heading: position.bearing,
  ),
);
