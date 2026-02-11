import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/dispersion/presentation/cubit/dispersion_cubit.dart';
import 'package:flutter_bloc_app/features/dispersion/presentation/cubit/dispersion_state.dart';
import 'package:flutter_bloc_app/features/dispersion/presentation/widgets/dispersion_combine_datasets_body.dart';
import 'package:flutter_bloc_app/features/dispersion/presentation/widgets/dispersion_compare_body.dart';
import 'package:flutter_bloc_app/features/dispersion/presentation/widgets/dispersion_create_group_body.dart';
import 'package:flutter_bloc_app/features/dispersion/presentation/widgets/dispersion_home_body.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

class DispersionPage extends StatelessWidget {
  const DispersionPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.dispersionPageTitle,
      body: BlocBuilder<DispersionCubit, DispersionState>(
        builder: (final context, final state) {
          if (state.screen == DispersionScreen.createGroup) {
            return DispersionCreateGroupBody(
              imagePath: state.createImagePath,
              knownLengthMm: state.createKnownLengthMm,
              distanceMeters: state.createDistanceMeters,
              groupName: state.createGroupName,
              holeDiameterMm: state.createHoleDiameterMm,
              pointsCount: state.createPoints.length,
              hasCalibration: state.createCalibration != null,
              hasAimPoint: state.createAimPointPx != null,
              calibration: state.createCalibration,
              aimPx: state.createAimPx,
              aimPy: state.createAimPy,
              createPoints: state.createPoints,
              createSelectedPointId: state.createSelectedPointId,
              calibrationE1x: state.createCalibrationE1x,
              calibrationE1y: state.createCalibrationE1y,
              calibrationE2x: state.createCalibrationE2x,
              calibrationE2y: state.createCalibrationE2y,
              errorMessage: state.errorMessage,
            );
          }
          if (state.screen == DispersionScreen.combineDatasets) {
            return DispersionCombineDatasetsBody(
              datasets: state.datasets,
              errorMessage: state.errorMessage,
            );
          }
          if (state.screen == DispersionScreen.compare) {
            return DispersionCompareBody(
              datasets: state.datasets,
              selectedAId: state.compareDatasetAId,
              selectedBId: state.compareDatasetBId,
              alpha: state.compareAlpha,
              excludeOutliers: state.compareExcludeOutliers,
              result: state.compareResult,
              isLoading: state.compareLoading,
              pointsA: state.comparePointsA ?? const [],
              pointsB: state.comparePointsB ?? const [],
            );
          }
          return DispersionHomeBody(
            datasets: state.datasets,
            groups: state.groups,
            isLoading: state.isLoading,
            errorMessage: state.errorMessage,
          );
        },
      ),
    );
  }
}
