import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_app/app/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/app/utils/bloc/cubit_helpers.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';

/// BuildContext extensions for sync status (e.g. ensuring SyncStatusCubit is started).
extension SyncContextExtensions on BuildContext {
  /// If [SyncStatusCubit] is in the tree, calls [SyncStatusCubit.ensureStarted].
  ///
  /// Use in initState or when entering a screen that may show sync status so sync
  /// runs when the cubit is provided (e.g. from app scope).
  void ensureSyncStartedIfAvailable() {
    if (CubitHelpers.isCubitAvailable<SyncStatusCubit, SyncStatusState>(this)) {
      cubit<SyncStatusCubit>().ensureStarted();
    }
  }
}
