import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/remote_config/presentation/cubit/remote_config_cubit.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_helpers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'awesome_feature_widget.freezed.dart';

@freezed
abstract class _FeatureEnabledData with _$FeatureEnabledData {
  const factory _FeatureEnabledData({required final bool isEnabled}) =
      __FeatureEnabledData;
}

class AwesomeFeatureWidget extends StatefulWidget {
  const AwesomeFeatureWidget({super.key});

  @override
  State<AwesomeFeatureWidget> createState() => _AwesomeFeatureWidgetState();
}

class _AwesomeFeatureWidgetState extends State<AwesomeFeatureWidget> {
  @override
  void initState() {
    super.initState();
    if (CubitHelpers.isCubitAvailable<RemoteConfigCubit, RemoteConfigState>(
      context,
    )) {
      unawaited(context.cubit<RemoteConfigCubit>().ensureInitialized());
    }
  }

  @override
  Widget build(final BuildContext context) {
    if (!CubitHelpers.isCubitAvailable<RemoteConfigCubit, RemoteConfigState>(
      context,
    )) {
      // If RemoteConfigCubit is not available (e.g., in tests), return empty widget
      return const SizedBox.shrink();
    }

    return BlocSelector<
      RemoteConfigCubit,
      RemoteConfigState,
      _FeatureEnabledData
    >(
      selector: (final state) => _FeatureEnabledData(
        isEnabled: state is RemoteConfigLoaded && state.isAwesomeFeatureEnabled,
      ),
      builder: (final context, final data) {
        if (data.isEnabled) {
          return const Text('Awesome feature is enabled');
        }
        return const SizedBox.shrink();
      },
    );
  }
}
