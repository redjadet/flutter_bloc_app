import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/sync/presentation/sync_status_cubit.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Trailing "Sync now" control for sync banners.
///
/// Owns in-flight spinner state and calls [SyncStatusCubit.flush]. Callers
/// pass [enabled] for offline/pending/syncing gates; this widget also
/// disables itself while a flush is already running.
class SyncNowTrailingButton extends StatefulWidget {
  const new({required this.enabled, required this.logLabel, super.key});

  /// When false (and not already flushing), the button is disabled.
  final bool enabled;

  /// Prefix for [AppLogger.error] if flush fails.
  final String logLabel;

  @override
  State<SyncNowTrailingButton> createState() => _SyncNowTrailingButtonState();
}

class _SyncNowTrailingButtonState extends State<SyncNowTrailingButton> {
  bool _isManualSyncing = false;

  Future<void> _handleSyncNow() async {
    if (_isManualSyncing) {
      return;
    }
    setState(() => _isManualSyncing = true);
    try {
      await context.cubit<SyncStatusCubit>().flush();
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        '${widget.logLabel}.handleSyncNow failed',
        error,
        stackTrace,
      );
    } finally {
      if (mounted) {
        setState(() => _isManualSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canPress = widget.enabled && !_isManualSyncing;
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: PlatformAdaptive.textButton(
        context: context,
        onPressed: canPress ? _handleSyncNow : null,
        child: _isManualSyncing
            ? SizedBox(
                height: context.responsiveGapM,
                width: context.responsiveGapM,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(context.l10n.syncStatusSyncNowButton),
      ),
    );
  }
}
