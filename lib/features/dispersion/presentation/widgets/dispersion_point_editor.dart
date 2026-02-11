import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/calibration.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_point.dart';

/// Point editor overlay: image with aim and shot markers; tap to add,
/// tap marker to select, delete selected. Converts tap to pixel offset from aim.
class DispersionPointEditor extends StatefulWidget {
  const DispersionPointEditor({
    required this.imagePath,
    required this.calibration,
    required this.aimPx,
    required this.aimPy,
    required this.points,
    required this.selectedPointId,
    required this.onAddPoint,
    required this.onRemovePoint,
    required this.onSelectPoint,
    super.key,
  });

  final String imagePath;
  final Calibration calibration;
  final double aimPx;
  final double aimPy;
  final List<DispersionPoint> points;
  final String? selectedPointId;
  final void Function(double offsetXpx, double offsetYpx) onAddPoint;
  final void Function(String pointId) onRemovePoint;
  final void Function(String? pointId) onSelectPoint;

  @override
  State<DispersionPointEditor> createState() => _DispersionPointEditorState();
}

class _DispersionPointEditorState extends State<DispersionPointEditor> {
  int? _imageWidth;
  int? _imageHeight;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    unawaited(_loadImageDimensions());
  }

  @override
  void didUpdateWidget(final DispersionPointEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      unawaited(_loadImageDimensions());
    }
  }

  Future<void> _loadImageDimensions() async {
    setState(() {
      _imageWidth = null;
      _imageHeight = null;
      _loadError = null;
    });
    try {
      final File file = File(widget.imagePath);
      if (!file.existsSync()) {
        if (mounted) {
          setState(() => _loadError = 'File not found');
        }
        return;
      }
      final bytes = await file.readAsBytes();
      ui.decodeImageFromList(
        bytes,
        (final ui.Image image) {
          if (mounted) {
            setState(() {
              _imageWidth = image.width;
              _imageHeight = image.height;
            });
            image.dispose();
          }
        },
      );
    } on Object catch (e) {
      if (mounted) {
        setState(() => _loadError = e);
      }
    }
  }

  /// Converts tap position in the [containerSize] to image-pixel offset from aim.
  PixelOffset? _tapToOffset(
    final Offset localPosition,
    final Size containerSize,
  ) {
    final int? w = _imageWidth;
    final int? h = _imageHeight;
    if (w == null || h == null || w <= 0 || h <= 0) {
      return null;
    }
    final double cw = containerSize.width;
    final double ch = containerSize.height;
    final double scale = (cw / w).clamp(0.0, double.infinity);
    final double scaleH = ch / h;
    final double scaleUsed = scale <= scaleH ? scale : scaleH;
    final double contentW = w * scaleUsed;
    final double contentH = h * scaleUsed;
    final double left = (cw - contentW) / 2;
    final double top = (ch - contentH) / 2;
    final double tx = localPosition.dx;
    final double ty = localPosition.dy;
    if (tx < left || tx > left + contentW || ty < top || ty > top + contentH) {
      return null;
    }
    final double imageX = (tx - left) / scaleUsed;
    final double imageY = (ty - top) / scaleUsed;
    return PixelOffset(imageX - widget.aimPx, imageY - widget.aimPy);
  }

  /// Converts point (mm) to display position in the same container layout.
  Offset _pointToDisplay(final DispersionPoint p, final Size containerSize) {
    final int? w = _imageWidth;
    final int? h = _imageHeight;
    if (w == null || h == null || w <= 0 || h <= 0) {
      return Offset.zero;
    }
    final double scale = widget.calibration.scaleFactorMmPerPx;
    if (scale <= 0) {
      return Offset.zero;
    }
    final double offsetPxX = p.xMm / scale;
    final double offsetPxY = p.yMm / scale;
    final double imageX = widget.aimPx + offsetPxX;
    final double imageY = widget.aimPy + offsetPxY;
    final double cw = containerSize.width;
    final double ch = containerSize.height;
    final double scaleDisp = (cw / w).clamp(0.0, double.infinity);
    final double scaleH = ch / h;
    final double scaleUsed = scaleDisp <= scaleH ? scaleDisp : scaleH;
    final double contentW = w * scaleUsed;
    final double contentH = h * scaleUsed;
    final double left = (cw - contentW) / 2;
    final double top = (ch - contentH) / 2;
    return Offset(left + imageX * scaleUsed, top + imageY * scaleUsed);
  }

  Offset _aimToDisplay(final Size containerSize) {
    final int? w = _imageWidth;
    final int? h = _imageHeight;
    if (w == null || h == null || w <= 0 || h <= 0) {
      return Offset.zero;
    }
    final double cw = containerSize.width;
    final double ch = containerSize.height;
    final double scaleDisp = (cw / w).clamp(0.0, double.infinity);
    final double scaleH = ch / h;
    final double scaleUsed = scaleDisp <= scaleH ? scaleDisp : scaleH;
    final double contentW = w * scaleUsed;
    final double contentH = h * scaleUsed;
    final double left = (cw - contentW) / 2;
    final double top = (ch - contentH) / 2;
    return Offset(
      left + widget.aimPx * scaleUsed,
      top + widget.aimPy * scaleUsed,
    );
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    if (_loadError != null) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Could not load image',
          style: theme.textTheme.bodySmall,
        ),
      );
    }
    if (_imageWidth == null || _imageHeight == null) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (final context, final constraints) {
          final Size size = Size(
            constraints.maxWidth,
            (constraints.maxWidth * (_imageHeight! / _imageWidth!)).clamp(
              120.0,
              400.0,
            ),
          );
          return SizedBox(
            width: size.width,
            height: size.height,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (final TapUpDetails details) {
                final PixelOffset? offset = _tapToOffset(
                  details.localPosition,
                  size,
                );
                if (offset != null) {
                  widget.onAddPoint(offset.dx, offset.dy);
                }
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(widget.imagePath),
                      width: size.width,
                      height: size.height,
                      fit: BoxFit.contain,
                    ),
                  ),
                  _AimMarker(offset: _aimToDisplay(size)),
                  ...widget.points.map(
                    (final DispersionPoint p) => _PointMarker(
                      offset: _pointToDisplay(p, size),
                      isSelected: p.id == widget.selectedPointId,
                      isOutlier: p.isOutlier,
                      onTap: () => widget.onSelectPoint(p.id),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Internal: pixel offset from aim (image coordinates).
class PixelOffset {
  const PixelOffset(this.dx, this.dy);
  final double dx;
  final double dy;
}

class _AimMarker extends StatelessWidget {
  const _AimMarker({required this.offset});

  final Offset offset;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Positioned(
      left: offset.dx - 12,
      top: offset.dy - 12,
      width: 24,
      height: 24,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
            border: Border.all(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _PointMarker extends StatelessWidget {
  const _PointMarker({
    required this.offset,
    required this.isSelected,
    required this.isOutlier,
    required this.onTap,
  });

  final Offset offset;
  final bool isSelected;
  final bool isOutlier;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    const double r = 14;
    Color fill = theme.colorScheme.secondary.withValues(alpha: 0.6);
    if (isOutlier) {
      fill = theme.colorScheme.error.withValues(alpha: 0.5);
    }
    if (isSelected) {
      fill = theme.colorScheme.primary.withValues(alpha: 0.7);
    }
    return Positioned(
      left: offset.dx - r,
      top: offset.dy - r,
      width: r * 2,
      height: r * 2,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fill,
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              width: isSelected ? 3 : 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
