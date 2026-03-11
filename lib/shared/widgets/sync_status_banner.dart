import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_context_extensions.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/app_message.dart';
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';

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
  bool _didEnsureSyncStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didEnsureSyncStarted) {
      return;
    }
    _didEnsureSyncStarted = true;
    context.ensureSyncStartedIfAvailable();
  }

  @override
  Widget build(final BuildContext context) {
    if (context.tryCubit<SyncStatusCubit>() == null) {
      return const SizedBox.shrink();
    }
    return TypeSafeBlocSelector<SyncStatusCubit, SyncStatusState, SyncStatus>(
      selector: (final state) => state.syncStatus,
      builder: (final context, final syncStatus) {
        if (syncStatus != SyncStatus.degraded) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveHorizontalGapL,
            vertical: context.responsiveGapS,
          ),
          child: AppMessage(
            title: context.l10n.syncStatusDegradedTitle,
            message: context.l10n.syncStatusDegradedMessage,
            isError: true,
            actions: <Widget>[
              PlatformAdaptive.textButton(
                context: context,
                onPressed: () {
                  final SyncStatusCubit cubit = context
                      .cubit<SyncStatusCubit>();
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
}
