import 'package:flutter_bloc_app/features/dispersion/domain/calibration.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_dataset.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_group.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_point.dart';

/// Safe map serialization for persistence. Normalizes dynamic keys to String.

Map<String, dynamic> pixelPointToMap(final PixelPoint p) => <String, dynamic>{
  'x': p.x,
  'y': p.y,
};

PixelPoint pixelPointFromMap(final Map<dynamic, dynamic> raw) {
  final Map<String, dynamic> m = raw.map(
    (final dynamic k, final dynamic v) => MapEntry(k.toString(), v),
  );
  final double x = (m['x'] as num?)?.toDouble() ?? 0;
  final double y = (m['y'] as num?)?.toDouble() ?? 0;
  return PixelPoint(x: x, y: y);
}

Map<String, dynamic> calibrationToMap(final Calibration c) => <String, dynamic>{
  'endpoint1Px': pixelPointToMap(c.endpoint1Px),
  'endpoint2Px': pixelPointToMap(c.endpoint2Px),
  'knownLengthMm': c.knownLengthMm,
};

Calibration calibrationFromMap(final Map<dynamic, dynamic> raw) {
  final Map<String, dynamic> m = raw.map(
    (final dynamic k, final dynamic v) => MapEntry(k.toString(), v),
  );
  final PixelPoint e1 = pixelPointFromMap(
    m['endpoint1Px'] as Map<dynamic, dynamic>? ?? <dynamic, dynamic>{},
  );
  final PixelPoint e2 = pixelPointFromMap(
    m['endpoint2Px'] as Map<dynamic, dynamic>? ?? <dynamic, dynamic>{},
  );
  final double known = (m['knownLengthMm'] as num?)?.toDouble() ?? 0;
  return Calibration(endpoint1Px: e1, endpoint2Px: e2, knownLengthMm: known);
}

Map<String, dynamic> dispersionPointToMap(final DispersionPoint p) =>
    <String, dynamic>{
      'id': p.id,
      'xMm': p.xMm,
      'yMm': p.yMm,
      'radialMm': p.radialMm,
      'holeDiameterMm': p.holeDiameterMm,
      'isOutlierAuto': p.isOutlierAuto,
      'isOutlierManual': p.isOutlierManual,
    };

DispersionPoint? dispersionPointFromMap(final Map<dynamic, dynamic> raw) {
  try {
    final Map<String, dynamic> m = raw.map(
      (final dynamic k, final dynamic v) => MapEntry(k.toString(), v),
    );
    final String? id = m['id'] as String?;
    if (id == null || id.isEmpty) return null;
    final double xMm = (m['xMm'] as num?)?.toDouble() ?? 0;
    final double yMm = (m['yMm'] as num?)?.toDouble() ?? 0;
    final double radialMm = (m['radialMm'] as num?)?.toDouble() ?? 0;
    final double holeDiameterMm =
        (m['holeDiameterMm'] as num?)?.toDouble() ?? 0;
    final bool isOutlierAuto = _coerceBool(m['isOutlierAuto']);
    final bool isOutlierManual = _coerceBool(m['isOutlierManual']);
    return DispersionPoint(
      id: id,
      xMm: xMm,
      yMm: yMm,
      radialMm: radialMm,
      holeDiameterMm: holeDiameterMm,
      isOutlierAuto: isOutlierAuto,
      isOutlierManual: isOutlierManual,
    );
  } on Exception {
    return null;
  }
}

bool _coerceBool(final dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    return value.toLowerCase() == 'true';
  }
  return false;
}

Map<String, dynamic> dispersionGroupToMap(final DispersionGroup g) =>
    <String, dynamic>{
      'id': g.id,
      'name': g.name,
      'capturedAt': g.capturedAt.toIso8601String(),
      'distanceToTargetMeters': g.distanceToTargetMeters,
      'imagePath': g.imagePath,
      'calibration': calibrationToMap(g.calibration),
      'aimPointPx': pixelPointToMap(g.aimPointPx),
      'points': g.points.map(dispersionPointToMap).toList(),
    };

