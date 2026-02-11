import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/calibration.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_point.dart';
import 'package:flutter_bloc_app/features/dispersion/presentation/cubit/dispersion_cubit.dart';
import 'package:flutter_bloc_app/features/dispersion/presentation/cubit/dispersion_state.dart';
import 'package:flutter_bloc_app/features/dispersion/presentation/widgets/dispersion_point_editor.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_max_width.dart';

class DispersionCreateGroupBody extends StatelessWidget {
  const DispersionCreateGroupBody({
    required this.imagePath,
    required this.knownLengthMm,
    required this.distanceMeters,
    required this.groupName,
    required this.holeDiameterMm,
    required this.pointsCount,
    required this.hasCalibration,
    required this.hasAimPoint,
    this.calibration,
    this.calibrationE1x = 0,
    this.calibrationE1y = 0,
    this.calibrationE2x = 0,
    this.calibrationE2y = 0,
    this.aimPx = 0,
    this.aimPy = 0,
    this.createPoints = const [],
    this.createSelectedPointId,
    this.errorMessage,
    super.key,
  });

  final String? imagePath;
  final double knownLengthMm;
  final double distanceMeters;
  final String? groupName;
  final double? holeDiameterMm;
  final int pointsCount;
  final bool hasCalibration;
  final bool hasAimPoint;
  final Calibration? calibration;
  final double calibrationE1x;
  final double calibrationE1y;
  final double calibrationE2x;
  final double calibrationE2y;
  final double aimPx;
  final double aimPy;
  final List<DispersionPoint> createPoints;
  final String? createSelectedPointId;
  final String? errorMessage;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.responsiveGapM),
      child: CommonMaxWidth(
        maxWidth: context.contentMaxWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (errorMessage != null && errorMessage!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: context.responsiveGapM),
                child: Material(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: EdgeInsets.all(context.responsiveGapS),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => context.cubit<DispersionCubit>().clearError(),
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Row(
              children: <Widget>[
                PlatformAdaptive.filledButton(
                  context: context,
                  onPressed: () => context.cubit<DispersionCubit>().pickImageFromCamera(),
                  child: Text(l10n.dispersionCamera),
                ),
                SizedBox(width: context.responsiveGapS),
                PlatformAdaptive.outlinedButton(
                  context: context,
                  onPressed: () => context.cubit<DispersionCubit>().pickImageFromGallery(),
                  child: Text(l10n.dispersionGallery),
                ),
                if (kDebugMode) ...[
                  SizedBox(width: context.responsiveGapS),
                  PlatformAdaptive.outlinedButton(
                    context: context,
                    onPressed: () => context.cubit<DispersionCubit>().loadTestImage(),
                    child: Text(l10n.dispersionUseTestImage),
                  ),
                ],
              ],
            ),
            if (kDebugMode) ...[
              SizedBox(height: context.responsiveGapS),
              PlatformAdaptive.outlinedButton(
                context: context,
                onPressed: () => context.cubit<DispersionCubit>().applyCreateTestValues(),
                child: Text(l10n.dispersionFillTestValues),
              ),
            ],
            if (imagePath != null) ...[
              SizedBox(height: context.responsiveGapS),
              if (calibration != null && hasAimPoint)
                DispersionPointEditor(
                  key: ValueKey<String>(
                    '${createPoints.length}_${createPoints.map((final e) => e.id).join(",")}',
                  ),
                  imagePath: imagePath!,
                  calibration: calibration!,
                  aimPx: aimPx,
                  aimPy: aimPy,
                  points: createPoints,
                  selectedPointId: createSelectedPointId,
                  onAddPoint: (final double dx, final double dy) {
                    context.cubit<DispersionCubit>().addCreatePoint(
                      PixelPoint(x: dx, y: dy),
                    );
                  },
                  onRemovePoint: (final String id) {
                    context.cubit<DispersionCubit>().removeCreatePoint(id);
                  },
                  onSelectPoint: (final String? id) {
                    context.cubit<DispersionCubit>().setCreateSelectedPoint(id);
                  },
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(imagePath!),
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              if (createSelectedPointId != null) ...[
                SizedBox(height: context.responsiveGapS),
                Row(
                  children: <Widget>[
                    Text(
                      l10n.dispersionSelectedPoint,
                      style: theme.textTheme.bodySmall,
                    ),
                    SizedBox(width: context.responsiveGapS),
                    PlatformAdaptive.outlinedButton(
                      context: context,
                      onPressed: () {
                        context.cubit<DispersionCubit>().removeCreatePoint(
                          createSelectedPointId!,
                        );
                        context.cubit<DispersionCubit>().setCreateSelectedPoint(
                          null,
                        );
                      },
                      child: Text(l10n.dispersionDeleteSelected),
                    ),
                  ],
                ),
              ],
            ],
            if (createPoints.isNotEmpty) ...[
              SizedBox(height: context.responsiveGapM),
              Text(
                l10n.dispersionPointList,
                style: theme.textTheme.titleSmall,
              ),
              SizedBox(height: context.responsiveGapS),
              ...createPoints.map<Widget>(
                (final DispersionPoint p) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: context.responsiveGapS),
                    child: Material(
                      borderRadius: BorderRadius.circular(8),
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.responsiveGapM,
                          vertical: context.responsiveGapS,
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${l10n.dispersionRadialMm}: ${p.radialMm.toStringAsFixed(1)}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                            Text(
                              '${l10n.dispersionOutlierAuto}: ${p.isOutlierAuto ? "Y" : "N"}',
                              style: theme.textTheme.bodySmall,
                            ),
                            SizedBox(width: context.responsiveGapS),
                            Semantics(
                              label: l10n.dispersionMarkAsOutlier,
                              child: Switch(
                                value: p.isOutlierManual,
                                onChanged: (final bool v) {
                                  context.cubit<DispersionCubit>().setCreatePointOutlierManual(
                                    p.id,
                                    value: v,
                                  );
                                },
                              ),
                            ),
                            Text(
                              '${l10n.dispersionOutlierEffective}: ${p.isOutlier ? "Y" : "N"}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
            SizedBox(height: context.responsiveGapM),
            Text(
              l10n.dispersionCalibrationHint,
              style: theme.textTheme.bodySmall,
            ),
            _NumberField(
              label: l10n.dispersionCalibrationE1x,
              value: calibrationE1x,
              onChanged: (final v) =>
                  context.cubit<DispersionCubit>().setCreateCalibrationFromNumbers(
                    v,
                    calibrationE1y,
                    calibrationE2x,
                    calibrationE2y,
                    knownLengthMm,
                  ),
            ),
            _NumberField(
              label: l10n.dispersionCalibrationE1y,
              value: calibrationE1y,
              onChanged: (final v) =>
                  context.cubit<DispersionCubit>().setCreateCalibrationFromNumbers(
                    calibrationE1x,
                    v,
                    calibrationE2x,
                    calibrationE2y,
                    knownLengthMm,
                  ),
            ),
            _NumberField(
              label: l10n.dispersionCalibrationE2x,
              value: calibrationE2x,
              onChanged: (final v) =>
                  context.cubit<DispersionCubit>().setCreateCalibrationFromNumbers(
                    calibrationE1x,
                    calibrationE1y,
                    v,
                    calibrationE2y,
                    knownLengthMm,
                  ),
            ),
            _NumberField(
              label: l10n.dispersionCalibrationE2y,
              value: calibrationE2y,
              onChanged: (final v) =>
                  context.cubit<DispersionCubit>().setCreateCalibrationFromNumbers(
                    calibrationE1x,
                    calibrationE1y,
                    calibrationE2x,
                    v,
                    knownLengthMm,
                  ),
            ),
            _NumberField(
              label: l10n.dispersionKnownLengthMm,
              value: knownLengthMm,
              onChanged: (final v) =>
                  context.cubit<DispersionCubit>().setCreateCalibrationFromNumbers(
                    calibrationE1x,
                    calibrationE1y,
                    calibrationE2x,
                    calibrationE2y,
                    v,
                  ),
            ),
            Text(
              l10n.dispersionAimPointPx,
              style: theme.textTheme.titleSmall,
            ),
            _NumberField(
              label: l10n.dispersionAimPointX,
              value: aimPx,
              onChanged: (final v) =>
                  context.cubit<DispersionCubit>().setCreateAimFromNumbers(v, aimPy),
            ),
            _NumberField(
              label: l10n.dispersionAimPointY,
              value: aimPy,
              onChanged: (final v) =>
                  context.cubit<DispersionCubit>().setCreateAimFromNumbers(aimPx, v),
            ),
            _NumberField(
              label: l10n.dispersionDistanceM,
              value: distanceMeters,
              onChanged: (final v) => context.cubit<DispersionCubit>().setCreateDistanceMeters(v),
            ),
            _NumberField(
              label: l10n.dispersionHoleDiameterMm,
              value: holeDiameterMm ?? 0,
              onChanged: (final v) => context.cubit<DispersionCubit>().setCreateHoleDiameterMm(v),
            ),
            TextFormField(
              initialValue: groupName ?? '',
              decoration: InputDecoration(
                labelText: l10n.dispersionGroupName,
                hintText: l10n.dispersionGroupNameHint,
              ),
              onChanged: (final v) => context.cubit<DispersionCubit>().setCreateGroupName(v),
            ),
            SizedBox(height: context.responsiveGapS),
            Text(
              '${l10n.dispersionPoints}: $pointsCount',
              style: theme.textTheme.bodyMedium,
            ),
            if (kDebugMode && imagePath != null && hasCalibration && hasAimPoint) ...[
              SizedBox(height: context.responsiveGapS),
              PlatformAdaptive.outlinedButton(
                context: context,
                onPressed: () => context.cubit<DispersionCubit>().addSamplePoints(),
                child: Text(l10n.dispersionAddSamplePoints),
              ),
            ],
            SizedBox(height: context.responsiveGapM),
            Row(
              children: <Widget>[
                PlatformAdaptive.filledButton(
                  context: context,
                  onPressed: () => context.cubit<DispersionCubit>().setScreen(
                    DispersionScreen.home,
                  ),
                  child: Text(l10n.dispersionBack),
                ),
                SizedBox(width: context.responsiveGapS),
                PlatformAdaptive.filledButton(
                  context: context,
                  onPressed: () => context.cubit<DispersionCubit>().saveGroup(),
                  child: Text(l10n.dispersionSaveGroup),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final void Function(double) onChanged;

  @override
  Widget build(final BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.responsiveGapS),
      child: TextFormField(
        key: ValueKey<String>('$label-$value'),
        initialValue: value.toString(),
        decoration: InputDecoration(labelText: label),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (final v) {
          final double? parsed = double.tryParse(v);
          if (parsed != null) {
            onChanged(parsed);
          }
        },
      ),
    );
  }
}
