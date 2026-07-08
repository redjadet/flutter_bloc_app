// check-ignore: nonbuilder_lists - small, fixed-size page content
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_week_calendar.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_forms_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_forms_state.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_sites_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/staff_demo_presentation_l10n.dart';

part 'staff_app_demo_forms_page_widgets.part.dart';

class StaffAppDemoFormsPage extends StatelessWidget {
  const StaffAppDemoFormsPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final state = context.watch<StaffDemoFormsCubit>().state;
    final l10n = context.l10n;
    final bool pinBanner =
        staffDemoFormsStatusBannerMessage(l10n, state) != null;

    return CommonPageLayout(
      title: l10n.staffDemoFormsTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (pinBanner)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _StatusBanner(state: state),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              children: const <Widget>[
                _AvailabilityCard(),
                SizedBox(height: 16),
                _ManagerReportCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
