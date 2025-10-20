import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/remote_config/presentation/cubit/remote_config_cubit.dart';

class AwesomeFeatureWidget extends StatelessWidget {
  const AwesomeFeatureWidget({super.key});

  @override
  Widget build(final BuildContext context) {
    try {
      // Try to access the cubit to check if it exists
      context.read<RemoteConfigCubit>();
      return BlocBuilder<RemoteConfigCubit, RemoteConfigState>(
        builder: (final context, final state) {
          if (state is RemoteConfigLoaded && state.isAwesomeFeatureEnabled) {
            return const Text('Awesome feature is enabled');
          }
          return const SizedBox.shrink();
        },
      );
    } on Exception {
      // If RemoteConfigCubit is not available (e.g., in tests), return empty widget
      return const SizedBox.shrink();
    }
  }
}
