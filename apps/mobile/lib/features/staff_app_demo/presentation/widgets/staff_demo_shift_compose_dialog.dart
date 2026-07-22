import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_messages_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_sites_cubit.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';

part 'staff_demo_shift_compose_dialog_site.part.dart';
part 'staff_demo_shift_compose_dialog_widgets.part.dart';

/// Values collected when the user confirms shift assignment in the compose dialog.
class _StaffDemoShiftComposeResult {
  const _StaffDemoShiftComposeResult({
    required this.toUserId,
    required this.body,
    required this.siteId,
  });

  final String toUserId;
  final String body;
  final String siteId;
}

/// Manager/accountant shift assignment compose flow (Firestore-backed demo).
Future<void> showStaffDemoShiftComposeDialog(
  final BuildContext context,
) async {
  final l10n = context.l10n;
  final StaffDemoMessagesCubit messagesCubit = context
      .cubit<StaffDemoMessagesCubit>();
  final Future<List<StaffDemoProfile>> staffFuture = messagesCubit
      .loadAssignableStaff();

  final StaffDemoSitesCubit sitesCubit = context.cubit<StaffDemoSitesCubit>();

  final _StaffDemoShiftComposeResult? result =
      await showDialog<_StaffDemoShiftComposeResult>(
        context: context,
        builder: (final dialogContext) => BlocProvider.value(
          value: sitesCubit,
          child: _StaffDemoShiftComposeDialog(
            staffFuture: staffFuture,
            defaultBodyText: l10n.staffDemoComposeDefaultShiftBody,
          ),
        ),
      );

  if (!context.mounted) return;
  if (result == null) return;

  await messagesCubit.sendShiftAssignmentWithDefaults(
    toUserId: result.toUserId,
    body: result.body,
    siteId: result.siteId,
  );
}
