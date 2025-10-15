import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_bloc_app/features/remote_config/presentation/cubit/remote_config_cubit.dart';

class AwesomeFeatureWidget extends StatelessWidget {
  const AwesomeFeatureWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RemoteConfigCubit, RemoteConfigState>(
      builder: (context, state) {
        if (state is RemoteConfigLoaded && state.isAwesomeFeatureEnabled) {
          return const Text('Awesome feature is enabled');
        }
        return const SizedBox.shrink();
      },
    );
  }
}
