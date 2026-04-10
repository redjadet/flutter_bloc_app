// check-ignore: nonbuilder_lists - small, fixed-size page content
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_session_state.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

class StaffAppDemoDashboardPage extends StatelessWidget {
  const StaffAppDemoDashboardPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final state = context.watch<StaffDemoSessionCubit>().state;

    return CommonPageLayout(
      title: 'Staff demo',
      body: switch (state.status) {
        StaffDemoSessionStatus.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        StaffDemoSessionStatus.missingProfile => const CommonErrorView(
          message:
              'No staff demo profile found for this user. Seed staffDemoProfiles/{uid} in Firestore.',
        ),
        StaffDemoSessionStatus.inactive => const CommonErrorView(
          message: 'This staff demo profile is inactive.',
        ),
        StaffDemoSessionStatus.error => CommonErrorView(
          message: state.errorMessage ?? 'Unknown error.',
        ),
        _ => _DashboardBody(state: state),
      },
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.state});

  final StaffDemoSessionState state;

  @override
  Widget build(final BuildContext context) {
    final profile = state.profile;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          profile == null ? 'Loading…' : 'Hello, ${profile.displayName}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        const Text(
          'Use the bottom tabs to navigate the demo. Accounting flow starts with Timeclock.',
        ),
      ],
    );
  }
}