DispersionGroup? dispersionGroupFromMap(final Map<dynamic, dynamic> raw) {
  try {
    final Map<String, dynamic> m = raw.map(
      (final dynamic k, final dynamic v) => MapEntry(k.toString(), v),
    );
    final String? id = m['id'] as String?;
    final String? name = m['name'] as String?;
    final String? capturedAt = m['capturedAt'] as String?;
    final double distance =
        (m['distanceToTargetMeters'] as num?)?.toDouble() ?? 0;
    final String? imagePath = m['imagePath'] as String?;
    if (id == null || id.isEmpty || name == null || imagePath == null) {
      return null;
    }
    final DateTime? captured = DateTime.tryParse(capturedAt ?? '')?.toUtc();
    if (captured == null) {
      return null;
    }
    final Calibration cal = calibrationFromMap(
      m['calibration'] as Map<dynamic, dynamic>? ?? <dynamic, dynamic>{},
    );
    final PixelPoint aim = pixelPointFromMap(
      m['aimPointPx'] as Map<dynamic, dynamic>? ?? <dynamic, dynamic>{},
    );
    final List<DispersionPoint> points = <DispersionPoint>[];
    final dynamic pts = m['points'];
    if (pts is Iterable<dynamic>) {
      for (final dynamic e in pts) {
        if (e is Map<dynamic, dynamic>) {
          final DispersionPoint? p = dispersionPointFromMap(e);
          if (p != null) points.add(p);
        }
      }
    }
    return DispersionGroup(
      id: id,
      name: name,
      capturedAt: captured,
      distanceToTargetMeters: distance,
      imagePath: imagePath,
      calibration: cal,
      aimPointPx: aim,
      points: points,
    );
  } on Exception {
    return null;
  }
}

Map<String, dynamic> dispersionDatasetToMap(final DispersionDataset d) =>
    <String, dynamic>{
      'id': d.id,
      'name': d.name,
      'groupIds': d.groupIds,
      'createdAt': d.createdAt.toIso8601String(),
      'isDerived': d.isDerived,
      'sourceDatasetIds': d.sourceDatasetIds,
      'pointCount': d.pointCount,
      'metadata': d.metadata,
    };

DispersionDataset? dispersionDatasetFromMap(final Map<dynamic, dynamic> raw) {
  try {
    final Map<String, dynamic> m = raw.map(
      (final dynamic k, final dynamic v) => MapEntry(k.toString(), v),
    );
    final String? id = m['id'] as String?;
    final String? name = m['name'] as String?;
    final List<String> groupIds = <String>[];
    final dynamic gids = m['groupIds'];
    if (gids is Iterable<dynamic>) {
      for (final dynamic e in gids) {
        if (e != null) groupIds.add(e.toString());
      }
    }
    final String? createdAt = m['createdAt'] as String?;
    final bool isDerived = _coerceBool(m['isDerived']);
    final List<String> sourceDatasetIds = <String>[];
    final dynamic sids = m['sourceDatasetIds'];
    if (sids is Iterable<dynamic>) {
      for (final dynamic e in sids) {
        if (e != null) sourceDatasetIds.add(e.toString());
      }
    }
    final int pointCount = (m['pointCount'] as num?)?.toInt() ?? 0;
    final Map<String, String> metadata = <String, String>{};
    final dynamic meta = m['metadata'];
    if (meta is Map<dynamic, dynamic>) {
      for (final MapEntry<dynamic, dynamic> e in meta.entries) {
        metadata[e.key.toString()] = e.value?.toString() ?? '';
      }
    }
    if (id == null || id.isEmpty || name == null) return null;
    final DateTime? created = DateTime.tryParse(createdAt ?? '')?.toUtc();
    if (created == null) return null;
    return DispersionDataset(
      id: id,
      name: name,
      groupIds: groupIds,
      createdAt: created,
      isDerived: isDerived,
      sourceDatasetIds: sourceDatasetIds,
      pointCount: pointCount,
      metadata: metadata,
    );
  } on Exception {
    return null;
  }
}
