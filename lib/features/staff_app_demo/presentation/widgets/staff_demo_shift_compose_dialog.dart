import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/messages/staff_demo_messages_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/sites/staff_demo_sites_cubit.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';

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
  final BuildContext context, {
  required final StaffDemoProfileRepository profileRepository,
}) async {
  final l10n = context.l10n;
  final DateTime defaultStartUtc = DateTime.now().toUtc().add(
    const Duration(minutes: 30),
  );
  final DateTime defaultEndUtc = defaultStartUtc.add(
    const Duration(hours: 4),
  );

  final Future<List<StaffDemoProfile>> staffFuture = profileRepository
      .listAssignableStaff();

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

  await context.cubit<StaffDemoMessagesCubit>().sendShiftAssignment(
    toUserId: result.toUserId,
    body: result.body,
    siteId: result.siteId,
    startAtUtc: defaultStartUtc,
    endAtUtc: defaultEndUtc,
  );
}
