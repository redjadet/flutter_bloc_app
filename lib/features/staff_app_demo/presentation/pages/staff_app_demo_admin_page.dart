// check-ignore: nonbuilder_lists - small, fixed-size page content
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/admin/staff_demo_admin_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/admin/staff_demo_admin_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

class StaffAppDemoAdminPage extends StatelessWidget {
  const StaffAppDemoAdminPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final state = context.watch<StaffDemoAdminCubit>().state;
    final flagged = state.recentEntries.where((e) => e.isFlagged).toList();
    final l10n = context.l10n;

    return CommonPageLayout(
      title: l10n.staffDemoAdminTitle,
      body: RefreshIndicator(
        onRefresh: context.cubit<StaffDemoAdminCubit>().load,
        child: switch (state.status) {
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
                  message: state.errorMessage ?? l10n.errorUnknown,
                ),
              ),
            ],
          ),
          StaffDemoAdminStatus.ready => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(
                l10n.staffDemoAdminRecentEntries(state.recentEntries.length),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.staffDemoAdminFlagged(flagged.length),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              if (flagged.isEmpty) Text(l10n.staffDemoAdminNoFlagged),
              for (final entry in flagged)
                ListTile(
                  dense: true,
                  title: Text(entry.entryId),
                  subtitle: Text(
                    'user=${entry.userId} state=${entry.entryState} '
                    'flags=${entry.flags.toJson()}',
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
