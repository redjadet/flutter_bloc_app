// check-ignore: nonbuilder_lists - small, fixed-size page content
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_proof_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_proof_state.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_sites_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/widgets/staff_demo_proof_signature_section.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/media/media_pick_error_messages.dart';

part 'staff_app_demo_proof_page_widgets.part.dart';

class StaffAppDemoProofPage extends StatelessWidget {
  const StaffAppDemoProofPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final state = context.watch<StaffDemoProofCubit>().state;
    final l10n = context.l10n;
    final bool pinBanner = _ProofStatusBanner.messageFor(state, l10n) != null;
    return CommonPageLayout(
      title: l10n.staffDemoProofTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (pinBanner)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _ProofStatusBanner(state: state),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              children: const <Widget>[
                _PhotoSection(),
                SizedBox(height: 16),
                StaffDemoProofSignatureSection(),
                SizedBox(height: 16),
                _SubmitSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
