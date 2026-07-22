import 'dart:async';

import 'package:design_system/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/app/sync/sync_banner_helpers.dart';
import 'package:flutter_bloc_app/app/sync/sync_context_extensions.dart';
import 'package:flutter_bloc_app/app/utils/bloc/cubit_helpers.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_cubit.dart';
import 'package:flutter_bloc_app/features/todo_list/presentation/cubit/todo_list_state.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';
import 'package:networking/networking.dart';

/// Sync status banner for the todo list feature. Uses shared logic from
/// sync_banner_helpers (shouldShowSyncBanner, syncBannerTitleAndMessage).
class TodoSyncBanner extends StatelessWidget {
  const TodoSyncBanner({super.key});

  @override
  Widget build(final BuildContext context) {
    context.ensureSyncStartedIfAvailable();

    if (!CubitHelpers.isCubitAvailable<SyncStatusCubit, SyncStatusState>(
      context,
    )) {
      return const SizedBox.shrink();
    }

    return TypeSafeBlocConsumer<SyncStatusCubit, SyncStatusState>(
      listener: (final context, final state) {
        if (!CubitHelpers.isCubitAvailable<TodoListCubit, TodoListState>(
          context,
        )) {
          return;
        }
        // check-ignore: listener callback is event-driven, not a build side effect
        unawaited(context.cubit<TodoListCubit>().refreshPendingSyncCount());
      },
      builder: (final context, final syncState) {
        if (!CubitHelpers.isCubitAvailable<TodoListCubit, TodoListState>(
          context,
        )) {
          return const SizedBox.shrink();
        }

        return TypeSafeBlocBuilder<TodoListCubit, TodoListState>(
          builder: (final context, final todoState) {
            final bool isOffline =
                syncState.networkStatus == NetworkStatus.offline;
            final bool isSyncing = syncState.syncStatus == SyncStatus.syncing;
            final int pendingCount = todoState.pendingSyncCount;
            if (!shouldShowSyncBanner(
              isOffline: isOffline,
              isSyncing: isSyncing,
              pendingCount: pendingCount,
            )) {
              return const SizedBox.shrink();
            }
            final (String title, String message) = syncBannerTitleAndMessage(
              context.l10n,
              isOffline: isOffline,
              isSyncing: isSyncing,
              pendingCount: pendingCount,
            );
            return Padding(
              padding: EdgeInsets.only(bottom: context.responsiveGapS),
              child: SyncBannerContent(
                title: title,
                message: message,
                isError: isOffline,
              ),
            );
          },
        );
      },
    );
  }
}
