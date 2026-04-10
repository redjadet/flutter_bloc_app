// check-ignore: nonbuilder_lists - small, fixed-size page content
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/admin/staff_demo_admin_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/admin/staff_demo_admin_state.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

class StaffAppDemoAdminPage extends StatelessWidget {
  const StaffAppDemoAdminPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final state = context.watch<StaffDemoAdminCubit>().state;
    final flagged = state.recentEntries.where((e) => e.isFlagged).toList();

    return CommonPageLayout(
      title: 'Admin',
      body: switch (state.status) {
        StaffDemoAdminStatus.initial ||
        StaffDemoAdminStatus.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        StaffDemoAdminStatus.error => CommonErrorView(
          message: state.errorMessage ?? 'Unknown error.',
        ),
        StaffDemoAdminStatus.ready => ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text(
              'Recent time entries (${state.recentEntries.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Flagged (${flagged.length})',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            if (flagged.isEmpty) const Text('No flagged entries found.'),
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
            const Text(
              'Seeding reminders: create staffDemoProfiles/{uid}, staffDemoSites/{siteId}, '
              'and staffDemoShifts/{shiftId} in Firestore for full demo coverage.',
            ),
          ],
        ),
      },
    );
  }
}
