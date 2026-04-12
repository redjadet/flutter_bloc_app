// check-ignore: nonbuilder_lists - small, fixed-size page content
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_session_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

class StaffAppDemoDashboardPage extends StatelessWidget {
  const StaffAppDemoDashboardPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final state = context.watch<StaffDemoSessionCubit>().state;
    final l10n = context.l10n;

    return CommonPageLayout(
      title: l10n.staffDemoDashboardTitle,
      body: switch (state.status) {
        StaffDemoSessionStatus.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        StaffDemoSessionStatus.missingProfile => CommonErrorView(
          message: l10n.staffDemoDashboardNoProfile,
        ),
        StaffDemoSessionStatus.inactive => CommonErrorView(
          message: l10n.staffDemoDashboardInactiveProfile,
        ),
        StaffDemoSessionStatus.error => CommonErrorView(
          message: state.errorMessage ?? l10n.errorUnknown,
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
    final l10n = context.l10n;
    final profile = state.profile;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          profile == null
              ? l10n.staffDemoDashboardLoading
              : l10n.staffDemoDashboardHello(profile.displayName),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(l10n.staffDemoDashboardIntro),
      ],
    );
  }
}
