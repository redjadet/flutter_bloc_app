// check-ignore: nonbuilder_lists - small, fixed-size page content
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/app/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_time_entry_summary.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_admin_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_admin_state.dart';

class StaffAppDemoAdminPage extends StatelessWidget {
  const StaffAppDemoAdminPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final data = context
        .selectState<
          StaffDemoAdminCubit,
          StaffDemoAdminState,
          _StaffDemoAdminViewData
        >(selector: _StaffDemoAdminViewData.fromState);
    final l10n = context.l10n;

    return CommonPageLayout(
      title: l10n.staffDemoAdminTitle,
      body: RefreshIndicator(
        onRefresh: context.cubit<StaffDemoAdminCubit>().load,
        child: switch (data.status) {
          StaffDemoAdminStatus.initial ||
          StaffDemoAdminStatus.loading => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(
                height: 240,
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
          StaffDemoAdminStatus.error => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: 240,
                child: CommonErrorView(
                  message: data.errorMessage ?? l10n.errorUnknown,
                ),
              ),
            ],
          ),
          StaffDemoAdminStatus.ready => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(
                l10n.staffDemoAdminRecentEntries(data.recentCount),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.staffDemoAdminFlagged(data.flaggedCount),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              if (data.flaggedEntries.isEmpty)
                Text(l10n.staffDemoAdminNoFlagged),
              for (final entry in data.flaggedEntries)
                ListTile(
                  dense: true,
                  title: Text(entry.entryId),
                  subtitle: Text(
                    'user=${entry.userId} state=${entry.entryState} '
                    'flags=${entry.flags.asMap}',
                  ),
                ),
              const SizedBox(height: 16),
              Text(l10n.staffDemoAdminSeedingReminder),
            ],
          ),
        },
      ),
    );
  }
}

@immutable
class _StaffDemoAdminViewData {
  const _StaffDemoAdminViewData({
    required this.status,
    required this.errorMessage,
    required this.recentCount,
    required this.flaggedEntries,
  });

  factory _StaffDemoAdminViewData.fromState(final StaffDemoAdminState state) {
    final flaggedEntries = <StaffDemoTimeEntrySummary>[
      for (final entry in state.recentEntries)
        if (entry.isFlagged) entry,
    ];
    return _StaffDemoAdminViewData(
      status: state.status,
      errorMessage: state.errorMessage,
      recentCount: state.recentEntries.length,
      flaggedEntries: List<StaffDemoTimeEntrySummary>.unmodifiable(
        flaggedEntries,
      ),
    );
  }

  final StaffDemoAdminStatus status;
  final String? errorMessage;
  final int recentCount;
  final List<StaffDemoTimeEntrySummary> flaggedEntries;

  int get flaggedCount => flaggedEntries.length;

  static const DeepCollectionEquality _listEq = DeepCollectionEquality();

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is _StaffDemoAdminViewData &&
          other.status == status &&
          other.errorMessage == errorMessage &&
          other.recentCount == recentCount &&
          _listEq.equals(other.flaggedEntries, flaggedEntries);

  @override
  int get hashCode => Object.hash(
    status,
    errorMessage,
    recentCount,
    _listEq.hash(flaggedEntries),
  );
}
