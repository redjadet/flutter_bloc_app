import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_helpers.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/app_message.dart';

/// Global sync status banner that displays when sync is degraded or error.
///
/// Shows "Sync issues detected" message with retry action when sync status
/// is degraded. Can be integrated into CommonPageLayout or app scaffold.
class SyncStatusBanner extends StatefulWidget {
  const SyncStatusBanner({super.key});

  @override
  State<SyncStatusBanner> createState() => _SyncStatusBannerState();
}

class _SyncStatusBannerState extends State<SyncStatusBanner> {
  @override
  void initState() {
    super.initState();
    if (CubitHelpers.isCubitAvailable<SyncStatusCubit, SyncStatusState>(
      context,
    )) {
      context.cubit<SyncStatusCubit>().ensureStarted();
    }
  }

  @override
  Widget build(
    final BuildContext context,
  ) => BlocBuilder<SyncStatusCubit, SyncStatusState>(
    builder: (final context, final state) {
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
                final SyncStatusCubit cubit = context.cubit<SyncStatusCubit>();
                // check-ignore: user action triggers async flush
                unawaited(cubit.flush());
              },
              child: Text(context.l10n.appInfoRetryButtonLabel),
            ),
          ],
        ),
      );
    },
  );
}
