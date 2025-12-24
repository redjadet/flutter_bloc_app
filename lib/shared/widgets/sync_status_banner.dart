import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/app_message.dart';

/// Global sync status banner that displays when sync is degraded or error.
///
/// Shows "Sync issues detected" message with retry action when sync status
/// is degraded. Can be integrated into CommonPageLayout or app scaffold.
class SyncStatusBanner extends StatelessWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(
    final BuildContext context,
  ) => BlocBuilder<SyncStatusCubit, SyncStatusState>(
    builder: (final BuildContext context, final SyncStatusState state) {
      final bool isDegraded = state.syncStatus == SyncStatus.degraded;
      if (!isDegraded) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveHorizontalGapL,
          vertical: context.responsiveGapS,
        ),
        child: AppMessage(
          title: 'Sync Issues Detected',
          message:
              'Some data may not be synced. Tap retry to attempt synchronization.',
          isError: true,
          actions: <Widget>[
            PlatformAdaptive.textButton(
              context: context,
              onPressed: () {
                final SyncStatusCubit cubit = context.read<SyncStatusCubit>();
                unawaited(cubit.flush());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    },
  );
}
